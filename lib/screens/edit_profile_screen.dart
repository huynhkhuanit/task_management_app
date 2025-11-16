import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_buttons.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;

  const EditProfileScreen({
    Key? key,
    this.initialName = 'Lê Huỳnh Đức',
    this.initialEmail = 'lehuynhduc@email.com',
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thay đổi'),
        ),
      );
      Navigator.of(context).pop();
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

                // Email Field
                CustomInputField(
                  label: 'Email',
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'nguyenvana@email.com',
                  fillColor: AppColors.greyLight,
                ),

                const SizedBox(height: AppDimensions.paddingXLarge * 2),

                // Save Button
                PrimaryButton(
                  text: 'Lưu Thay Đổi',
                  onPressed: _handleSave,
                ),

                const SizedBox(height: AppDimensions.paddingMedium),

                // Cancel Button
                SecondaryButton(
                  text: 'Hủy',
                  onPressed: _handleCancel,
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

