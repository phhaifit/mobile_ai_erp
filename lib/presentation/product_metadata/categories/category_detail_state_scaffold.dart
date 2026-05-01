import 'package:flutter/material.dart';

class CategoryDetailStateScaffold extends StatelessWidget {
  const CategoryDetailStateScaffold({
    super.key,
    required this.hasChanged,
    required this.body,
  });

  final bool hasChanged;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category detail'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop(hasChanged)),
      ),
      body: body,
    );
  }
}
