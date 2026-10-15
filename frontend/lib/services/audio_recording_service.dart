import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Service responsible for handling microphone permissions, recording session
/// timer, saving recording audio files, and streaming real-time amplitude
/// data for the visualizer. Uses the `record` package for real microphone
/// capture (WAV output) so recordings can be uploaded to the backend model.
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  int _elapsedMilliseconds = 0;
  Timer? _timer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  String? _currentRecordingPath;

  final StreamController<double> _amplitudeController =
      StreamController<double>.broadcast();
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();

  bool get isRecording => _isRecording;
  int get elapsedMilliseconds => _elapsedMilliseconds;
  double get elapsedSeconds => _elapsedMilliseconds / 1000.0;

  /// Stream of real-time amplitude levels (0.0 to 1.0) for visualizer waveform
  Stream<double> get amplitudeStream => _amplitudeController.stream;

  /// Stream of elapsed recording duration in seconds
  Stream<int> get durationStream => _durationController.stream;

  /// Checks if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Start recording audio session. Saves a real WAV file to the app's
  /// temporary directory, matching the 32kHz mono format the backend
  /// model (PANNs Cnn14) expects.
  Future<void> startRecording() async {
    if (_isRecording) return;

    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission not granted');
      }
    }

    final dir = Directory.systemTemp;
    final path =
        '${dir.path}/engine_sound_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentRecordingPath = path;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 32000, // matches PANNs Cnn14 expected sample rate
        numChannels: 1,
      ),
      path: path,
    );

    _isRecording = true;
    _elapsedMilliseconds = 0;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _elapsedMilliseconds += 100;
      _durationController.add((_elapsedMilliseconds / 1000).floor());
    });

    _amplitudeSub?.cancel();
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      if (_isRecording) {
        // amp.current is in dBFS, roughly -45 (quiet) to 0 (loudest).
        // Normalize to a 0.0-1.0 range for the waveform visualizer.
        const minDb = -45.0;
        final normalized =
            ((amp.current - minDb) / (0 - minDb)).clamp(0.0, 1.0);
        _amplitudeController.add(normalized);
      }
    });
  }

  /// Stop recording audio session and return path to the saved WAV file.
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    _isRecording = false;
    _timer?.cancel();
    await _amplitudeSub?.cancel();

    final path = await _recorder.stop();
    return path ?? _currentRecordingPath;
  }

  /// Dispose service streams and timers
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    _amplitudeController.close();
    _durationController.close();
    _recorder.dispose();
  }
}
