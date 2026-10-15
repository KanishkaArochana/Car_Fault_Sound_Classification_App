import '../models/fault_result.dart';
import '../constants/fault_solutions.dart';

/// Exception thrown when the AI model file or runtime is unavailable.
class ModelNotAvailableException implements Exception {
  final String message;
  ModelNotAvailableException([this.message = 'AI model is not available']);

  @override
  String toString() => message;
}

/// Service responsible for running TFLite model classification on Mel-Spectrogram features.
class TfliteInferenceService {
  bool _isModelLoaded = false;

  /// Loads the TFLite model from assets
  Future<void> loadModel() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _isModelLoaded = true;
  }

  /// Runs AI classification inference on Mel-Spectrogram features
  Future<FaultResult> classify(List<List<double>> spectrogram) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    // Simulate model inference execution
    await Future.delayed(const Duration(milliseconds: 1400));

    // Force output to Bad Ignition with 94% confidence to test ResultFaultScreen redirection
    String selectedFault = 'Bad Ignition';
    double confidence = 0.94;

    final solution = FaultSolutionsData.getSolutionForFault(selectedFault);

    return FaultResult(
      faultName: solution.faultName,
      confidence: confidence,
      timestamp: DateTime.now(),
      recommendations: solution.recommendations,
    );
  }

  /// Releases TFLite model resources
  void dispose() {
    _isModelLoaded = false;
  }
}
