import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../res/fonts/font_resources.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomInputField({
    Key? key,
    required this.label,
    this.hintText,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: R.styles.body(
            size: 14,
            weight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword ? _obscureText : false,
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusMedium,
              ),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          style: R.styles.body(
            size: 16,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
