import 'dart:convert';
import '../models/preset_model.dart';
import 'database_service.dart';

class PresetService {
  static final PresetService _instance = PresetService._internal();
  factory PresetService() => _instance;
  PresetService._internal();

  final DatabaseService _databaseService = DatabaseService();
  List<PresetModel>? _cachedPresets;

  // Default workout presets
  static const List<PresetModel> _defaultPresets = [
    PresetModel(
      id: 'tabata_classic',
      name: 'Classic Tabata',
      description: 'High-intensity intervals for maximum fat burn',
      totalSets: 8,
      setDurationSeconds: 20,
      restDurationSeconds: 10,
      restAfterSets: 1,
      category: 'HIIT',
      iconName: 'flash_on',
      isDefault: true,
    ),
    PresetModel(
      id: 'ab_destroyer',
      name: 'Ab Destroyer',
      description: 'Intense core workout for strong abs',
      totalSets: 6,
      setDurationSeconds: 45,
      restDurationSeconds: 15,
      restAfterSets: 1,
      category: 'Core',
      iconName: 'fitness_center',
      isDefault: true,
    ),
    PresetModel(
      id: 'hiit_intervals',
      name: 'HIIT Intervals',
      description: 'Balanced work-rest ratio for sustained intensity',
      totalSets: 10,
      setDurationSeconds: 30,
      restDurationSeconds: 30,
      restAfterSets: 1,
      category: 'HIIT',
      iconName: 'timer',
      isDefault: true,
    ),
    PresetModel(
      id: 'endurance_builder',
      name: 'Endurance Builder',
      description: 'Build stamina with longer work periods',
      totalSets: 5,
      setDurationSeconds: 60,
      restDurationSeconds: 20,
      restAfterSets: 1,
      category: 'Endurance',
      iconName: 'trending_up',
      isDefault: true,
    ),
    PresetModel(
      id: 'quick_burn',
      name: 'Quick Burn',
      description: 'Short but intense 5-minute workout',
      totalSets: 10,
      setDurationSeconds: 25,
      restDurationSeconds: 5,
      restAfterSets: 1,
      category: 'Quick',
      iconName: 'bolt',
      isDefault: true,
    ),
    PresetModel(
      id: 'pyramid_power',
      name: 'Pyramid Power',
      description: 'Progressive intensity building',
      totalSets: 7,
      setDurationSeconds: 40,
      restDurationSeconds: 20,
      restAfterSets: 2,
      category: 'Strength',
      iconName: 'trending_up',
      isDefault: true,
    ),
  ];

  /// Get all available presets (default + custom)
  Future<List<PresetModel>> getAllPresets() async {
    if (_cachedPresets != null) {
      return _cachedPresets!;
    }

    try {
      final customPresets = await _databaseService.getAllCustomPresets();
      _cachedPresets = [..._defaultPresets, ...customPresets];
      return _cachedPresets!;
    } catch (e) {
      print('Error loading presets: $e');
      return List.from(_defaultPresets);
    }
  }

  /// Get presets by category
  Future<List<PresetModel>> getPresetsByCategory(String category) async {
    final allPresets = await getAllPresets();
    return allPresets.where((preset) => preset.category == category).toList();
  }

  /// Get default presets only
  List<PresetModel> getDefaultPresets() {
    return List.from(_defaultPresets);
  }

  /// Get available categories
  Future<List<String>> getCategories() async {
    final presets = await getAllPresets();
    final categories = presets.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Find preset by ID
  Future<PresetModel?> getPresetById(String id) async {
    final presets = await getAllPresets();
    try {
      return presets.firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Save custom preset
  Future<void> saveCustomPreset(PresetModel preset) async {
    try {
      await _databaseService.saveCustomPreset(preset);
      clearCache(); // Clear cache to force reload
    } catch (e) {
      throw Exception('Failed to save custom preset: $e');
    }
  }

  /// Delete custom preset
  Future<void> deleteCustomPreset(String id) async {
    try {
      await _databaseService.deleteCustomPreset(id);
      clearCache(); // Clear cache to force reload
    } catch (e) {
      throw Exception('Failed to delete custom preset: $e');
    }
  }

  /// Update custom preset
  Future<void> updateCustomPreset(PresetModel preset) async {
    try {
      await _databaseService.updateCustomPreset(preset);
      clearCache(); // Clear cache to force reload
    } catch (e) {
      throw Exception('Failed to update custom preset: $e');
    }
  }

  /// Check if preset name already exists
  Future<bool> presetNameExists(String name, {String? excludeId}) async {
    // Check default presets
    final defaultExists =
        _defaultPresets.any((preset) => preset.name.toLowerCase() == name.toLowerCase() && (excludeId == null || preset.id != excludeId));

    if (defaultExists) return true;

    // Check custom presets
    return await _databaseService.presetNameExists(name, excludeId: excludeId);
  }

  /// Get custom presets count
  Future<int> getCustomPresetCount() async {
    return await _databaseService.getCustomPresetCount();
  }

  // Import/Export functionality will be implemented in future versions
  // when file_picker and share_plus packages are added back with privacy manifests

  /// Export preset to JSON string
  String exportPreset(PresetModel preset) {
    return jsonEncode(preset.toJson());
  }

  /// Import preset from JSON string
  PresetModel importPreset(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PresetModel.fromJson(json);
    } catch (e) {
      throw FormatException('Invalid preset format: $e');
    }
  }

  /// Clear cache (useful for testing or after updates)
  void clearCache() {
    _cachedPresets = null;
  }

  /// Validate preset data
  bool validatePreset(PresetModel preset) {
    return preset.name.isNotEmpty &&
        preset.totalSets > 0 &&
        preset.totalSets <= 50 &&
        preset.setDurationSeconds >= 5 &&
        preset.setDurationSeconds <= 600 &&
        preset.restDurationSeconds >= 0 &&
        preset.restDurationSeconds <= 300 &&
        preset.restAfterSets > 0 &&
        preset.restAfterSets <= preset.totalSets;
  }

  /// Get most popular presets (analytics-based, future feature)
  Future<List<PresetModel>> getPopularPresets() async {
    // For now, return first 4 default presets
    final defaults = getDefaultPresets();
    return defaults.take(4).toList();
  }

  /// Search presets by name or description
  Future<List<PresetModel>> searchPresets(String query) async {
    if (query.isEmpty) return getAllPresets();

    final allPresets = await getAllPresets();
    final lowercaseQuery = query.toLowerCase();

    return allPresets.where((preset) {
      return preset.name.toLowerCase().contains(lowercaseQuery) ||
          preset.description.toLowerCase().contains(lowercaseQuery) ||
          preset.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
