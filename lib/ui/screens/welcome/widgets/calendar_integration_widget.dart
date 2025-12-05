import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';
import 'package:time_gem/ui/screens/home/home_screen.dart';

class CalendarIntegrationWidget extends StatelessWidget {
  const CalendarIntegrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarBloc, CalendarState>(
      listener: (context, state) {
        if (state is CalendarAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else if (state is CalendarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CalendarInitial) {
          // Handle initial state if needed, or maybe navigate to WelcomeScreen if this was a standalone screen
          // But here it is part of WelcomeScreen, so maybe do nothing or reset
        }
      },
      builder: (context, state) {
        if (state is CalendarLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Integrate with Google Calendar for the best experience.',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<CalendarBloc>().add(SignInWithGoogleRequested());
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
        );
      },
    );
  }

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
                'You can use time_gem with a local on-device calendar. '
                'However, integrating with your Google Calendar will provide a richer '
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
                        builder: (context) => const HomeScreen(),
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
}
