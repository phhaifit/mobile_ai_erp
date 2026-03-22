import 'package:flutter/material.dart';

Color? tryParseHexColor(String? value) {
  if (value == null) {
    return null;
  }

  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length != 6) {
    return null;
  }

  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) {
    return null;
  }

  return Color(0xFF000000 | parsed);
}

String formatHexColor(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color readableForegroundFor(Color background) {
  return background.computeLuminance() > 0.6 ? Colors.black87 : Colors.white;
}

Color softenedColor(Color color, {double amount = 0.72}) {
  return Color.lerp(color, Colors.white, amount) ?? color;
}
