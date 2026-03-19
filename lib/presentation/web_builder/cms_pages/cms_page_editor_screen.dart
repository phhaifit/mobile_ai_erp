import 'package:flutter/material.dart';

class CmsPageEditorScreen extends StatelessWidget {
  const CmsPageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
      ),
      body: const Center(
        child: Text('CMS Page Editor'),
      ),
    );
  }
}
