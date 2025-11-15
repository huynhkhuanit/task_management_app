import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../utils/navigation_helper.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() {
    _animationController.forward().then((_) {
      // Đợi thêm một chút để người dùng thấy logo
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          NavigationHelper.pushReplacementSlideTransition(
            context,
            const OnboardingScreen(),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4FD1C7), // Teal gradient start
              const Color(0xFF319795), // Teal gradient end
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                R.drawables.logo,
                width: 240,
                height: 240,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback nếu không load được logo
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 120,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

