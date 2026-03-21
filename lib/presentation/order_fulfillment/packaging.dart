import 'package:flutter/material.dart';

class PackagingScreen extends StatefulWidget {
  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packaging')),
      body: const Center(child: Text('Packaging')),
    );
  }
}
