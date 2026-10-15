import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class CheckItemTile extends StatelessWidget {
  final String checkItem;

  const CheckItemTile({
    super.key,
    required this.checkItem,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Green check mark icon from assets
          SvgPicture.asset(
            'assets/icons/ok.svg',
            width: 22,
            height: 22,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              checkItem,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
