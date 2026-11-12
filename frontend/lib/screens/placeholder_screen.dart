import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final int tabIndex;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.tipsBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForTab(),
                  size: 64,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                '$title Feature',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'This section is currently under development. Stay tuned for future updates!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: tabIndex),
    );
  }

  IconData _getIconForTab() {
    switch (tabIndex) {
      case 2:
        return Icons.garage_rounded;
      case 3:
        return Icons.warning_amber_rounded;
      case 4:
        return Icons.person_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
