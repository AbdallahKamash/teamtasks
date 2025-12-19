import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Alexandria'),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Settings Screen Wrapper',
          style: TextStyle(fontFamily: 'Alexandria', fontSize: 18),
        ),
      ),
    );
  }
}
