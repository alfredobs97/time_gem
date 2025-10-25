import 'package:flutter/material.dart';
import 'package:time_gem/main_app_screen.dart';

class CalendarIntegrationScreen extends StatelessWidget {
  const CalendarIntegrationScreen({super.key});

  void _showLocalCalendarWarning(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Local Calendar Usage',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'You can use time_gem with a local on-device calendar. ' +
                'However, integrating with your Google Calendar will provide a richer ' +
                'experience with AI-powered scheduling based on your existing events.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss bottom sheet
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const MainAppScreen(),
                      ),
                    ); // Navigate to main app
                  },
                  child: const Text('Continue with Local Calendar'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss bottom sheet
                  },
                  child: const Text('Go Back'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                _showLocalCalendarWarning(context);
              },
              child: const Text('Continue without connecting'),
            ),
          ],
        ),
      ),
    );
  }
}
