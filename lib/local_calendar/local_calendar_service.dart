import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:time_gem/models/calendar_event_model.dart';

class LocalCalendarService {
  final DatabaseHelper _databaseHelper;

  LocalCalendarService(this._databaseHelper);

  Future<void> insertEvent(CalendarEventModel event) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'events',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CalendarEventModel>> getEvents() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return CalendarEventModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteEvent(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  // For testing purposes
  static Future<DatabaseHelper> test(Database database) async {
    _database = database;
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'local_calendar.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE events(id TEXT PRIMARY KEY, title TEXT, start TEXT, end TEXT)',
        );
      },
      version: 1,
    );
  }
}
