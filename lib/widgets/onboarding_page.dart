import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/onboarding_model.dart';
import '../res/fonts/font_resources.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolvedImagePath = _resolveImagePath(item.imagePath);
    // Ước tính chiều cao bottom navigation area (khoảng 180-220px)
    final bottomNavHeight = 220.0;

    return Container(
      color: AppColors.onboardingBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Image area at the top
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Image.asset(
                  resolvedImagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Content area below image
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: AppDimensions.paddingLarge,
                    right: AppDimensions.paddingLarge,
                    top: AppDimensions.paddingLarge,
                    bottom:
                        bottomNavHeight, // Padding để tránh bị che bởi bottom navigation
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style: R.styles.heading1(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: R.styles.body(
                          size: 16,
                          weight: FontWeight.w400,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveImagePath(String path) {
    if (path.startsWith('lib/')) {
      return path.replaceFirst('lib/', '');
    }
    return path;
  }
}
