import 'package:flutter/material.dart';

const TextStyle metadataFormErrorStyle = TextStyle(
  overflow: TextOverflow.visible,
  height: 1.25,
);

const TextStyle metadataFormHelperStyle = TextStyle(
  overflow: TextOverflow.visible,
  height: 1.25,
);

InputDecoration metadataFormDecoration({
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
    helperStyle: metadataFormHelperStyle,
    border: const OutlineInputBorder(),
    errorText: errorText,
    errorMaxLines: 4,
    errorStyle: metadataFormErrorStyle,
  );
}
