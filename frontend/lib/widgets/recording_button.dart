import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class RecordingButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final String iconPath;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onTap,
    this.iconPath = 'assets/icons/mic.svg',
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.12).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 190,
        height: 190,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            double scale = widget.isRecording ? _scaleAnimation.value : 1.0;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring 3
                Container(
                  width: 180 * scale,
                  height: 180 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                ),
                // Outer Ring 2
                Container(
                  width: 145 * scale,
                  height: 145 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                // Outer Ring 1
                Container(
                  width: 110 * scale,
                  height: 110 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue.withValues(alpha: 0.16),
                  ),
                ),
                // Core Button Circle
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryBlue,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.iconPath,
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
