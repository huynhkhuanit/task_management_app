import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_buttons.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';
import 'home_screen.dart';
import 'set_password_screen.dart';

// Custom TextInputFormatter để detect backspace khi ô trống
class _BackspaceFormatter extends TextInputFormatter {
  final VoidCallback onBackspace;
  final int fieldIndex;

  _BackspaceFormatter({
    required this.onBackspace,
    required this.fieldIndex,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Nếu ô đã trống và người dùng nhấn backspace (text vẫn trống)
    // Điều này có nghĩa là người dùng nhấn backspace trên ô trống
    if (oldValue.text.isEmpty &&
        newValue.text.isEmpty &&
        oldValue.selection.baseOffset == 0 &&
        newValue.selection.baseOffset == 0) {
      // Gọi callback để xử lý backspace
      Future.microtask(() => onBackspace());
    }
    return newValue;
  }
}

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final bool isSignUp;
  final String? fullName;

  const OTPVerificationScreen({
    Key? key,
    required this.email,
    this.isSignUp = false,
    this.fullName,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _authService = AuthService();
  // Supabase gửi mã OTP 8 số, cần nhập đủ 8 số để verify
  final List<TextEditingController> _controllers = List.generate(
    8,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    8,
    (index) => FocusNode(),
  );
  final List<bool> _focusStates = List.generate(8, (_) => false);
  bool _isLoading = false;
  int _countdown = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Add listeners to focus nodes for real-time UI updates
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _focusStates[i] = _focusNodes[i].hasFocus;
        });
      });
    }
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
      // Người dùng nhập số mới
      _controllers[index].text = value;
      if (index < 7) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOTP();
      }
    } else if (value.isEmpty) {
      // Người dùng xóa số (nhấn backspace/delete)
      _controllers[index].clear();
      // Luôn chuyển focus về ô trước (nếu có)
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ 8 số'),
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
        email: widget.email,
        token: otp,
      );

      if (mounted) {
        if (widget.isSignUp) {
          // Nếu là đăng ký, chuyển đến màn hình tạo mật khẩu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xác minh OTP thành công!'),
              backgroundColor: AppColors.success,
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              NavigationHelper.pushReplacementSlideTransition(
                context,
                SetPasswordScreen(email: widget.email),
              );
            }
          });
        } else {
          // Nếu là đăng nhập, chuyển đến màn hình chính
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: AppColors.success,
            ),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              NavigationHelper.pushReplacementSlideTransition(
                context,
                const HomeScreen(),
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
        await _authService.signUpWithEmailOTP(
          email: widget.email,
          fullName: widget.fullName!,
        );
      } else {
        await _authService.sendLoginOTP(widget.email);
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
                'Xác nhận email',
                textAlign: TextAlign.center,
                style: R.styles.heading1(
                  color: AppColors.black,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              // Subtitle
              Text(
                'Nhập mã 8 số đã được gửi đến\n${widget.email}',
                textAlign: TextAlign.center,
                style: R.styles.body(
                  size: 16,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXLarge * 2),
              // OTP Input Fields
              // Wrap Row in Flexible/Expanded to prevent overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate available width and spacing
                  final availableWidth = constraints.maxWidth;
                  final spacing = 8.0; // Spacing hợp lý giữa các ô
                  final fieldWidth = (availableWidth - (spacing * 7)) / 8;
                  // Kích thước tối thiểu để đảm bảo text hiển thị tốt
                  final fieldSize = fieldWidth < 42 ? 42.0 : fieldWidth;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(8, (index) {
                      return ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controllers[index],
                        builder: (context, value, child) {
                          final hasFocus = _focusStates[index];
                          final hasValue = value.text.isNotEmpty;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: fieldSize,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusMedium,
                              ),
                              border: Border.all(
                                color: hasFocus
                                    ? AppColors.primary
                                    : hasValue
                                        ? AppColors.primary.withOpacity(0.3)
                                        : AppColors.greyLight,
                                width: hasFocus ? 2 : 1.5,
                              ),
                              boxShadow: hasFocus
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : hasValue
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                            ),
                            child: Focus(
                              onKeyEvent: (node, event) {
                                // Detect backspace key khi ô trống
                                if (event is KeyDownEvent &&
                                    (event.logicalKey ==
                                            LogicalKeyboardKey.backspace ||
                                        event.logicalKey ==
                                            LogicalKeyboardKey.delete)) {
                                  if (_controllers[index].text.isEmpty &&
                                      index > 0) {
                                    // Chuyển focus về ô trước và xóa số trong ô đó
                                    _focusNodes[index - 1].requestFocus();
                                    Future.delayed(
                                        const Duration(milliseconds: 50), () {
                                      if (mounted &&
                                          _focusNodes[index - 1].hasFocus) {
                                        _controllers[index - 1].clear();
                                      }
                                    });
                                    return KeyEventResult.handled;
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                              child: Center(
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: R.styles.body(
                                    color: AppColors.black,
                                    size: 24, // Font size lớn để dễ đọc
                                    weight: FontWeight.w700,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: false,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                  onChanged: (value) =>
                                      _onChanged(index, value),
                                  onTap: () {
                                    // Khi tap vào ô, select all text để có thể xóa dễ dàng
                                    _controllers[index].selection =
                                        TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          _controllers[index].text.length,
                                    );
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  );
                },
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
                      _countdown > 0 ? 'Gửi lại sau ($_countdown)' : 'Gửi lại',
                      style: R.styles.body(
                        size: 14,
                        color:
                            _countdown > 0 ? AppColors.grey : AppColors.primary,
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
