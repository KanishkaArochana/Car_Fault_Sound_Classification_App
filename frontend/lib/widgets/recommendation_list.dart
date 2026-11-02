import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RecommendationList extends StatelessWidget {
  final List<String> recommendations;
  final String title;
  final Color? firstLetterColor;

  const RecommendationList({
    super.key,
    required this.recommendations,
    this.title = 'Recommended Solution',
    this.firstLetterColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with customized styling if needed
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title.substring(0, 1),
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: firstLetterColor ?? AppColors.faultRed, // First letter color config
                ),
              ),
              TextSpan(
                text: title.substring(1),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        // Bullet list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0, left: 4.0, right: 10.0),
                    child: Icon(
                      Icons.circle,
                      size: 6.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendations[index],
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
