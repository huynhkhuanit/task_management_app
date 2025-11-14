import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  Widget _buildIcon(IconData icon, bool isSelected, int index) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      scale: isSelected ? 1.15 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isSelected ? 40 : 24,
        height: isSelected ? 40 : 24,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.grey,
          size: isSelected ? 22 : 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        elevation: 0,
        selectedLabelStyle: R.styles.body(
          size: 13,
          weight: FontWeight.w600,
        ),
        unselectedLabelStyle: R.styles.body(
          size: 12,
          weight: FontWeight.w400,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, false, 0),
            activeIcon: _buildIcon(Icons.home, true, 0),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.check_circle_outline, false, 1),
            activeIcon: _buildIcon(Icons.check_circle_outline, true, 1),
            label: 'Công việc',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.bar_chart, false, 2),
            activeIcon: _buildIcon(Icons.bar_chart, true, 2),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, false, 3),
            activeIcon: _buildIcon(Icons.person, true, 3),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
