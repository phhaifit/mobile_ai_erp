import 'package:flutter/material.dart';

class PrintLabelScreen extends StatefulWidget {
  @override
  State<PrintLabelScreen> createState() => _PrintLabelScreenState();
}

class _PrintLabelScreenState extends State<PrintLabelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Label')),
      body: const Center(child: Text('Print Label')),
    );
  }
}
