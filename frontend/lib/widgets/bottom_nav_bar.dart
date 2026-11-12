import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/car_faults_detection_screen/history_screen.dart';
import '../screens/placeholder_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetScreen;
    switch (index) {
      case 0:
        targetScreen = const HomeScreen();
        break;
      case 1:
        targetScreen = const HistoryScreen();
        break;
      case 2:
        targetScreen = const PlaceholderScreen(title: 'Garage', tabIndex: 2);
        break;
      case 3:
        targetScreen = const PlaceholderScreen(title: 'Emergency', tabIndex: 3);
        break;
      case 4:
        targetScreen = const PlaceholderScreen(title: 'Profile', tabIndex: 4);
        break;
      default:
        targetScreen = const HomeScreen();
        break;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabTapped(context, index),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 24),
            activeIcon: Icon(Icons.home_rounded, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_rounded, size: 24),
            activeIcon: Icon(Icons.access_time_rounded, size: 24),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_rounded, size: 24),
            activeIcon: Icon(Icons.directions_car_rounded, size: 24),
            label: 'Garage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded, size: 24),
            activeIcon: Icon(Icons.notifications_active_rounded, size: 24),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded, size: 24),
            activeIcon: Icon(Icons.person_rounded, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
