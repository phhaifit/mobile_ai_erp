import 'package:flutter/material.dart';

class WebBuilderDashboard extends StatelessWidget {
  const WebBuilderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Builder'),
      ),
      body: const Center(
        child: Text('Web Builder Dashboard'),
      ),
    );
  }
}
