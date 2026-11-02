import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResultBanner extends StatelessWidget {
  final String title;
  final String iconPath;
  final Color backgroundColor;
  final Color contentColor;

  const ResultBanner({
    super.key,
    required this.title,
    required this.iconPath,
    required this.backgroundColor,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              contentColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: contentColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
