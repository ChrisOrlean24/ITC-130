import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Database? _database;

  Future<Database> get _db async => _database ??= await _openDatabase();

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'teachdesk_auth.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            email TEXT PRIMARY KEY,
            passwordHash TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> register(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _db;
    final existing = await db.query(
      'users',
      columns: ['email'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (existing.isNotEmpty) {
      throw Exception('An account already exists for this email.');
    }

    await db.insert('users', {
      'email': normalizedEmail,
      'passwordHash': _hashPassword(normalizedEmail, password),
    });
  }

  Future<void> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _db;
    final users = await db.query(
      'users',
      columns: ['passwordHash'],
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (users.isEmpty || users.first['passwordHash'] != _hashPassword(normalizedEmail, password)) {
      throw Exception('Invalid email or password.');
    }
  }

  Future<void> signOut() async {
    // Local authentication uses stateless sign-in on this service.
  }

  String _hashPassword(String email, String password) {
    final bytes = utf8.encode('$email:$password');
    return sha256.convert(bytes).toString();
  }
}
