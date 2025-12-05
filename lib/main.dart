import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_gem/calendar_bloc/calendar_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:time_gem/local_calendar/local_calendar_service.dart';
import 'package:time_gem/task_bloc/task_bloc.dart';
import 'package:time_gem/task_bloc/task_event.dart';
import 'package:time_gem/ui/screens/welcome/welcome_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:time_gem/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LocalCalendarService localCalendarService =
        LocalCalendarService(DatabaseHelper());

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CalendarBloc(
            googleSignIn: GoogleSignIn(
              scopes: [
                'https://www.googleapis.com/auth/calendar.readonly',
                'https://www.googleapis.com/auth/calendar.events',
              ],
            ),
            localCalendarService: localCalendarService,
          ),
        ),
        BlocProvider(
          create: (context) => TaskBloc()..add(LoadTasks()),
        ),
      ],
      child: CalendarControllerProvider(
        controller: EventController(),
        child: MaterialApp(
          title: 'time_gem',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const WelcomeScreen(),
        ),
      ),
    );
  }
}
