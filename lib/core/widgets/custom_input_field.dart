import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.overline),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.titleSm.copyWith(color: AppColors.cyan),
          cursorColor: AppColors.cyan,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
