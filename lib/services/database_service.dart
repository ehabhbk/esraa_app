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
      version: 9,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
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
        category TEXT DEFAULT 'عام',
        scheduledTime TEXT,
        reminderMinutes INTEGER DEFAULT 30,
        progress INTEGER DEFAULT 0,
        hasCompleted INTEGER DEFAULT 0
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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        notes TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        shiftType TEXT NOT NULL,
        notes TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientName TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL,
        notes TEXT DEFAULT '',
        status TEXT DEFAULT 'قادم',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        time TEXT NOT NULL,
        notes TEXT DEFAULT '',
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        isDone INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        weekStart TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medical_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        source TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        phone TEXT NOT NULL,
        hospital TEXT DEFAULT '',
        notes TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        systolic INTEGER,
        diastolic INTEGER,
        weight REAL,
        heartRate INTEGER,
        sleepHours INTEGER,
        notes TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cme_hours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        hours REAL NOT NULL,
        type TEXT NOT NULL,
        provider TEXT DEFAULT '',
        date TEXT NOT NULL,
        notes TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS memory_capsules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imagePath TEXT,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_impacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        patientDescription TEXT NOT NULL,
        impactDescription TEXT NOT NULL,
        category TEXT NOT NULL,
        emotion TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS photo_diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        caption TEXT DEFAULT '',
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        unit TEXT NOT NULL,
        target INTEGER DEFAULT 1,
        current INTEGER DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS visited_places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        city TEXT DEFAULT '',
        date TEXT,
        rating INTEGER DEFAULT 3,
        notes TEXT DEFAULT '',
        imagePath TEXT,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wishlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL,
        category TEXT NOT NULL,
        priority TEXT DEFAULT 'متوسط',
        link TEXT,
        isPurchased INTEGER DEFAULT 0,
        notes TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS my_ideas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT DEFAULT 'أخرى',
        status TEXT DEFAULT 'جديد',
        progress INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dreams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT DEFAULT '',
        category TEXT DEFAULT 'شخصي',
        isAchieved INTEGER DEFAULT 0,
        targetDate TEXT,
        achievedDate TEXT,
        priority INTEGER DEFAULT 5,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hobbies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT DEFAULT '🎨',
        startDate TEXT,
        hoursPerWeek INTEGER,
        notes TEXT DEFAULT '',
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS patients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          age INTEGER NOT NULL,
          gender TEXT NOT NULL,
          diagnosis TEXT NOT NULL,
          notes TEXT DEFAULT '',
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          shiftType TEXT NOT NULL,
          notes TEXT DEFAULT ''
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('CREATE TABLE IF NOT EXISTS appointments (id INTEGER PRIMARY KEY AUTOINCREMENT, patientName TEXT NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, type TEXT NOT NULL, notes TEXT DEFAULT \'\', status TEXT DEFAULT \'قادم\', createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS medicines (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, dosage TEXT NOT NULL, frequency TEXT NOT NULL, time TEXT NOT NULL, notes TEXT DEFAULT \'\', isActive INTEGER DEFAULT 1, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, category TEXT NOT NULL, description TEXT NOT NULL, date TEXT NOT NULL, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS daily_goals (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, type TEXT NOT NULL, category TEXT NOT NULL, isDone INTEGER DEFAULT 0, date TEXT NOT NULL, weekStart TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS medical_notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, category TEXT NOT NULL, source TEXT DEFAULT \'\', createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, specialty TEXT NOT NULL, phone TEXT NOT NULL, hospital TEXT DEFAULT \'\', notes TEXT DEFAULT \'\', createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS health_records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, systolic INTEGER, diastolic INTEGER, weight REAL, heartRate INTEGER, sleepHours INTEGER, notes TEXT DEFAULT \'\')');
      await db.execute('CREATE TABLE IF NOT EXISTS cme_hours (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, hours REAL NOT NULL, type TEXT NOT NULL, provider TEXT DEFAULT \'\', date TEXT NOT NULL, notes TEXT DEFAULT \'\', createdAt TEXT NOT NULL)');
    }
    if (oldVersion < 4) {
      await db.execute('CREATE TABLE IF NOT EXISTS memory_capsules (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, imagePath TEXT, date TEXT NOT NULL, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS daily_impacts (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, patientDescription TEXT NOT NULL, impactDescription TEXT NOT NULL, category TEXT NOT NULL, emotion TEXT NOT NULL, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS photo_diary (id INTEGER PRIMARY KEY AUTOINCREMENT, imagePath TEXT NOT NULL, caption TEXT DEFAULT \'\', date TEXT NOT NULL, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS daily_habits (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, icon TEXT NOT NULL, unit TEXT NOT NULL, target INTEGER DEFAULT 1, current INTEGER DEFAULT 0, date TEXT NOT NULL)');
    }
    if (oldVersion < 5) {
      await db.execute('CREATE TABLE IF NOT EXISTS wardrobe_items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, color TEXT, imagePath TEXT, season TEXT DEFAULT \'كل المواسم\', isFavorite INTEGER DEFAULT 0, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS skincare_routines (id INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT NOT NULL, category TEXT NOT NULL, time TEXT NOT NULL, isDone INTEGER DEFAULT 0, date TEXT NOT NULL, notes TEXT DEFAULT \'\')');
      await db.execute('CREATE TABLE IF NOT EXISTS makeup_items (id INTEGER PRIMARY KEY AUTOINCREMENT, productName TEXT NOT NULL, category TEXT NOT NULL, brand TEXT DEFAULT \'\', shade TEXT DEFAULT \'\', isFavorite INTEGER DEFAULT 0, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS my_looks (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, description TEXT DEFAULT \'\', outfitId INTEGER, makeupNotes TEXT DEFAULT \'\', hairStyle TEXT DEFAULT \'\', accessories TEXT DEFAULT \'\', rating INTEGER DEFAULT 3, imagePath TEXT, wardrobeItemIds TEXT DEFAULT \'\', createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS measurements (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT NOT NULL, weight REAL, height REAL, bust REAL, waist REAL, hips REAL, notes TEXT DEFAULT \'\')');
    }
    if (oldVersion < 6) {
      await db.execute('CREATE TABLE IF NOT EXISTS visited_places (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, city TEXT DEFAULT \'\', date TEXT, rating INTEGER DEFAULT 3, notes TEXT DEFAULT \'\', imagePath TEXT, isFavorite INTEGER DEFAULT 0, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS wishlist_items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, price REAL, category TEXT NOT NULL, priority TEXT DEFAULT \'متوسط\', link TEXT, isPurchased INTEGER DEFAULT 0, notes TEXT DEFAULT \'\', createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS my_ideas (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, category TEXT DEFAULT \'أخرى\', status TEXT DEFAULT \'جديد\', createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS dreams (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT DEFAULT \'\', category TEXT DEFAULT \'شخصي\', isAchieved INTEGER DEFAULT 0, targetDate TEXT, achievedDate TEXT, priority INTEGER DEFAULT 5, createdAt TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS hobbies (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, category TEXT NOT NULL, icon TEXT DEFAULT \'🎨\', startDate TEXT, hoursPerWeek INTEGER, notes TEXT DEFAULT \'\', isActive INTEGER DEFAULT 1, createdAt TEXT NOT NULL)');
    }
    if (oldVersion < 7) {
      try { await db.execute('ALTER TABLE my_ideas ADD COLUMN progress INTEGER DEFAULT 0'); } catch (_) {}
    }
    if (oldVersion < 8) {
      try { await db.execute('ALTER TABLE tasks ADD COLUMN scheduledTime TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE tasks ADD COLUMN reminderMinutes INTEGER DEFAULT 30'); } catch (_) {}
      try { await db.execute('ALTER TABLE tasks ADD COLUMN progress INTEGER DEFAULT 0'); } catch (_) {}
      try { await db.execute('ALTER TABLE tasks ADD COLUMN hasCompleted INTEGER DEFAULT 0'); } catch (_) {}
    }
    if (oldVersion < 9) {
      try { await db.execute('ALTER TABLE my_looks ADD COLUMN imagePath TEXT'); } catch (_) {}
      try { await db.execute('ALTER TABLE my_looks ADD COLUMN wardrobeItemIds TEXT DEFAULT \'\''); } catch (_) {}
    }
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
