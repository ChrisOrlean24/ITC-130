import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService({ApiService? api, StorageService? storage})
      : _api = api ?? ApiService(),
        _storage = storage ?? StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final token = response['token'] as String;
    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    await _storage.saveToken(token);
    await _storage.saveUser(user);
    _api.setAuthToken(token);
    return {'token': token, 'user': user};
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    final token = response['token'] as String;
    final user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    await _storage.saveToken(token);
    await _storage.saveUser(user);
    _api.setAuthToken(token);
    return {'token': token, 'user': user};
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {}
    await _storage.clearAll();
    _api.clearAuthToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    _api.setAuthToken(token);
    return true;
  }

  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post('/auth/reset-password', {
      'token': token,
      'password': newPassword,
    });
  }
}
