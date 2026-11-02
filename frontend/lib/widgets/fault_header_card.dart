import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaultHeaderCard extends StatelessWidget {
  final String faultName;
  final String iconAsset;
  final Color backgroundColor;
  final Color contentColor;

  const FaultHeaderCard({
    super.key,
    required this.faultName,
    required this.iconAsset,
    required this.backgroundColor,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Svg Icon from assets
          SvgPicture.asset(
            iconAsset,
            width: 32,
            height: 24,
            colorFilter: ColorFilter.mode(
              contentColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              faultName,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: contentColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
