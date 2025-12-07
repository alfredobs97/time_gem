import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyStartTime = 'start_time';
  static const String _keyEndTime = 'end_time';

  // Onboarding Status
  bool get isOnboardingCompleted =>
      _prefs.getBool(_keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  // User Preferences
  DateTime? get startTime {
    final startString = _prefs.getString(_keyStartTime);
    if (startString == null) return null;
    return DateTime.tryParse(startString);
  }

  DateTime? get endTime {
    final endString = _prefs.getString(_keyEndTime);
    if (endString == null) return null;
    return DateTime.tryParse(endString);
  }

  Future<void> saveUserPreferences({
    required DateTime start,
    required DateTime end,
  }) async {
    await _prefs.setString(_keyStartTime, start.toIso8601String());
    await _prefs.setString(_keyEndTime, end.toIso8601String());
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
