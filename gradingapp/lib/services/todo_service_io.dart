import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class TodoService {
  static Database? _db;

  static const _tableName = 'todos';

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            priority TEXT NOT NULL,
            status TEXT NOT NULL,
            dueDate TEXT,
            category TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ── Create ───────────────────────────────────────────────────────────────

  Future<void> addTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      _tableName,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'createdAt DESC');
    return maps.map(Todo.fromMap).toList();
  }

  Future<List<Todo>> getTodosByStatus(TodoStatus status) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Todo.fromMap).toList();
  }

  Future<List<Todo>> getTodosByPriority(TodoPriority priority) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'priority = ?',
      whereArgs: [priority.name],
      orderBy: 'createdAt DESC',
    );
    return maps.map(Todo.fromMap).toList();
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      _tableName,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updated = todo.copyWith(
      status: todo.status == TodoStatus.pending
          ? TodoStatus.completed
          : TodoStatus.pending,
    );
    await updateTodo(updated);
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCompleted() async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'status = ?',
      whereArgs: [TodoStatus.completed.name],
    );
  }
}
