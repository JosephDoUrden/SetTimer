import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/preset_model.dart';

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
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
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

    // Create index for better performance
    await db.execute('''
      CREATE INDEX idx_custom_presets_category ON custom_presets(category)
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades in future versions
    if (oldVersion < 2) {
      // Example: Add new columns or tables
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
