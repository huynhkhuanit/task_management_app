import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/onboarding_model.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/onboarding_page_indicator.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Quản lý công việc',
      description:
          'Dễ dàng tạo và sắp xếp tất cả các công việc của bạn ở một nơi để luôn hoàn thành tốt công việc.',
      imagePath: R.drawables.onboarding_1,
      backgroundColor: const Color(0xFFD4A574),
    ),
    OnboardingItem(
      title: 'Theo dõi tiến độ',
      description:
          'Xem rõ ràng tiến độ các công việc của bạn với biểu đồ và thống kê chi tiết hàng ngày.',
      imagePath: R.drawables.onboarding_2,
      backgroundColor: const Color(0xFFC9A876),
    ),
    OnboardingItem(
      title: 'Nhận thông báo',
      description:
          'Nhận thông báo kịp thời để không bao giờ quên các công việc quan trọng của bạn.',
      imagePath: R.drawables.onboarding_3,
      backgroundColor: const Color(0xFFB9985E),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: Stack(
        children: [
          // PageView for onboarding pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: onboardingItems.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                item: onboardingItems[index],
              );
            },
          ),
          // Skip button at top right
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: GestureDetector(
                  onTap: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: R.styles.body(
                      size: 14,
                      weight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom navigation area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.onboardingBackground,
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator
                  OnboardingPageIndicator(
                    currentIndex: _currentIndex,
                    totalPages: onboardingItems.length,
                  ),
                  const SizedBox(height: AppDimensions.paddingXLarge),
                  // Primary button (Next/Get Started)
                  PrimaryButton(
                    text: _currentIndex == onboardingItems.length - 1
                        ? 'Bắt đầu'
                        : 'Tiếp theo',
                    onPressed: _nextPage,
                  ),
                  if (_currentIndex < onboardingItems.length - 1) ...[
                    const SizedBox(height: AppDimensions.paddingMedium),
                    // Skip button (only shown when not on last page)
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: const Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
