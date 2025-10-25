import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';

class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('time_gem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<CalendarBloc>().add(SignOutRequested());
              // Popping the screen is handled by the BlocConsumer in the integration screen
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CalendarEventsLoaded) {
            return ListView.builder(
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.events[index]),
                );
              },
            );
          } else if (state is CalendarAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment.center,
                children: [
                  Text('Welcome, ${state.userName}!'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalendarBloc>().add(FetchCalendarEvents());
                    },
                    child: const Text('Fetch Calendar Events'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('Welcome to the Main App!'),
          );
        },
      ),
    );
  }
}
