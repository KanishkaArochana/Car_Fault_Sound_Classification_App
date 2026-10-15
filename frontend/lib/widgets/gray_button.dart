import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GrayButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? iconPath;

  const GrayButton({
    super.key,
    this.text = 'How It Works',
    required this.onPressed,
    this.iconPath = 'assets/icons/about.svg',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAFC),
          foregroundColor: const Color(0xFF1E293B),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.5,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (iconPath != null) ...[
              SvgPicture.asset(
                iconPath!,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1E293B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 10.0),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
