import 'dart:convert';
import 'dart:html' as html;

import 'package:crypto/crypto.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _storageKey = 'teachdesk_auth_users';

  Future<void> register(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _loadUsers();

    if (users.containsKey(normalizedEmail)) {
      throw Exception('An account already exists for this email.');
    }

    users[normalizedEmail] = _hashPassword(normalizedEmail, password);
    _saveUsers(users);
  }

  Future<void> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _loadUsers();

    if (users[normalizedEmail] != _hashPassword(normalizedEmail, password)) {
      throw Exception('Invalid email or password.');
    }
  }

  Future<void> signOut() async {
    // Local authentication uses stateless sign-in on this service.
  }

  Map<String, String> _loadUsers() {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(raw);
    return Map<String, String>.from(decoded as Map);
  }

  void _saveUsers(Map<String, String> users) {
    html.window.localStorage[_storageKey] = jsonEncode(users);
  }

  String _hashPassword(String email, String password) {
    final bytes = utf8.encode('$email:$password');
    return sha256.convert(bytes).toString();
  }
}
