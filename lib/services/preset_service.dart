import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/preset_model.dart';

class PresetService {
  static final PresetService _instance = PresetService._internal();
  factory PresetService() => _instance;
  PresetService._internal();

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
      // For now, return default presets
      // In future sprints, this will include custom presets from local storage
      _cachedPresets = List.from(_defaultPresets);
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

  /// Save custom preset (for future implementation)
  Future<void> saveCustomPreset(PresetModel preset) async {
    // TODO: Implement in Sprint 1.2 - Custom Template Management
    throw UnimplementedError('Custom preset saving will be implemented in Sprint 1.2');
  }

  /// Delete custom preset (for future implementation)
  Future<void> deleteCustomPreset(String id) async {
    // TODO: Implement in Sprint 1.2 - Custom Template Management
    throw UnimplementedError('Custom preset deletion will be implemented in Sprint 1.2');
  }

  /// Export preset to JSON
  String exportPreset(PresetModel preset) {
    return jsonEncode(preset.toJson());
  }

  /// Import preset from JSON
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
