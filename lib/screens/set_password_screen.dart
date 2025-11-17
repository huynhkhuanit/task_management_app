import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_buttons.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';
import 'home_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String email;

  const SetPasswordScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Set password cho user sau khi verify OTP
      await _authService.updatePassword(_passwordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo mật khẩu thành công!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to home screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            NavigationHelper.pushReplacementSlideTransition(
              context,
              const HomeScreen(),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != _passwordController.text) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.paddingXLarge),
                // Title
                Text(
                  'Tạo mật khẩu',
                  textAlign: TextAlign.center,
                  style: R.styles.heading1(
                    color: AppColors.black,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                // Subtitle
                Text(
                  'Vui lòng tạo mật khẩu để sử dụng cho lần đăng nhập sau',
                  textAlign: TextAlign.center,
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mật khẩu',
                      style: R.styles.body(
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    TextFormField(
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        hintStyle: R.styles.body(
                          size: 16,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.greyLight,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.greyLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xác nhận mật khẩu',
                      style: R.styles.body(
                        size: 14,
                        weight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    TextFormField(
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                      obscureText: _obscureConfirmPassword,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu',
                        hintStyle: R.styles.body(
                          size: 16,
                          color: AppColors.grey,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingMedium,
                          vertical: AppDimensions.paddingMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.greyLight,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.greyLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      style: R.styles.body(
                        size: 16,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Set Password Button
                PrimaryButton(
                  text: _isLoading ? 'Đang tạo...' : 'Tạo mật khẩu',
                  isLoading: _isLoading,
                  onPressed: _handleSetPassword,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
