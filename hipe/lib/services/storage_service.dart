import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';
  static const _themeKey = 'app_theme';
  static const _onboardingKey = 'onboarding_done';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Token
  Future<void> saveToken(String token) async =>
      (await _prefs).setString(_tokenKey, token);

  Future<String?> getToken() async => (await _prefs).getString(_tokenKey);

  Future<void> removeToken() async => (await _prefs).remove(_tokenKey);

  // User
  Future<void> saveUser(UserModel user) async =>
      (await _prefs).setString(_userKey, jsonEncode(user.toJson()));

  Future<UserModel?> getUser() async {
    final data = (await _prefs).getString(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> removeUser() async => (await _prefs).remove(_userKey);

  // Theme
  Future<void> saveTheme(bool isDark) async =>
      (await _prefs).setBool(_themeKey, isDark);

  Future<bool> getTheme() async =>
      (await _prefs).getBool(_themeKey) ?? false;

  // Onboarding
  Future<void> setOnboardingDone() async =>
      (await _prefs).setBool(_onboardingKey, true);

  Future<bool> isOnboardingDone() async =>
      (await _prefs).getBool(_onboardingKey) ?? false;

  // Clear all
  Future<void> clearAll() async => (await _prefs).clear();
}
