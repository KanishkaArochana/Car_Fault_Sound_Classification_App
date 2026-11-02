import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SolutionStepTile extends StatelessWidget {
  final int stepNumber;
  final String stepText;

  const SolutionStepTile({
    super.key,
    required this.stepNumber,
    required this.stepText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft pink circle containing step number
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2.0),
            decoration: const BoxDecoration(
              color: AppColors.stopButtonBg, // soft pink
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.stopButtonRed, // red number
                ),
              ),
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              stepText,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
