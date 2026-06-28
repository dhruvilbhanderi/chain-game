// lib/app/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, color: AppColors.textHint, size: 20),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textHint,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
