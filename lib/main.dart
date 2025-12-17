import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:time_gem/ui/blocs/calendar_bloc/calendar_bloc.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:time_gem/data/services/local_calendar_service.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_bloc.dart';
import 'package:time_gem/ui/blocs/task_bloc/task_event.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:time_gem/firebase_options.dart';

import 'package:time_gem/data/services/google_calendar_service.dart';
import 'package:time_gem/data/services/task_service.dart';
import 'package:time_gem/data/services/gemini_ai_service.dart';
import 'package:time_gem/ui/theme/app_theme.dart';
import 'package:time_gem/ui/blocs/session_bloc/session_bloc.dart';
import 'package:time_gem/ui/blocs/session_bloc/session_event.dart';

import 'package:time_gem/data/services/storage_service.dart';
import 'package:time_gem/ui/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.init(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            title: 'time_gem',
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final storageService = snapshot.data!;

        final localCalendarService = LocalCalendarService(DatabaseHelper());
        final taskService = TaskService();

        final googleCalendarRepository = GoogleCalendarService(
          googleSignIn: GoogleSignIn(
            scopes: [
              'https://www.googleapis.com/auth/calendar.readonly',
              'https://www.googleapis.com/auth/calendar.events',
            ],
          ),
        );

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SessionBloc(
                storageService: storageService,
                googleCalendarService: googleCalendarRepository,
              )..add(AppStarted()),
            ),
            BlocProvider(
              create: (context) => CalendarBloc(
                googleCalendarRepository: googleCalendarRepository,
                localCalendarService: localCalendarService,
                taskService: taskService,
              ),
            ),
            BlocProvider(
              create: (context) => TaskBloc(
                taskService: taskService,
                aiService: GeminiAIService(
                  googleCalendarRepository: googleCalendarRepository,
                ),
                storageService: storageService,
              )..add(LoadTasks()),
            ),
          ],
          child: CalendarControllerProvider(
            controller: EventController(),
            child: MaterialApp(
              title: 'time_gem',
              theme: AppTheme.lightTheme,
              home: const SplashScreen(),
            ),
          ),
        );
      },
    );
  }
}
