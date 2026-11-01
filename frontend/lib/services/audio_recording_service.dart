import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Audio recording service for microphone input and amplitude streaming.
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  // State & timers
  bool _isRecording = false;
  int _elapsedMilliseconds = 0;
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  String? _currentRecordingPath;

  // Stream controllers
  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();

  // Getters
  bool get isRecording => _isRecording;
  int get elapsedMilliseconds => _elapsedMilliseconds;
  double get elapsedSeconds => _elapsedMilliseconds / 1000.0;

  /// Stream of normalized amplitude (0.0 - 1.0) for visualizer
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// Stream of recording duration in seconds
  Stream<int> get durationStream => _durationController.stream;

  /// Check mic permission
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request mic permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording (saves 32kHz mono WAV to temp)
  Future<void> startRecording() async {
    if (_isRecording) return;

    // Check mic permission
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission not granted');
      }
    }

    // Temp file path
    final dir = Directory.systemTemp;
    final path =
        '${dir.path}/engine_sound_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentRecordingPath = path;

    // Start WAV recording
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 32000, // PANNs Cnn14 sample rate
        numChannels: 1,
      ),
      path: path,
    );

    _isRecording = true;
    _elapsedMilliseconds = 0;

    // Duration timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _elapsedMilliseconds += 100;
      _durationController.add((_elapsedMilliseconds / 1000).floor());
    });

    // Amplitude stream for visualizer
    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      if (_isRecording) {
        // Normalize dBFS (-45 to 0) to 0.0 - 1.0
        const minDb = -45.0;
        final normalized =
            ((amp.current - minDb) / (0 - minDb)).clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      }
    });
  }

  /// Stop recording and return WAV path
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _isRecording = false;

    // Stop timer and stream
    _timer?.cancel();
    await _amplitudeSub?.cancel();

    // Finalize recording
    final path = await _recorder.stop();
    return path ?? _currentRecordingPath;
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _amplitudeController.close();
    _durationController.close();
    _recorder.dispose();
  }
}
