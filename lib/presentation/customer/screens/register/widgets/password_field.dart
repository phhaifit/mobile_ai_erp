import 'package:flutter/material.dart';

/// PasswordField - Reusable secure password input field
/// Provides visibility toggle and password strength indicators
class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String labelText;
  final String? hintText;
  final EdgeInsets contentPadding;
  final TextInputAction textInputAction;

  const PasswordField({
    Key? key,
    this.controller,
    this.validator,
    required this.labelText,
    this.hintText,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.textInputAction = TextInputAction.next,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: widget.contentPadding,
      ),
      validator: widget.validator,
    );
  }
}
