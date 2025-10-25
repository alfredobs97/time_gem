import 'package:flutter/material.dart';
import 'package:time_gem/calendar_integration_screen.dart';

class AppGoalScreen extends StatelessWidget {
  const AppGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How it Works'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(Icons.lightbulb_outline, size: 64, color: Colors.amber),
            const SizedBox(height: 24),
            const Text(
              'Meet Your AI Planning Assistant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CalendarIntegrationScreen(),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
