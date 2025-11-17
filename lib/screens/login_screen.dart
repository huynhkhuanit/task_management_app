import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';
import '../utils/navigation_helper.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _usePhoneLogin = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _identifierController.text.trim();
      
      if (!_usePhoneLogin) {
        // Đăng nhập bằng email và password
        await _authService.signIn(
          email: email,
          password: _passwordController.text,
        );

        if (mounted) {
          // Đăng nhập thành công, điều hướng đến home screen
          NavigationHelper.pushReplacementSlideTransition(
            context,
            const HomeScreen(),
          );
        }
      } else {
        // Đăng nhập bằng email với OTP
        await _authService.sendLoginOTP(email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi mã OTP đến email của bạn'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to OTP verification screen
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              NavigationHelper.pushReplacementSlideTransition(
                context,
                OTPVerificationScreen(
                  email: email,
                  isSignUp: false,
                ),
              );
            }
          });
        }
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang chuyển hướng đến Google...'),
          ),
        );
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

  void _handleForgotPassword() {
    NavigationHelper.pushSlideTransition(
      context,
      const ForgotPasswordScreen(),
    );
  }

  void _handleSignUp() {
    NavigationHelper.pushSlideTransition(
      context,
      const SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Welcome title
                Text(
                  'Chào mừng trở lại!',
                  textAlign: TextAlign.center,
                  style: R.styles.heading1(
                    color: AppColors.black,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),
                // Subtitle
                Text(
                  'Đăng nhập để tiếp tục vào tài khoản của bạn.',
                  textAlign: TextAlign.center,
                  style: R.styles.body(
                    size: 16,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Login method toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _usePhoneLogin = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: !_usePhoneLogin
                                ? AppColors.primary
                                : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          child: Text(
                            'Email + Mật khẩu',
                            textAlign: TextAlign.center,
                            style: R.styles.body(
                              size: 14,
                              color: !_usePhoneLogin
                                  ? AppColors.white
                                  : AppColors.grey,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _usePhoneLogin = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: _usePhoneLogin
                                ? AppColors.primary
                                : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          child: Text(
                            'Email + OTP',
                            textAlign: TextAlign.center,
                            style: R.styles.body(
                              size: 14,
                              color: _usePhoneLogin
                                  ? AppColors.white
                                  : AppColors.grey,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Email input (always show)
                CustomInputField(
                  label: 'Email',
                  hintText: 'Nhập email của bạn',
                  controller: _identifierController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Password input (only show for password login)
                if (!_usePhoneLogin) ...[
                  CustomInputField(
                    label: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu của bạn',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Quên mật khẩu?',
                        style: R.styles.body(
                          size: 14,
                          weight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.paddingXLarge),
                // Sign in button
                PrimaryButton(
                  text: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                  isLoading: _isLoading,
                  onPressed: () {
                    _handleSignIn();
                  },
                ),
                const SizedBox(height: AppDimensions.paddingXLarge),
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.greyLight,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                      ),
                      child: Text(
                        'hoặc',
                        style: R.styles.body(
                          size: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.greyLight,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXLarge),
                // Google sign in button
                _GoogleSignInButton(
                  onPressed: _handleGoogleSignIn,
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: R.styles.body(
                        size: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleSignUp,
                      child: Text(
                        'Đăng ký',
                        style: R.styles.body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google icon - Simple colored G
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    // Background circle with Google colors
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4285F4), // Blue
                            Color(0xFF34A853), // Green
                          ],
                        ),
                      ),
                    ),
                    // G letter
                    Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMedium),
              Text(
                'Đăng nhập với Google',
                style: R.styles.body(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
