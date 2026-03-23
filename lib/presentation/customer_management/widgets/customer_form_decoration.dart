import 'package:flutter/material.dart';

const TextStyle _customerFormErrorStyle = TextStyle(
  overflow: TextOverflow.visible,
  height: 1.25,
);

const TextStyle _customerFormHelperStyle = TextStyle(
  overflow: TextOverflow.visible,
  height: 1.25,
);

InputDecoration customerFormDecoration({
  required String labelText,
  String? hintText,
  String? helperText,
  String? errorText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    helperText: helperText,
    helperMaxLines: 3,
    helperStyle: _customerFormHelperStyle,
    border: const OutlineInputBorder(),
    errorText: errorText,
    errorMaxLines: 4,
    errorStyle: _customerFormErrorStyle,
  );
}
