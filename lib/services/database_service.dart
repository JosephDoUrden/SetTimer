import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/preset_model.dart';
import '../models/workout_session_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'settimer.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create presets table
    await db.execute('''
      CREATE TABLE custom_presets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        totalSets INTEGER NOT NULL,
        setDurationSeconds INTEGER NOT NULL,
        restDurationSeconds INTEGER NOT NULL,
        restAfterSets INTEGER NOT NULL,
        category TEXT NOT NULL,
        iconName TEXT,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create workout sessions table
    await db.execute('''
      CREATE TABLE workout_sessions (
        id TEXT PRIMARY KEY,
        presetId TEXT,
        presetName TEXT,
        totalSets INTEGER NOT NULL,
        setDurationSeconds INTEGER NOT NULL,
        restDurationSeconds INTEGER NOT NULL,
        restAfterSets INTEGER NOT NULL,
        completedSets INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'inProgress',
        startTime TEXT NOT NULL,
        endTime TEXT,
        totalPausedDurationSeconds INTEGER NOT NULL DEFAULT 0,
        actualWorkoutDurationSeconds INTEGER NOT NULL DEFAULT 0,
        completionPercentage REAL NOT NULL DEFAULT 0.0,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (presetId) REFERENCES custom_presets (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_custom_presets_category ON custom_presets(category)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_start_time ON workout_sessions(startTime)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_status ON workout_sessions(status)
    ''');

    await db.execute('''
      CREATE INDEX idx_workout_sessions_preset_id ON workout_sessions(presetId)
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add workout sessions table
      await db.execute('''
        CREATE TABLE workout_sessions (
          id TEXT PRIMARY KEY,
          presetId TEXT,
          presetName TEXT,
          totalSets INTEGER NOT NULL,
          setDurationSeconds INTEGER NOT NULL,
          restDurationSeconds INTEGER NOT NULL,
          restAfterSets INTEGER NOT NULL,
          completedSets INTEGER NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'inProgress',
          startTime TEXT NOT NULL,
          endTime TEXT,
          totalPausedDurationSeconds INTEGER NOT NULL DEFAULT 0,
          actualWorkoutDurationSeconds INTEGER NOT NULL DEFAULT 0,
          completionPercentage REAL NOT NULL DEFAULT 0.0,
          metadata TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (presetId) REFERENCES custom_presets (id) ON DELETE SET NULL
        )
      ''');

      // Create indexes for workout sessions
      await db.execute('''
        CREATE INDEX idx_workout_sessions_start_time ON workout_sessions(startTime)
      ''');

      await db.execute('''
        CREATE INDEX idx_workout_sessions_status ON workout_sessions(status)
      ''');

      await db.execute('''
        CREATE INDEX idx_workout_sessions_preset_id ON workout_sessions(presetId)
      ''');
    }
  }

  /// Save a custom preset to the database
  Future<void> saveCustomPreset(PresetModel preset) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final presetData = preset.toJson();
    presetData['createdAt'] = now;
    presetData['updatedAt'] = now;
    presetData['isDefault'] = preset.isDefault ? 1 : 0;

    await db.insert(
      'custom_presets',
      presetData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing custom preset
  Future<void> updateCustomPreset(PresetModel preset) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final presetData = preset.toJson();
    presetData['updatedAt'] = now;
    presetData['isDefault'] = preset.isDefault ? 1 : 0;

    await db.update(
      'custom_presets',
      presetData,
      where: 'id = ?',
      whereArgs: [preset.id],
    );
  }

  /// Get all custom presets from the database
  Future<List<PresetModel>> getAllCustomPresets() async {
    final db = await database;
    final maps = await db.query(
      'custom_presets',
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) {
      final presetMap = Map<String, dynamic>.from(map);
      presetMap['isDefault'] = map['isDefault'] == 1;
      presetMap.remove('createdAt');
      presetMap.remove('updatedAt');
      return PresetModel.fromJson(presetMap);
    }).toList();
  }

  /// Get custom presets by category
  Future<List<PresetModel>> getCustomPresetsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      'custom_presets',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) {
      final presetMap = Map<String, dynamic>.from(map);
      presetMap['isDefault'] = map['isDefault'] == 1;
      presetMap.remove('createdAt');
      presetMap.remove('updatedAt');
      return PresetModel.fromJson(presetMap);
    }).toList();
  }

  /// Get a custom preset by ID
  Future<PresetModel?> getCustomPresetById(String id) async {
    final db = await database;
    final maps = await db.query(
      'custom_presets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final presetMap = Map<String, dynamic>.from(map);
    presetMap['isDefault'] = map['isDefault'] == 1;
    presetMap.remove('createdAt');
    presetMap.remove('updatedAt');
    return PresetModel.fromJson(presetMap);
  }

  /// Delete a custom preset
  Future<void> deleteCustomPreset(String id) async {
    final db = await database;
    await db.delete(
      'custom_presets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all unique categories from custom presets
  Future<List<String>> getCustomPresetCategories() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT category FROM custom_presets ORDER BY category',
    );

    return maps.map((map) => map['category'] as String).toList();
  }

  /// Search custom presets by name or description
  Future<List<PresetModel>> searchCustomPresets(String query) async {
    final db = await database;
    final maps = await db.query(
      'custom_presets',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) {
      final presetMap = Map<String, dynamic>.from(map);
      presetMap['isDefault'] = map['isDefault'] == 1;
      presetMap.remove('createdAt');
      presetMap.remove('updatedAt');
      return PresetModel.fromJson(presetMap);
    }).toList();
  }

  /// Check if a preset name already exists
  Future<bool> presetNameExists(String name, {String? excludeId}) async {
    final db = await database;

    String whereClause = 'LOWER(name) = ?';
    List<dynamic> whereArgs = [name.toLowerCase()];

    if (excludeId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeId);
    }

    final maps = await db.query(
      'custom_presets',
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Get the count of custom presets
  Future<int> getCustomPresetCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM custom_presets');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Save a workout session to the database
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final sessionData = session.toJson();
    sessionData['createdAt'] = now;
    sessionData['updatedAt'] = now;

    await db.insert(
      'workout_sessions',
      sessionData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing workout session
  Future<void> updateWorkoutSession(WorkoutSession session) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final sessionData = session.toJson();
    sessionData['updatedAt'] = now;

    await db.update(
      'workout_sessions',
      sessionData,
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  /// Get a workout session by ID
  Future<WorkoutSession?> getWorkoutSessionById(String id) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final sessionMap = Map<String, dynamic>.from(map);
    sessionMap.remove('createdAt');
    sessionMap.remove('updatedAt');
    return WorkoutSession.fromJson(sessionMap);
  }

  /// Get all workout sessions ordered by start time (most recent first)
  Future<List<WorkoutSession>> getAllWorkoutSessions({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      orderBy: 'startTime DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) {
      final sessionMap = Map<String, dynamic>.from(map);
      sessionMap.remove('createdAt');
      sessionMap.remove('updatedAt');
      return WorkoutSession.fromJson(sessionMap);
    }).toList();
  }

  /// Get workout sessions within a date range
  Future<List<WorkoutSession>> getWorkoutSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'startTime DESC',
      limit: limit,
    );

    return maps.map((map) {
      final sessionMap = Map<String, dynamic>.from(map);
      sessionMap.remove('createdAt');
      sessionMap.remove('updatedAt');
      return WorkoutSession.fromJson(sessionMap);
    }).toList();
  }

  /// Get workout sessions by status
  Future<List<WorkoutSession>> getWorkoutSessionsByStatus(
    SessionStatus status, {
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'startTime DESC',
      limit: limit,
    );

    return maps.map((map) {
      final sessionMap = Map<String, dynamic>.from(map);
      sessionMap.remove('createdAt');
      sessionMap.remove('updatedAt');
      return WorkoutSession.fromJson(sessionMap);
    }).toList();
  }

  /// Get workout sessions for a specific preset
  Future<List<WorkoutSession>> getWorkoutSessionsByPreset(
    String presetId, {
    int? limit,
  }) async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'presetId = ?',
      whereArgs: [presetId],
      orderBy: 'startTime DESC',
      limit: limit,
    );

    return maps.map((map) {
      final sessionMap = Map<String, dynamic>.from(map);
      sessionMap.remove('createdAt');
      sessionMap.remove('updatedAt');
      return WorkoutSession.fromJson(sessionMap);
    }).toList();
  }

  /// Delete a workout session
  Future<void> deleteWorkoutSession(String id) async {
    final db = await database;
    await db.delete(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE startTime >= ? AND startTime <= ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }

    // Total sessions
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sessions $whereClause',
      whereArgs,
    );
    final totalSessions = Sqflite.firstIntValue(totalResult) ?? 0;

    // Completed sessions
    final completedWhereClause = whereClause.isEmpty ? "WHERE status = 'completed'" : "$whereClause AND status = 'completed'";
    final completedArgs = [...whereArgs, if (whereClause.isEmpty) 'completed'];

    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_sessions $completedWhereClause',
      completedArgs,
    );
    final completedSessions = Sqflite.firstIntValue(completedResult) ?? 0;

    // Total workout time (for completed sessions)
    final timeResult = await db.rawQuery(
      'SELECT SUM(actualWorkoutDurationSeconds) as total FROM workout_sessions $completedWhereClause',
      completedArgs,
    );
    final totalWorkoutSeconds = Sqflite.firstIntValue(timeResult) ?? 0;

    // Average session duration
    final avgResult = await db.rawQuery(
      'SELECT AVG(actualWorkoutDurationSeconds) as avg FROM workout_sessions $completedWhereClause',
      completedArgs,
    );
    final avgWorkoutSeconds = (avgResult.first['avg'] as num?)?.round() ?? 0;

    // Total sets completed
    final setsResult = await db.rawQuery(
      'SELECT SUM(completedSets) as total FROM workout_sessions $completedWhereClause',
      completedArgs,
    );
    final totalSetsCompleted = Sqflite.firstIntValue(setsResult) ?? 0;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'totalWorkoutTimeSeconds': totalWorkoutSeconds,
      'averageWorkoutTimeSeconds': avgWorkoutSeconds,
      'totalSetsCompleted': totalSetsCompleted,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions * 100) : 0.0,
    };
  }

  /// Get current active session (if any)
  Future<WorkoutSession?> getCurrentActiveSession() async {
    final db = await database;
    final maps = await db.query(
      'workout_sessions',
      where: 'status IN (?, ?)',
      whereArgs: ['inProgress', 'paused'],
      orderBy: 'startTime DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final sessionMap = Map<String, dynamic>.from(map);
    sessionMap.remove('createdAt');
    sessionMap.remove('updatedAt');
    return WorkoutSession.fromJson(sessionMap);
  }

  /// Close the database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Clear all custom presets (for testing purposes)
  Future<void> clearAllCustomPresets() async {
    final db = await database;
    await db.delete('custom_presets');
  }
}
