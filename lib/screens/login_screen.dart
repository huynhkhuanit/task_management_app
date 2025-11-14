import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  void _handleGoogleSignIn() {
    // TODO: Implement Google sign in logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập với Google...')),
    );
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _handleSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
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
                // Email input
                CustomInputField(
                  label: 'Email',
                  hintText: 'Nhập email của bạn',
                  controller: _emailController,
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
                // Password input
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
                const SizedBox(height: AppDimensions.paddingXLarge),
                // Sign in button
                PrimaryButton(
                  text: 'Đăng nhập',
                  onPressed: _handleSignIn,
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
