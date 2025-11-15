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
    return SizedBox(
      width: 40,
      height: 38,
      child: Center(
        child: ClipRect(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            scale: isSelected ? 1.15 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 38 : 24,
              height: isSelected ? 38 : 24,
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.white,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 72,
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.grey,
              elevation: 0,
              iconSize: 24,
              selectedFontSize: 13,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
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
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 4;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: currentIndex * tabWidth,
                      bottom: 0,
                      width: tabWidth,
                      height: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
