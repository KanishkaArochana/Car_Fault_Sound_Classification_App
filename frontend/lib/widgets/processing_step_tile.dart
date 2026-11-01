import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

enum StepStatus { pending, inProgress, completed, failed }

class ProcessingStepTile extends StatelessWidget {
  final String title;
  final IconData leadIcon;
  final Color leadIconBg;
  final Color leadIconColor;
  final StepStatus status;

  const ProcessingStepTile({
    super.key,
    required this.title,
    required this.leadIcon,
    required this.leadIconBg,
    required this.leadIconColor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          // Left Icon Circle Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: leadIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              leadIcon,
              color: leadIconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14.0),
          // Step Title Label
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: status == StepStatus.pending
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          // Trailing Status Indicator
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case StepStatus.completed:
        return SvgPicture.asset(
          'assets/icons/ok.svg',
          width: 24,
          height: 24,
        );
      case StepStatus.inProgress:
        return const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primaryBlue,
          ),
        );
      case StepStatus.failed:
        return const Icon(
          Icons.cancel_rounded,
          color: AppColors.faultRed,
          size: 24,
        );
      case StepStatus.pending:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFCBD5E1),
              width: 2.0,
            ),
          ),
        );
    }
  }
}
