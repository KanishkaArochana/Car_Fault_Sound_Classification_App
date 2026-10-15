import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../widgets/recording_button.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/alert_dialogs.dart';
import '../../services/audio_recording_service.dart';
import 'processing_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late final AudioRecordingService _audioService;
  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<int>? _durationSub;

  int _elapsedSeconds = 0;
  bool _isRecording = false;
  bool _permissionGranted = false;

  // Waveform heights normalized (35 bars)
  final List<double> _waveformHeights = List.generate(35, (index) => 0.2);

  @override
  void initState() {
    super.initState();
    _audioService = AudioRecordingService();
  }

  void _onStartRecordingPressed() {
    if (_permissionGranted) {
      _startRecordingSession();
    } else {
      AppAlerts.showPermissionRequired(
        context,
        onAllow: () {
          setState(() {
            _permissionGranted = true;
          });
          _startRecordingSession();
        },
      );
    }
  }

  void _startRecordingSession() {
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
    });

    _audioService.startRecording();

    _durationSub?.cancel();
    _durationSub = _audioService.durationStream.listen((seconds) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = seconds;
        });

        // Auto-stop at 30 seconds (six 5-second segments for analysis)
        if (_elapsedSeconds >= 30) {
          _handleStopRecording();
        }
      }
    });

    _amplitudeSub?.cancel();
    _amplitudeSub = _audioService.amplitudeStream.listen((amplitude) {
      if (mounted && _isRecording) {
        setState(() {
          _waveformHeights.removeAt(0);
          _waveformHeights.add(amplitude);
        });
      }
    });
  }

  Future<void> _handleStopRecording() async {
    if (!_isRecording) return;

    if (_elapsedSeconds < 5) {
      // Show short recording alert if recorded for less than 5 seconds
      // (each analyzed segment is 5 seconds long).
      await AppAlerts.showShortRecording(context);
      return;
    }

    setState(() {
      _isRecording = false;
    });

    final audioPath = await _audioService.stopRecording();
    if (mounted && audioPath != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProcessingScreen(audioPath: audioPath),
        ),
      );
    }
  }

  String _formatTimer(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    String minsStr = mins.toString().padLeft(2, '0');
    String secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _durationSub?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 26,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            children: [
              // Header Title
              const Text(
                RecordingStrings.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10.0),
              // Subtitle
              const Text(
                RecordingStrings.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),

              const Spacer(),

              // Pulsing Recording Mic Button
              RecordingButton(
                isRecording: _isRecording,
                onTap: () {
                  if (_isRecording) {
                    _handleStopRecording();
                  } else {
                    _onStartRecordingPressed();
                  }
                },
              ),

              const SizedBox(height: 24.0),

              // Timer Display (00:03 / 00:05)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatTimer(_elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    ' / ${RecordingStrings.timerTotalFormat}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28.0),

              // Audio Waveform Visualizer Bar
              SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_waveformHeights.length, (index) {
                    double heightPercent = _waveformHeights[index];
                    double barHeight = (heightPercent * 40.0).clamp(6.0, 42.0);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 90),
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      width: 4.0,
                      height: _isRecording ? barHeight : 8.0,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Dynamic Action Button: "Start Recording" -> "Stop Recording"
              if (!_isRecording)
                PrimaryButton(
                  text: RecordingStrings.startRecording,
                  onPressed: _onStartRecordingPressed,
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: OutlinedButton(
                    onPressed: _handleStopRecording,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.stopButtonBg,
                      side: const BorderSide(
                        color: AppColors.stopButtonBorder,
                        width: 1.5,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.stopButtonRed,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        const Text(
                          RecordingStrings.stopRecording,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.stopButtonRed,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16.0),

              // Tips Box Card Widget
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.tipsBg,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: AppColors.tipsBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2.0),
                      child: SvgPicture.asset(
                        'assets/icons/tip.svg',
                        width: 22,
                        height: 22,
                        colorFilter: const ColorFilter.mode(
                          AppColors.tipsIconBlue,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            RecordingStrings.tipsTitle,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            RecordingStrings.tipsBody,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
