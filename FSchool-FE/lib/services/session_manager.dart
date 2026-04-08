import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bai1/models/auth_response.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  AuthResponse? user;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoStr = prefs.getString('user_info');
    if (userInfoStr != null) {
      try {
        user = AuthResponse.fromJson(jsonDecode(userInfoStr));
      } catch (e) {
        print("Error loading session: $e");
      }
    }
  }

  Future<void> saveSession(AuthResponse authResponse, dynamic rawJson) async {
    user = authResponse;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authResponse.accessToken);
    await prefs.setString('user_info', jsonEncode(rawJson));
  }

  Future<void> clearSession() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_info');
  }
}
