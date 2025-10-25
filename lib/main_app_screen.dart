import 'package:flutter/material.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('time_gem'),
      ),
      body: const Center(
        child: Text('Welcome to the Main App!'),
      ),
    );
  }
}
