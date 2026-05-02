import 'package:flutter/material.dart';

/// Secure password input field with visibility toggle and strength indicator
class PasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final bool showStrengthIndicator;
  final bool isConfirmPassword;
  final String? passwordToMatch;
  final InputDecoration? decoration;
  final int minLines;
  final int maxLines;

  const PasswordField({
    Key? key,
    this.label = 'Password',
    this.hintText,
    this.validator,
    this.controller,
    this.onChanged,
    this.showStrengthIndicator = false,
    this.isConfirmPassword = false,
    this.passwordToMatch,
    this.decoration,
    this.minLines = 1,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late bool _obscureText;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _obscureText = true;
  }

  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.grey;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _passwordStrength = 'Weak (too short)';
        _strengthColor = Colors.red;
      });
      return;
    }

    int strengthScore = 0;

    if (password.contains(RegExp(r'[a-z]'))) strengthScore++;
    if (password.contains(RegExp(r'[A-Z]'))) strengthScore++;
    if (password.contains(RegExp(r'[0-9]'))) strengthScore++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strengthScore++;

    String strength;
    Color color;

    if (strengthScore <= 1) {
      strength = 'Weak';
      color = Colors.red;
    } else if (strengthScore == 2) {
      strength = 'Fair';
      color = Colors.orange;
    } else if (strengthScore == 3) {
      strength = 'Good';
      color = Colors.amber;
    } else {
      strength = 'Strong';
      color = Colors.green;
    }

    setState(() {
      _passwordStrength = strength;
      _strengthColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: (value) {
            if (widget.showStrengthIndicator) {
              _updatePasswordStrength(value);
            }
            widget.onChanged?.call(value);
          },
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          decoration: widget.decoration ??
              InputDecoration(
                labelText: widget.label,
                hintText: widget.hintText ?? 'Enter ${widget.label.toLowerCase()}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
        ),
        if (widget.showStrengthIndicator && _passwordStrength.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: _strengthColor == Colors.red
                      ? 0.25
                      : _strengthColor == Colors.orange
                          ? 0.5
                          : _strengthColor == Colors.amber
                              ? 0.75
                              : 1.0,
                  color: _strengthColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _passwordStrength,
                style: TextStyle(
                  color: _strengthColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
