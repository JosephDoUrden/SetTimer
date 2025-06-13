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
  });

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
