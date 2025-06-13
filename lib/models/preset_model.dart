class PresetModel {
  final String id;
  final String name;
  final String description;
  final int totalSets;
  final int setDurationSeconds;
  final int restDurationSeconds;
  final int restAfterSets;
  final String category;
  final String? iconName;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PresetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.totalSets,
    required this.setDurationSeconds,
    required this.restDurationSeconds,
    required this.restAfterSets,
    this.category = 'Custom',
    this.iconName,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Generate a custom preset ID
  static String generateCustomId() {
    return 'custom_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Create a new custom preset with auto-generated ID and timestamps
  factory PresetModel.createCustom({
    required String name,
    required String description,
    required int totalSets,
    required int setDurationSeconds,
    required int restDurationSeconds,
    required int restAfterSets,
    String category = 'Custom',
    String? iconName,
  }) {
    final now = DateTime.now();
    return PresetModel(
      id: generateCustomId(),
      name: name,
      description: description,
      totalSets: totalSets,
      setDurationSeconds: setDurationSeconds,
      restDurationSeconds: restDurationSeconds,
      restAfterSets: restAfterSets,
      category: category,
      iconName: iconName,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  PresetModel copyWith({
    String? id,
    String? name,
    String? description,
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
    String? category,
    String? iconName,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalSets: totalSets ?? this.totalSets,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      restAfterSets: restAfterSets ?? this.restAfterSets,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalSets': totalSets,
      'setDurationSeconds': setDurationSeconds,
      'restDurationSeconds': restDurationSeconds,
      'restAfterSets': restAfterSets,
      'category': category,
      'iconName': iconName,
      'isDefault': isDefault,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  factory PresetModel.fromJson(Map<String, dynamic> json) {
    return PresetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalSets: json['totalSets'] as int,
      setDurationSeconds: json['setDurationSeconds'] as int,
      restDurationSeconds: json['restDurationSeconds'] as int,
      restAfterSets: json['restAfterSets'] as int,
      category: json['category'] as String? ?? 'Custom',
      iconName: json['iconName'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  String get formattedDuration {
    final workMinutes = setDurationSeconds ~/ 60;
    final workSeconds = setDurationSeconds % 60;
    final restMinutes = restDurationSeconds ~/ 60;
    final restSecondsRemaining = restDurationSeconds % 60;

    String workTime = workSeconds > 0 ? '${workMinutes}m ${workSeconds}s' : '${workMinutes}m';
    String restTime = restSecondsRemaining > 0 ? '${restMinutes}m ${restSecondsRemaining}s' : '${restMinutes}m';

    if (workMinutes == 0) workTime = '${setDurationSeconds}s';
    if (restMinutes == 0) restTime = '${restDurationSeconds}s';

    return '$workTime work, $restTime rest';
  }

  String get estimatedDuration {
    final totalWorkTime = totalSets * setDurationSeconds;
    final restSets = (totalSets / restAfterSets).floor();
    final totalRestTime = restSets * restDurationSeconds;
    final totalSeconds = totalWorkTime + totalRestTime;

    final minutes = totalSeconds ~/ 60;
    return '~${minutes}min';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PresetModel(id: $id, name: $name, sets: $totalSets)';
  }
}
