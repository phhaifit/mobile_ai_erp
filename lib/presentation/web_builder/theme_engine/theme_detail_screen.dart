import 'package:flutter/material.dart';

class ThemeDetailScreen extends StatelessWidget {
  const ThemeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Preview'),
      ),
      body: const Center(
        child: Text('Theme Detail'),
      ),
    );
  }
}
