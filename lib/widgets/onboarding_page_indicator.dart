import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const OnboardingPageIndicator({
    Key? key,
    required this.currentIndex,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Container(
          key: ValueKey<int>(index),
          margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
          ),
          width: currentIndex == index ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color:
                currentIndex == index ? AppColors.primary : AppColors.greyLight,
          ),
        ),
      ),
    );
  }
}
