import 'package:flutter/material.dart';

class CmsPageListScreen extends StatelessWidget {
  const CmsPageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMS Pages'),
      ),
      body: const Center(
        child: Text('CMS Page List'),
      ),
    );
  }
}
