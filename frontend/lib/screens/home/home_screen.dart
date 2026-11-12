import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/my_car_card.dart';
import '../../widgets/primary_button.dart';
import '../car_faults_detection_screen/recording_screen.dart';
import '../car_faults_detection_screen/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Stack (Blue top + Overlapping Car Card)
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Blue background header
                Container(
                  width: double.infinity,
                  height: 230,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar (Menu & Title & Notification Bell)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Menu tapped')),
                                  );
                                },
                              ),
                              const Text(
                                'Home Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 48), // Spacer to balance menu button
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          // User Greeting
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Hello, John 👋',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    'Good to see you!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              // Notification Bell Icon with Badge background
                              InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Notifications')),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Overlapping My Car Card
                Positioned(
                  bottom: -60,
                  left: 20,
                  right: 20,
                  child: MyCarCard(
                    onManagePressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manage Vehicles')),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Grid space offset
            const SizedBox(height: 80.0),

            // Grid of 6 features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.85,
                children: [
                  _buildGridItem(
                    title: 'OBD Code Lookup',
                    assetPath: 'assets/icons/engine_blue.svg',
                    isSvg: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OBD Code Lookup'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildGridItem(
                    title: 'DashBoard Symbols',
                    assetPath: 'assets/icons/dashbord.png',
                    isSvg: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dashboard Symbols'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildGridItem(
                    title: 'Sound Detection',
                    assetPath: 'assets/icons/sound.svg',
                    isSvg: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecordingScreen()),
                      );
                    },
                  ),
                  _buildGridItem(
                    title: 'Fault History',
                    assetPath: 'assets/icons/fault_history.svg',
                    isSvg: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  _buildGridItem(
                    title: 'Nearby Garages',
                    assetPath: 'assets/icons/car-garage-icon.svg',
                    isSvg: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nearby Garages')),
                      );
                    },
                  ),
                  _buildGridItem(
                    title: 'Emergency Mode',
                    assetPath: 'assets/icons/emergency.svg',
                    isSvg: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Emergency Mode')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20.0),

            // + Add New Vehicle Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: PrimaryButton(
                text: 'Add New Vehicle',
                iconPath: 'assets/icons/plus.svg',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Vehicle feature'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32.0),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildGridItem({
    required String title,
    required String assetPath,
    required bool isSvg,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color.fromARGB(20, 158, 158, 158),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(4, 0, 0, 0),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                SizedBox(
                  width: 36,
                  height: 36,
                  child: isSvg
                      ? SvgPicture.asset(
                          assetPath,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 10.0),
                // Text
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
