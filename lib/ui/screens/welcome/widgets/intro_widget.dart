import 'package:flutter/material.dart';

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lightbulb_outline, size: 64, color: Colors.amber),
        const SizedBox(height: 24),
        Text(
          'Meet Your AI Planning Assistant',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          '1. Create your tasks with priorities and time estimates.\n\n'
          '2. Connect your calendar to see your schedule.\n\n'
          '3. Let our AI agent find the perfect time slots to get your work done!',
          style: TextStyle(fontSize: 16, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
