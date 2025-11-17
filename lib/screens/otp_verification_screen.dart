import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_buttons.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';
import 'home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isSignUp;
  final String? fullName;

  const OTPVerificationScreen({
    Key? key,
    required this.phone,
    this.isSignUp = false,
    this.fullName,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _authService = AuthService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        return _countdown > 0;
      }
      return false;
    });
  }

  void _onChanged(int index, String value) {
    if (value.length == 1) {
      _controllers[index].text = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ 6 số'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyOTP(
        phone: widget.phone,
        token: otp,
      );

      if (mounted) {
        if (widget.isSignUp) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: AppColors.success,
            ),
          );
        }

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
        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (_countdown > 0) return;

    try {
      if (widget.isSignUp && widget.fullName != null) {
        await _authService.signUpWithPhone(
          phone: widget.phone,
          fullName: widget.fullName!,
        );
      } else {
        await _authService.sendLoginOTP(widget.phone);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi lại mã OTP'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _countdown = 60;
        });
        _startCountdown();
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
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.paddingXLarge),
              // Title
              Text(
                'Xác nhận số điện thoại',
                textAlign: TextAlign.center,
                style: R.styles.heading1(
                  color: AppColors.black,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              // Subtitle
              Text(
                'Nhập mã 6 số đã được gửi đến\n${widget.phone}',
                textAlign: TextAlign.center,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXLarge * 2),
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: R.styles.heading2(
                        color: AppColors.black,
                        weight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.greyLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusMedium,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onChanged(index, value),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.paddingXLarge * 2),
              // Verify Button
              PrimaryButton(
                text: _isLoading ? 'Đang xác nhận...' : 'Xác nhận',
                isLoading: _isLoading,
                onPressed: _verifyOTP,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Không nhận được mã? ',
                    style: R.styles.body(
                      size: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: _countdown > 0 ? null : _resendOTP,
                    child: Text(
                      _countdown > 0
                          ? 'Gửi lại sau ($_countdown)'
                          : 'Gửi lại',
                      style: R.styles.body(
                        size: 14,
                        color: _countdown > 0
                            ? AppColors.grey
                            : AppColors.primary,
                        weight: FontWeight.w600,
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
    );
  }
}

