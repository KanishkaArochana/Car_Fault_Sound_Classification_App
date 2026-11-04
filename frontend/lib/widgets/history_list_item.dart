import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/fault_result.dart';
import '../constants/app_colors.dart';
import '../screens/car_faults_detection_screen/solution_details_screen.dart';

class HistoryListItem extends StatelessWidget {
  final FaultResult result;

  const HistoryListItem({
    super.key,
    required this.result,
  });

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthStr = months[dt.month - 1];
    final dayStr = dt.day.toString();
    final yearStr = dt.year.toString();

    final hour = dt.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayHourStr = displayHour.toString().padLeft(2, '0');
    final displayMinuteStr = dt.minute.toString().padLeft(2, '0');

    return '$monthStr $dayStr, $yearStr  •  $displayHourStr:$displayMinuteStr $period';
  }

  @override
  Widget build(BuildContext context) {
    // Select dynamic status colors and icons depending on severity/type of fault
    Color iconBg;
    Color iconColor;
    String iconAsset;

    final name = result.faultName.toLowerCase();

    if (name.contains('normal') || name.contains('healthy')) {
      iconBg = const Color(0xFFE8F5E9); // Soft green
      iconColor = AppColors.successGreen;
      iconAsset = 'assets/icons/ok.svg';
    } else if (name.contains('low') || name.contains('steering') || name.contains('belt') || name.contains('oil')) {
      iconBg = const Color(0xFFFFFBEB); // Soft orange
      iconColor = AppColors.warningOrange;
      iconAsset = 'assets/icons/uncertain.svg';
    } else {
      iconBg = const Color(0xFFFEE2E2); // Soft red
      iconColor = AppColors.faultRed;
      iconAsset = 'assets/icons/red_engine.svg';
    }

    final percentage = (result.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SolutionDetailsScreen(
                faultName: result.faultName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Left: Status Colored Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // Middle: Fault Title and Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.faultName,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      _formatDateTime(result.timestamp),
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              // Right: Confidence Percentage
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
