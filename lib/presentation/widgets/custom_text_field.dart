import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1.5,
            color: theme.dividerColor.withOpacity(.3),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(width: 2, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
