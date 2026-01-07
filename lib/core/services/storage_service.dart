import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // ====== OpenAI API Key ======
  static Future<void> saveApiKey(String key) async {
    await prefs.setString('openai_api_key', key);
  }

  static String? getApiKey() => prefs.getString('openai_api_key');

  // ====== User Session ======
  static Future<void> saveUserId(String uid) async {
    await prefs.setString('user_id', uid);
  }

  static String? getUserId() => prefs.getString('user_id');

  static Future<void> saveUserName(String name) async {
    await prefs.setString('user_name', name);
  }

  static String? getUserName() => prefs.getString('user_name');

  static Future<void> saveUserEmail(String email) async {
    await prefs.setString('user_email', email);
  }

  static String? getUserEmail() => prefs.getString('user_email');

  // ====== Onboarding State ======
  static Future<void> setOnboardingComplete(bool value) async {
    await prefs.setBool('onboarding_complete', value);
  }

  static bool isOnboardingComplete() =>
      prefs.getBool('onboarding_complete') ?? false;

  // ====== User Profile (local cache) ======
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await prefs.setString('user_profile', jsonEncode(profile));
  }

  static Map<String, dynamic>? getUserProfile() {
    final json = prefs.getString('user_profile');
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ====== AI Assessment Cache ======
  static Future<void> saveAssessment(String text) async {
    await prefs.setString('last_assessment', text);
    await prefs.setString(
        'assessment_date', DateTime.now().toIso8601String());
  }

  static String? getAssessment() => prefs.getString('last_assessment');
  static String? getAssessmentDate() => prefs.getString('assessment_date');

  // ====== Sessions Data ======
  static Future<void> saveSessionData(Map<String, dynamic> session) async {
    final sessions = getAllSessions();
    sessions.add(session);
    await prefs.setString('sessions', jsonEncode(sessions));
  }

  static List<Map<String, dynamic>> getAllSessions() {
    final json = prefs.getString('sessions');
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ====== Progress Data ======
  static Future<void> saveWeeklyProgress(Map<String, dynamic> data) async {
    await prefs.setString('weekly_progress', jsonEncode(data));
  }

  static Map<String, dynamic>? getWeeklyProgress() {
    final json = prefs.getString('weekly_progress');
    if (json == null) return null;
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ====== RGPD: Clear all data ======
  static Future<void> clearAllData() async {
    await prefs.clear();
  }

  // ====== Logout ======
  static Future<void> logout() async {
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('onboarding_complete');
    await prefs.remove('user_profile');
    await prefs.remove('last_assessment');
    await prefs.remove('sessions');
  }
}
