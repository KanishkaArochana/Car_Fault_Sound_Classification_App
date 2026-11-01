import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../constants/fault_solutions.dart';
import '../models/fault_result.dart';
import '../models/ranked_fault_result.dart';
import 'audio_chunk_service.dart';

// Network or connection failure exception
class ServerUnreachableException implements Exception {
  final String message;
  ServerUnreachableException([
    this.message = 'Could not reach the analysis server. '
        'Make sure your phone is on the same Wi-Fi network as the '
        'computer running the server, and that the server is running.',
  ]);

  @override
  String toString() => message;
}

// Backend prediction failure exception
class InferenceFailedException implements Exception {
  final String message;
  InferenceFailedException([this.message = 'Analysis failed on the server.']);

  @override
  String toString() => message;
}

// Maps backend class names to display names
const Map<String, String> _classNameDisplayMap = {
  'bad_ignition': 'Bad Ignition',
  'dead_battery': 'Dead Battery',
  'low_oil': 'Low Oil',
  'no oil_serpentine belt': 'No Oil and Serpentine Belt Issue',
  'normal_brakes': 'Normal Brakes',
  'normal_engine_idle': 'Normal Engine Idle',
  'normal_engine_startup': 'Normal Engine Startup',
  'power steering combined_no oil': 'Power Steering and Low Oil Issue',
  'power steering combined_no oil_serpentine belt':
      'Power Steering, Low Oil, and Serpentine Belt Issue',
  'power steering combined_serpentine belt':
      'Power Steering and Serpentine Belt Issue',
  'power_steering': 'Power Steering',
  'serpentine_belt': 'Serpentine Belt',
  'worn_out_brakes': 'Worn Out Brakes',
};

// Single chunk raw prediction
class _RawPrediction {
  final String rawClassName;
  final double confidence;
  _RawPrediction(this.rawClassName, this.confidence);
}

// Service for backend audio inference and prediction aggregation.
class ApiInferenceService {
  final AudioChunkService _chunkService = AudioChunkService();

  // Classifies audio by splitting into chunks and aggregating predictions
  Future<RankedFaultResult> classifyAudioFileChunked(
    String audioPath, {
    int chunkSeconds = 5,
  }) async {
    // Validate file existence
    final file = File(audioPath);
    if (!await file.exists()) {
      throw InferenceFailedException('Recording file not found: $audioPath');
    }

    // Split audio into chunks
    final chunkPaths = await _chunkService.splitIntoChunks(
      audioPath,
      chunkSeconds: chunkSeconds,
    );

    // Verify minimum audio length
    if (chunkPaths.isEmpty) {
      throw InferenceFailedException(
        'Recording was too short to analyze. Please record for longer.',
      );
    }

    final rawResults = <_RawPrediction>[];
    try {
      // Send chunks sequentially
      for (final chunkPath in chunkPaths) {
        rawResults.add(await _predictRaw(chunkPath));
      }
    } finally {
      // Cleanup temporary chunks
      await _chunkService.cleanupChunks(chunkPaths);
    }

    // Aggregate predictions
    return _aggregate(rawResults);
  }

  // Classifies a single audio file without chunking
  Future<FaultResult> classifyAudioFile(String audioPath) async {
    final raw = await _predictRaw(audioPath);
    final displayName =
        _classNameDisplayMap[raw.rawClassName] ?? raw.rawClassName;
    final solution = FaultSolutionsData.getSolutionForFault(displayName);

    return FaultResult(
      faultName: solution.faultName,
      confidence: raw.confidence,
      timestamp: DateTime.now(),
      recommendations: solution.recommendations,
    );
  }

  // Sends single chunk to /predict endpoint
  Future<_RawPrediction> _predictRaw(String audioPath) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw InferenceFailedException('Audio chunk not found: $audioPath');
    }

    // Multipart upload request
    final uri = Uri.parse(ApiConfig.predictEndpoint);
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', audioPath));

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse =
          await request.send().timeout(ApiConfig.requestTimeout);
    } on SocketException {
      throw ServerUnreachableException();
    } on HttpException {
      throw ServerUnreachableException();
    } catch (e) {
      throw ServerUnreachableException();
    }

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw InferenceFailedException(
        'Server returned an error (status ${response.statusCode}).',
      );
    }

    late Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw InferenceFailedException('Could not parse server response.');
    }

    final predictedClass = json['predicted_class'] as String?;
    final confidence = (json['confidence'] as num?)?.toDouble();

    if (predictedClass == null || confidence == null) {
      throw InferenceFailedException('Server response missing expected fields.');
    }

    return _RawPrediction(predictedClass, confidence);
  }

  // Aggregates chunk predictions into ranked results
  RankedFaultResult _aggregate(List<_RawPrediction> rawResults) {
    final totalChunks = rawResults.length;
    final Map<String, List<double>> confidencesByClass = {};

    // Group confidences by class
    for (final r in rawResults) {
      confidencesByClass
          .putIfAbsent(r.rawClassName, () => [])
          .add(r.confidence);
    }

    // Calculate ranking stats per class
    final rankings = confidencesByClass.entries.map((entry) {
      final rawClassName = entry.key;
      final confidences = entry.value;
      final avgConfidence =
          confidences.reduce((a, b) => a + b) / confidences.length;
      final displayName = _classNameDisplayMap[rawClassName] ?? rawClassName;
      final solution = FaultSolutionsData.getSolutionForFault(displayName);

      return ClassRanking(
        faultName: solution.faultName,
        rawClassName: rawClassName,
        occurrences: confidences.length,
        totalChunks: totalChunks,
        averageConfidence: avgConfidence,
        recommendations: solution.recommendations,
      );
    }).toList();

    // Sort by frequency and confidence descending
    rankings.sort((a, b) {
      final byCount = b.occurrences.compareTo(a.occurrences);
      if (byCount != 0) return byCount;
      return b.averageConfidence.compareTo(a.averageConfidence);
    });

    return RankedFaultResult(
      rankings: rankings,
      totalChunks: totalChunks,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {}
}
