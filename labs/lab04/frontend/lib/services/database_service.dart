import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'lab04_app.db';
  static const int _version = 1;

  // TODO: Implement database getter
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // TODO: Implement _initDatabase method
  static Future<Database> _initDatabase() async {
    // Get the default databases location
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Open the database, set version, and provide onCreate and onUpgrade callbacks
    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // TODO: Implement _onCreate method
  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create posts table
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        published INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  // TODO: Implement _onUpgrade method
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // TODO: Handle database schema upgrades
    // For now, you can leave this empty or add migration logic later
  }

  // User CRUD operations

  // TODO: Implement createUser method
  static Future<User> createUser(CreateUserRequest request) async {
    final db = await database;

    final now = DateTime.now();
    final userMap = {
      'name': request.name.trim(),
      'email': request.email.trim(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    final id = await db.insert(
      'users',
      userMap,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return User(
      id: id,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: now,
      updatedAt: now,
    );
  }

  // TODO: Implement getUser method
  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      final userMap = maps.first;
      return User(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        createdAt: DateTime.parse(userMap['created_at'] as String),
        updatedAt: DateTime.parse(userMap['updated_at'] as String),
      );
    }
    return null;
  }

  // TODO: Implement getAllUsers method
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query(
      'users',
      orderBy: 'created_at ASC',
    );
    return maps.map((userMap) => User(
      id: userMap['id'] as int,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    )).toList();
  }

  // TODO: Implement updateUser method
  static Future<User> updateUser(int id, Map<String, dynamic> updates) async {
    final db = await database;

    // Prepare the updates map and update the updated_at timestamp
    final updatedAt = DateTime.now();
    final updateData = Map<String, dynamic>.from(updates);
    updateData['updated_at'] = updatedAt.toIso8601String();

    // Update the user in the database
    await db.update(
      'users',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Fetch the updated user and return
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final userMap = maps.first;
      return User(
        id: userMap['id'] as int,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        createdAt: DateTime.parse(userMap['created_at'] as String),
        updatedAt: DateTime.parse(userMap['updated_at'] as String),
      );
    } else {
      throw Exception('User not found');
    }
  }

  // TODO: Implement deleteUser method
  static Future<void> deleteUser(int id) async {
    final db = await database;

    // Delete the user by ID
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    // If you have related tables (e.g., posts, comments), consider deleting related data here.
    // For now, this only deletes the user from the users table.
  }

  // TODO: Implement getUserCount method
  static Future<int> getUserCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    if (result.isNotEmpty) {
      return result.first['count'] as int;
    } else {
      return 0;
    }
  }

  // TODO: Implement searchUsers method
  static Future<List<User>> searchUsers(String query) async {
    final db = await database;
    final searchQuery = '%${query.trim()}%';
    final maps = await db.query(
      'users',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: [searchQuery, searchQuery],
    );
    return maps.map((userMap) => User(
      id: userMap['id'] as int,
      name: userMap['name'] as String,
      email: userMap['email'] as String,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      updatedAt: DateTime.parse(userMap['updated_at'] as String),
    )).toList();
  }

  // Database utility methods

  // TODO: Implement closeDatabase method
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // TODO: Implement clearAllData method
  static Future<void> clearAllData() async {
    final db = await database;

    // Delete all records from all tables
    await db.delete('users');
    // Если будут другие таблицы, добавьте их очистку здесь

    // Сброс автоинкремента (SQLite)
    // Для таблицы users
    await db.execute("DELETE FROM sqlite_sequence WHERE name='users'");
    // Если есть другие таблицы с автоинкрементом, добавьте их сброс здесь
  }

  // TODO: Implement getDatabasePath method
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return path;
  }
}
