import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/ranked_fault_result.dart';

/// A single row in the ranked results list: rank badge, class name, how
/// many of the recorded segments matched it, and its average confidence.
class ClassRankingTile extends StatelessWidget {
  final int rank;
  final ClassRanking ranking;
  final bool isTop;

  const ClassRankingTile({
    super.key,
    required this.rank,
    required this.ranking,
    this.isTop = false,
  });

  Color get _accentColor {
    final name = ranking.faultName.toLowerCase();
    if (name.contains('normal') || name.contains('healthy')) {
      return AppColors.successGreen;
    }
    return isTop ? AppColors.faultRed : AppColors.warningOrange;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (ranking.averageConfidence.clamp(0.0, 1.0) * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: isTop ? _accentColor.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isTop ? _accentColor.withValues(alpha: 0.35) : AppColors.borderLight,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank badge
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: _accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.faultName,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${ranking.occurrences}/${ranking.totalChunks} segments matched',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: ranking.averageConfidence.clamp(0.0, 1.0),
                    minHeight: 6.0,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
