import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendRecoveryLink() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement send recovery link logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi liên kết khôi phục!')),
      );
    }
  }

  void _handleBackToLogin() {
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
                // Checkmark icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusLarge,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Title
                Text(
                  'Quên mật khẩu',
                  textAlign: TextAlign.center,
                  style: R.styles.heading1(
                    color: AppColors.black,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  child: Text(
                    'Vui lòng nhập email đã đăng ký. Chúng tôi sẽ gửi một liên kết để bạn đặt lại mật khẩu.',
                    textAlign: TextAlign.center,
                    style: R.styles.body(
                      size: 16,
                      color: AppColors.grey,
                    ),
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
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Send recovery link button
                PrimaryButton(
                  text: 'Gửi liên kết khôi phục',
                  onPressed: _handleSendRecoveryLink,
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Back to login link
                GestureDetector(
                  onTap: _handleBackToLogin,
                  child: Text(
                    'Quay lại Đăng nhập',
                    style: R.styles.body(
                      size: 16,
                      color: AppColors.grey,
                      weight: FontWeight.w500,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
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

