import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';
import '../utils/navigation_helper.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _agreeToTerms = false;
  bool _isLoading = false;
  bool _usePhoneSignUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Vui lòng đồng ý với Điều khoản Dịch vụ và Chính sách Bảo mật'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_usePhoneSignUp) {
        // Đăng ký bằng số điện thoại - gửi OTP
        await _authService.signUpWithPhone(
          phone: _phoneController.text.trim(),
          fullName: _nameController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi mã OTP đến số điện thoại của bạn'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to OTP verification screen
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              NavigationHelper.pushReplacementSlideTransition(
                context,
                OTPVerificationScreen(
                  phone: _phoneController.text.trim(),
                  isSignUp: true,
                  fullName: _nameController.text.trim(),
                ),
              );
            }
          });
        }
      } else {
        // Đăng ký bằng email
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to login screen after successful signup
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              NavigationHelper.pushReplacementSlideTransition(
                context,
                const LoginScreen(),
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

  void _handleTermsOfService() {
    _showTermsDialog();
  }

  void _handlePrivacyPolicy() {
    _showPrivacyDialog();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Điều khoản Dịch vụ',
            style: R.styles.heading2(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Điều khoản Dịch vụ\n\n'
              '1. Chấp nhận điều khoản\n'
              'Bằng việc sử dụng ứng dụng này, bạn đồng ý với các điều khoản và điều kiện sau đây.\n\n'
              '2. Sử dụng dịch vụ\n'
              'Bạn được phép sử dụng ứng dụng để quản lý công việc cá nhân của mình.\n\n'
              '3. Bảo mật thông tin\n'
              'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn theo các tiêu chuẩn bảo mật cao nhất.\n\n'
              '4. Quyền và trách nhiệm\n'
              'Bạn có trách nhiệm bảo mật thông tin đăng nhập và không chia sẻ với người khác.\n\n'
              '5. Thay đổi điều khoản\n'
              'Chúng tôi có quyền thay đổi các điều khoản này và sẽ thông báo cho bạn khi có thay đổi.',
              style: R.styles.body(
                size: 14,
                color: AppColors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: R.styles.body(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chính sách Bảo mật',
            style: R.styles.heading2(
              color: AppColors.black,
              weight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Chính sách Bảo mật\n\n'
              '1. Thu thập thông tin\n'
              'Chúng tôi chỉ thu thập thông tin cần thiết để cung cấp dịch vụ tốt nhất cho bạn.\n\n'
              '2. Sử dụng thông tin\n'
              'Thông tin của bạn được sử dụng để:\n'
              '- Cung cấp và cải thiện dịch vụ\n'
              '- Gửi thông báo quan trọng\n'
              '- Bảo mật tài khoản của bạn\n\n'
              '3. Bảo vệ thông tin\n'
              'Chúng tôi sử dụng các biện pháp bảo mật tiên tiến để bảo vệ thông tin của bạn.\n\n'
              '4. Chia sẻ thông tin\n'
              'Chúng tôi không bán hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba.\n\n'
              '5. Quyền của bạn\n'
              'Bạn có quyền truy cập, chỉnh sửa hoặc xóa thông tin cá nhân của mình bất cứ lúc nào.',
              style: R.styles.body(
                size: 14,
                color: AppColors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: R.styles.body(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
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
                // Sign up method toggle
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _usePhoneSignUp = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: !_usePhoneSignUp
                                ? AppColors.primary
                                : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          child: Text(
                            'Email',
                            textAlign: TextAlign.center,
                            style: R.styles.body(
                              size: 14,
                              color: !_usePhoneSignUp
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
                            _usePhoneSignUp = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          decoration: BoxDecoration(
                            color: _usePhoneSignUp
                                ? AppColors.primary
                                : AppColors.greyLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          child: Text(
                            'Số điện thoại',
                            textAlign: TextAlign.center,
                            style: R.styles.body(
                              size: 14,
                              color: _usePhoneSignUp
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
                // Email input (only show if not using phone signup)
                if (!_usePhoneSignUp)
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
                if (!_usePhoneSignUp)
                  const SizedBox(height: AppDimensions.paddingLarge),
                // Phone input
                CustomInputField(
                  label: 'Số điện thoại',
                  hintText: '0912345678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (_usePhoneSignUp) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      if (value.length < 10) {
                        return 'Số điện thoại không hợp lệ';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingLarge),
                // Password input (only show if using email signup)
                if (!_usePhoneSignUp) ...[
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
                ],
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
                  text: _isLoading ? 'Đang tạo tài khoản...' : 'Tạo Tài Khoản',
                  isLoading: _isLoading,
                  onPressed: () {
                    _handleSignUp();
                  },
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
