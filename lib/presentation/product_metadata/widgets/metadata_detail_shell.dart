import 'package:flutter/material.dart';

class MetadataDetailShell extends StatelessWidget {
  const MetadataDetailShell({
    super.key,
    required this.title,
    required this.hasChanged,
    required this.body,
    this.actions,
  });

  final String title;
  final bool hasChanged;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(hasChanged),
        ),
        actions: actions,
      ),
      body: body,
    );
  }
}
