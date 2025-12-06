import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:time_gem/data/services/local_calendar_service.dart';
import 'package:time_gem/models/calendar_event_model.dart';

void main() {
  sqfliteFfiInit();

  group('LocalCalendarService', () {
    late DatabaseHelper databaseHelper;
    late LocalCalendarService localCalendarService;
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          onCreate: (db, version) {
            return db.execute(
              'CREATE TABLE events(id TEXT PRIMARY KEY, title TEXT, start TEXT, end TEXT)',
            );
          },
          version: 1,
        ),
      );
      databaseHelper = await DatabaseHelper.test(db);
      localCalendarService = LocalCalendarService(databaseHelper);
    });

    tearDown(() async {
      await db.close();
    });

    test('insertEvent and getEvents', () async {
      final event = CalendarEventModel(
        id: '1',
        title: 'Test Event',
        start: DateTime(2025, 10, 26, 9, 0),
        end: DateTime(2025, 10, 26, 10, 0),
      );
      await localCalendarService.insertEvent(event);

      final events = await localCalendarService.getEvents();
      expect(events.length, 1);
      expect(events.first.title, 'Test Event');
    });

    test('deleteEvent', () async {
      final event = CalendarEventModel(
        id: '2',
        title: 'Another Event',
        start: DateTime(2025, 10, 27, 11, 0),
        end: DateTime(2025, 10, 27, 12, 0),
      );
      await localCalendarService.insertEvent(event);

      var events = await localCalendarService.getEvents();
      expect(events.length, 1);

      await localCalendarService.deleteEvent('2');
      events = await localCalendarService.getEvents();
      expect(events.length, 0);
    });

    test('inserting event with same id replaces it', () async {
      final event1 = CalendarEventModel(
        id: '3',
        title: 'Original Event',
        start: DateTime(2025, 10, 28, 13, 0),
        end: DateTime(2025, 10, 28, 14, 0),
      );
      await localCalendarService.insertEvent(event1);

      final event2 = CalendarEventModel(
        id: '3',
        title: 'Updated Event',
        start: DateTime(2025, 10, 28, 13, 0),
        end: DateTime(2025, 10, 28, 14, 0),
      );
      await localCalendarService.insertEvent(event2);

      final events = await localCalendarService.getEvents();
      expect(events.length, 1);
      expect(events.first.title, 'Updated Event');
    });
  });
}
