import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Vui lòng đồng ý với Điều khoản Dịch vụ và Chính sách Bảo mật'),
          ),
        );
        return;
      }
      // TODO: Implement sign up logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
    }
  }

  void _handleTermsOfService() {
    // TODO: Navigate to terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Điều khoản Dịch vụ...')),
    );
  }

  void _handlePrivacyPolicy() {
    // TODO: Navigate to privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chính sách Bảo mật...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      appBar: AppBar(
        backgroundColor: AppColors.onboardingBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingLarge),
                // Title
                Center(
                  child: Text(
                    'Tạo tài khoản mới',
                    textAlign: TextAlign.center,
                    style: R.styles.heading1(
                      color: AppColors.black,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Full Name input
                CustomInputField(
                  label: 'Họ và Tên',
                  hintText: 'Nguyễn Văn A',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Email input
                CustomInputField(
                  label: 'Email',
                  hintText: 'example@email.com',
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
                const SizedBox(height: AppDimensions.paddingLarge),
                // Confirm Password input
                CustomInputField(
                  label: 'Xác nhận Mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Terms and Privacy checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: AppColors.white,
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppColors.primary;
                          }
                          return AppColors.white;
                        },
                      ),
                      side: BorderSide(
                        color: AppColors.greyLight,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: RichText(
                          text: TextSpan(
                            style: R.styles.body(
                              size: 14,
                              color: AppColors.black,
                            ),
                            children: [
                              const TextSpan(text: 'Tôi đồng ý với các '),
                              TextSpan(
                                text: 'Điều khoản Dịch vụ',
                                style: R.styles.body(
                                  size: 14,
                                  weight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _handleTermsOfService,
                              ),
                              const TextSpan(text: ' và '),
                              TextSpan(
                                text: 'Chính sách Bảo mật',
                                style: R.styles.body(
                                  size: 14,
                                  weight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _handlePrivacyPolicy,
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingXLarge * 2),
                // Sign up button
                PrimaryButton(
                  text: 'Tạo Tài Khoản',
                  onPressed: _handleSignUp,
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
