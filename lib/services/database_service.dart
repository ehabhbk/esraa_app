import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'esraa_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mood TEXT NOT NULL,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE evaluations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        rating INTEGER NOT NULL,
        learnedSomething INTEGER DEFAULT 0,
        helpedPatient INTEGER DEFAULT 0,
        satisfied INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isDone INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        category TEXT DEFAULT 'عام'
      )
    ''');
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        cups INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        eaten INTEGER DEFAULT 0,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE prayer_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        prayer TEXT NOT NULL,
        performed INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT NOT NULL,
        category TEXT DEFAULT 'عام',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE letters_to_father (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconEmoji TEXT NOT NULL,
        isUnlocked INTEGER DEFAULT 0,
        unlockedAt TEXT,
        progress INTEGER DEFAULT 0,
        target INTEGER DEFAULT 1
      )
    ''');
  }

  static Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return await db.insert(table, values);
  }

  static Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  static Future<int> delete(String table, String where,
      List<dynamic> whereArgs) async {
    final db = await database;
    return await db
        .delete(table, where: where, whereArgs: whereArgs);
  }

  static Future<List<Map<String, dynamic>>> query(String table,
      {String? where,
      List<dynamic>? whereArgs,
      String? orderBy,
      int? limit}) async {
    final db = await database;
    return await db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  static Future<Map<String, dynamic>?> querySingle(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final results = await query(table, where: where, whereArgs: whereArgs);
    return results.isNotEmpty ? results.first : null;
  }

  static Future<DateTime?> getLastNotificationDate(String type) async {
    final db = await database;
    final result = await db.query('notification_log',
        where: 'type = ?', whereArgs: [type], orderBy: 'date DESC', limit: 1);
    if (result.isNotEmpty) {
      return DateTime.parse(result.first['date'] as String);
    }
    return null;
  }

  static Future<void> logNotification(String type) async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notification_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
    await db.insert('notification_log', {
      'type': type,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<bool> hasDataForDate(String table, String dateColumn,
      DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay =
        startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    final result = await db.query(table,
        where: '$dateColumn >= ? AND $dateColumn <= ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        limit: 1);
    return result.isNotEmpty;
  }

  static Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
