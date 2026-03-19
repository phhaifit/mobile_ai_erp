import 'package:flutter/material.dart';

class ThemeListScreen extends StatelessWidget {
  const ThemeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
      ),
      body: const Center(
        child: Text('Theme List'),
      ),
    );
  }
}
