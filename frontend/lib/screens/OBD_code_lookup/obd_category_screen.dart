import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'obd_codes_list_screen.dart';

class ObdCategoryScreen extends StatelessWidget {
  const ObdCategoryScreen({super.key});

  String _getJsonFileName(String title) {
    switch (title.toLowerCase()) {
      case 'powertrain':
        return 'P_codes.json';
      case 'body':
        return 'B_codes.json';
      case 'chassis':
        return 'C_codes.json';
      case 'network':
        return 'U_codes.json';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'OBD Categories',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a category to search',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24.0),
              _buildCategoryCard(
                context,
                title: 'Powertrain',
                imagePath: 'assets/images/OBD Images/Powetrain.png',
              ),
              const SizedBox(height: 16.0),
              _buildCategoryCard(
                context,
                title: 'Body',
                imagePath: 'assets/images/OBD Images/Body.png',
              ),
              const SizedBox(height: 16.0),
              _buildCategoryCard(
                context,
                title: 'Chassis',
                imagePath: 'assets/images/OBD Images/Chassis.png',
              ),
              const SizedBox(height: 16.0),
              _buildCategoryCard(
                context,
                title: 'Network',
                imagePath: 'assets/images/OBD Images/Network.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required String title, required String imagePath}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObdCodesListScreen(
                  categoryName: title,
                  jsonFileName: _getJsonFileName(title),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    imagePath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
