import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditProfileScreen({
    Key? key,
    this.initialName = '',
    this.initialEmail = '',
    this.initialPhone = '',
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _profileService.updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
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

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleChangeAvatar() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng thay đổi ảnh đại diện'),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập tên';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty && value.length < 10) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Chỉnh Sửa Hồ Sơ',
          style: R.styles.heading2(
            color: AppColors.black,
            weight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Avatar Section
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE5D4), // Light orange
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 70,
                              color: AppColors.black,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _handleChangeAvatar,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),

                      // Name Field
                      CustomInputField(
                        label: 'Tên',
                        controller: _nameController,
                        validator: _validateName,
                        hintText: 'Nguyễn Văn A',
                        fillColor: AppColors.greyLight,
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Email Field (read-only, cannot change)
                      CustomInputField(
                        label: 'Email',
                        controller: _emailController,
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'nguyenvana@email.com',
                        fillColor: AppColors.greyLight,
                      ),

                      const SizedBox(height: AppDimensions.paddingLarge),

                      // Phone Field
                      CustomInputField(
                        label: 'Số điện thoại',
                        controller: _phoneController,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                        hintText: '0912345678',
                        fillColor: AppColors.greyLight,
                      ),

                      const SizedBox(height: AppDimensions.paddingXLarge),
                    ],
                  ),
                ),
              ),

              // Footer Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.greyLight,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          minimumSize: const Size(0, 44),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingSmall,
                          ),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusMedium,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isLoading ? 'Đang lưu...' : 'Lưu Thay Đổi',
                          style: R.styles.body(
                            size: 16,
                            weight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
