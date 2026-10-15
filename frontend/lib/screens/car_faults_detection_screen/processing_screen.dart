import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../widgets/processing_progress_ring.dart';
import '../../widgets/processing_step_tile.dart';
import '../../widgets/alert_dialogs.dart';
import '../../services/api_inference_service.dart';
import '../../models/ranked_fault_result.dart';
import 'result_ranked_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String audioPath;

  const ProcessingScreen({
    super.key,
    required this.audioPath,
  });

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _overallProgress = 0.0; // 0.0 to 1.0
  Timer? _progressTimer;

  StepStatus _noiseStatus = StepStatus.pending;
  StepStatus _spectrogramStatus = StepStatus.pending;
  StepStatus _inferenceStatus = StepStatus.pending;

  late final ApiInferenceService _inferenceService;

  @override
  void initState() {
    super.initState();
    _inferenceService = ApiInferenceService();

    _startAnalysisPipeline();
  }

  void _startAnalysisPipeline() async {
    // 1. Start overall progress counter animation
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          if (_overallProgress < 0.95) {
            _overallProgress += 0.01;
          }
        });
      }
    });

    try {
      // Step 1: split the recording into 5-second segments and upload each
      // one to the analysis server. (Noise reduction + feature extraction
      // happen server-side, per segment, as part of each /predict request.)
      setState(() {
        _noiseStatus = StepStatus.inProgress;
      });

      // Kick off the real network requests now, then let the UI steps
      // animate forward while we wait for all of them to come back.
      final resultFuture = _inferenceService.classifyAudioFileChunked(
        widget.audioPath,
        chunkSeconds: 5,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _noiseStatus = StepStatus.completed;
        _spectrogramStatus = StepStatus.inProgress;
        _overallProgress = 0.33;
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _spectrogramStatus = StepStatus.completed;
        _inferenceStatus = StepStatus.inProgress;
        _overallProgress = 0.66;
      });

      // Wait for every segment's prediction and the aggregated ranking.
      final result = await resultFuture;

      if (!mounted) return;
      setState(() {
        _inferenceStatus = StepStatus.completed;
        _overallProgress = 1.0;
      });

      _progressTimer?.cancel();

      if (!mounted) return;
      _navigateToResult(result);

    } on ServerUnreachableException {
      _progressTimer?.cancel();
      if (mounted) {
        final navigator = Navigator.of(context);
        await AppAlerts.showModelNotAvailable(context);
        if (mounted) {
          navigator.pop();
        }
      }
    } catch (e) {
      _progressTimer?.cancel();
      if (mounted) {
        final navigator = Navigator.of(context);
        await AppAlerts.showProcessingFailed(context);
        if (mounted) {
          navigator.pop();
        }
      }
    }
  }

  void _navigateToResult(RankedFaultResult result) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultRankedScreen(result: result),
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _inferenceService.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Title Header
              const Text(
                ProcessingStrings.title,
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8.0),
              // Subtitle
              const Text(
                ProcessingStrings.subtitle,
                style: TextStyle(
                  fontSize: 15.0,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // Circular Progress Ring
              ProcessingProgressRing(progress: _overallProgress),

              const Spacer(),

              // Steps Checklist Layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ProcessingStepTile(
                      title: ProcessingStrings.noiseReductionStep,
                      leadIcon: Icons.volume_mute_rounded,
                      leadIconBg: const Color(0xFFE6F4EA),
                      leadIconColor: const Color(0xFF137333),
                      status: _noiseStatus,
                    ),
                    const SizedBox(height: 8.0),
                    ProcessingStepTile(
                      title: ProcessingStrings.melSpectrogramStep,
                      leadIcon: Icons.graphic_eq_rounded,
                      leadIconBg: const Color(0xFFE6F4EA),
                      leadIconColor: const Color(0xFF137333),
                      status: _spectrogramStatus,
                    ),
                    const SizedBox(height: 8.0),
                    ProcessingStepTile(
                      title: ProcessingStrings.aiClassificationStep,
                      leadIcon: Icons.auto_awesome_rounded,
                      leadIconBg: const Color(0xFFEFF6FF),
                      leadIconColor: AppColors.primaryBlue,
                      status: _inferenceStatus,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Tips Card Box
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/protect.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(
                        AppColors.tipsIconBlue,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    const Expanded(
                      child: Text(
                        ProcessingStrings.tipsBody,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
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
