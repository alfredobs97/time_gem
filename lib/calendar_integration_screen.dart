import 'package:flutter/material.dart';

class CalendarIntegrationScreen extends StatelessWidget {
  const CalendarIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Calendar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Integrate with Google Calendar for the best experience.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Google Calendar connection logic
                print('Connect Google Calendar');
              },
              child: const Text('Connect Google Calendar'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // TODO: Implement navigation to main app with local calendar
                print('Continue without connecting');
              },
              child: const Text('Continue without connecting'),
            ),
          ],
        ),
      ),
    );
  }
}
