import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  totalWorkouts,
  totalTime,
  consistency,
  completion,
  personal,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final AchievementTier tier;
  final IconData icon;
  final Color color;
  final int targetValue;
  final String unit;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.tier,
    required this.icon,
    required this.color,
    required this.targetValue,
    required this.unit,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  double get progressPercentage => targetValue == 0 ? 0.0 : (currentProgress / targetValue * 100).clamp(0.0, 100.0);

  bool get isCompleted => currentProgress >= targetValue;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    AchievementType? type,
    AchievementTier? tier,
    IconData? icon,
    Color? color,
    int? targetValue,
    String? unit,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'tier': tier.toString(),
      'targetValue': targetValue,
      'unit': unit,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      tier: AchievementTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
      ),
      icon: _getIconFromString(json['icon'] ?? 'star'),
      color: _getColorFromTier(AchievementTier.values.firstWhere(
        (e) => e.toString() == json['tier'],
      )),
      targetValue: json['targetValue'],
      unit: json['unit'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      currentProgress: json['currentProgress'] ?? 0,
    );
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'timer':
        return Icons.timer;
      case 'check':
        return Icons.check_circle;
      case 'target':
        return Icons.center_focus_strong;
      case 'fitness':
        return Icons.fitness_center;
      case 'trending':
        return Icons.trending_up;
      case 'speed':
        return Icons.speed;
      case 'schedule':
        return Icons.schedule;
      case 'repeat':
        return Icons.repeat;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }

  static Color _getColorFromTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }
}

class AchievementDefinitions {
  static List<Achievement> get allAchievements => [
        // Streak Achievements
        const Achievement(
          id: 'streak_3',
          title: 'Getting Started',
          description: 'Complete workouts for 3 consecutive days',
          type: AchievementType.streak,
          tier: AchievementTier.bronze,
          icon: Icons.local_fire_department,
          color: Color(0xFFCD7F32),
          targetValue: 3,
          unit: 'days',
        ),
        const Achievement(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Complete workouts for 7 consecutive days',
          type: AchievementType.streak,
          tier: AchievementTier.silver,
          icon: Icons.local_fire_department,
          color: Color(0xFFC0C0C0),
          targetValue: 7,
          unit: 'days',
        ),
        const Achievement(
          id: 'streak_30',
          title: 'Month Master',
          description: 'Complete workouts for 30 consecutive days',
          type: AchievementType.streak,
          tier: AchievementTier.gold,
          icon: Icons.local_fire_department,
          color: Color(0xFFFFD700),
          targetValue: 30,
          unit: 'days',
        ),
        const Achievement(
          id: 'streak_100',
          title: 'Century Champion',
          description: 'Complete workouts for 100 consecutive days',
          type: AchievementType.streak,
          tier: AchievementTier.platinum,
          icon: Icons.local_fire_department,
          color: Color(0xFFE5E4E2),
          targetValue: 100,
          unit: 'days',
        ),

        // Total Workouts Achievements
        const Achievement(
          id: 'workouts_10',
          title: 'First Steps',
          description: 'Complete 10 total workouts',
          type: AchievementType.totalWorkouts,
          tier: AchievementTier.bronze,
          icon: Icons.fitness_center,
          color: Color(0xFFCD7F32),
          targetValue: 10,
          unit: 'workouts',
        ),
        const Achievement(
          id: 'workouts_50',
          title: 'Fitness Enthusiast',
          description: 'Complete 50 total workouts',
          type: AchievementType.totalWorkouts,
          tier: AchievementTier.silver,
          icon: Icons.fitness_center,
          color: Color(0xFFC0C0C0),
          targetValue: 50,
          unit: 'workouts',
        ),
        const Achievement(
          id: 'workouts_100',
          title: 'Workout Warrior',
          description: 'Complete 100 total workouts',
          type: AchievementType.totalWorkouts,
          tier: AchievementTier.gold,
          icon: Icons.fitness_center,
          color: Color(0xFFFFD700),
          targetValue: 100,
          unit: 'workouts',
        ),
        const Achievement(
          id: 'workouts_500',
          title: 'Fitness Master',
          description: 'Complete 500 total workouts',
          type: AchievementType.totalWorkouts,
          tier: AchievementTier.platinum,
          icon: Icons.fitness_center,
          color: Color(0xFFE5E4E2),
          targetValue: 500,
          unit: 'workouts',
        ),

        // Total Time Achievements
        const Achievement(
          id: 'time_1800',
          title: 'Getting Moving',
          description: 'Complete 30 minutes of total workout time',
          type: AchievementType.totalTime,
          tier: AchievementTier.bronze,
          icon: Icons.schedule,
          color: Color(0xFFCD7F32),
          targetValue: 1800, // 30 minutes in seconds
          unit: 'seconds',
        ),
        const Achievement(
          id: 'time_18000',
          title: 'Time Keeper',
          description: 'Complete 5 hours of total workout time',
          type: AchievementType.totalTime,
          tier: AchievementTier.silver,
          icon: Icons.schedule,
          color: Color(0xFFC0C0C0),
          targetValue: 18000, // 5 hours in seconds
          unit: 'seconds',
        ),
        const Achievement(
          id: 'time_72000',
          title: 'Time Master',
          description: 'Complete 20 hours of total workout time',
          type: AchievementType.totalTime,
          tier: AchievementTier.gold,
          icon: Icons.schedule,
          color: Color(0xFFFFD700),
          targetValue: 72000, // 20 hours in seconds
          unit: 'seconds',
        ),
        const Achievement(
          id: 'time_360000',
          title: 'Time Champion',
          description: 'Complete 100 hours of total workout time',
          type: AchievementType.totalTime,
          tier: AchievementTier.platinum,
          icon: Icons.schedule,
          color: Color(0xFFE5E4E2),
          targetValue: 360000, // 100 hours in seconds
          unit: 'seconds',
        ),

        // Completion Rate Achievements
        const Achievement(
          id: 'completion_75',
          title: 'Finisher',
          description: 'Maintain 75% completion rate',
          type: AchievementType.completion,
          tier: AchievementTier.bronze,
          icon: Icons.check_circle,
          color: Color(0xFFCD7F32),
          targetValue: 75,
          unit: 'percent',
        ),
        const Achievement(
          id: 'completion_85',
          title: 'Consistent Finisher',
          description: 'Maintain 85% completion rate',
          type: AchievementType.completion,
          tier: AchievementTier.silver,
          icon: Icons.check_circle,
          color: Color(0xFFC0C0C0),
          targetValue: 85,
          unit: 'percent',
        ),
        const Achievement(
          id: 'completion_95',
          title: 'Almost Perfect',
          description: 'Maintain 95% completion rate',
          type: AchievementType.completion,
          tier: AchievementTier.gold,
          icon: Icons.check_circle,
          color: Color(0xFFFFD700),
          targetValue: 95,
          unit: 'percent',
        ),
        const Achievement(
          id: 'completion_100',
          title: 'Perfectionist',
          description: 'Maintain 100% completion rate',
          type: AchievementType.completion,
          tier: AchievementTier.platinum,
          icon: Icons.check_circle,
          color: Color(0xFFE5E4E2),
          targetValue: 100,
          unit: 'percent',
        ),

        // Consistency Achievements
        const Achievement(
          id: 'consistency_70',
          title: 'Building Habits',
          description: 'Maintain 70% workout consistency',
          type: AchievementType.consistency,
          tier: AchievementTier.bronze,
          icon: Icons.trending_up,
          color: Color(0xFFCD7F32),
          targetValue: 70,
          unit: 'percent',
        ),
        const Achievement(
          id: 'consistency_80',
          title: 'Steady Progress',
          description: 'Maintain 80% workout consistency',
          type: AchievementType.consistency,
          tier: AchievementTier.silver,
          icon: Icons.trending_up,
          color: Color(0xFFC0C0C0),
          targetValue: 80,
          unit: 'percent',
        ),
        const Achievement(
          id: 'consistency_90',
          title: 'Discipline Master',
          description: 'Maintain 90% workout consistency',
          type: AchievementType.consistency,
          tier: AchievementTier.gold,
          icon: Icons.trending_up,
          color: Color(0xFFFFD700),
          targetValue: 90,
          unit: 'percent',
        ),
        const Achievement(
          id: 'consistency_95',
          title: 'Consistency Legend',
          description: 'Maintain 95% workout consistency',
          type: AchievementType.consistency,
          tier: AchievementTier.platinum,
          icon: Icons.trending_up,
          color: Color(0xFFE5E4E2),
          targetValue: 95,
          unit: 'percent',
        ),

        // Personal Achievements
        const Achievement(
          id: 'longest_workout',
          title: 'Endurance Hero',
          description: 'Complete a 60-minute workout',
          type: AchievementType.personal,
          tier: AchievementTier.gold,
          icon: Icons.timer,
          color: Color(0xFFFFD700),
          targetValue: 3600, // 60 minutes in seconds
          unit: 'seconds',
        ),
        const Achievement(
          id: 'most_sets_50',
          title: 'Set Champion',
          description: 'Complete 50 sets in a single workout',
          type: AchievementType.personal,
          tier: AchievementTier.silver,
          icon: Icons.repeat,
          color: Color(0xFFC0C0C0),
          targetValue: 50,
          unit: 'sets',
        ),
        const Achievement(
          id: 'most_sets_100',
          title: 'Set Legend',
          description: 'Complete 100 sets in a single workout',
          type: AchievementType.personal,
          tier: AchievementTier.gold,
          icon: Icons.repeat,
          color: Color(0xFFFFD700),
          targetValue: 100,
          unit: 'sets',
        ),
        const Achievement(
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Complete 20 sets in under 10 minutes',
          type: AchievementType.personal,
          tier: AchievementTier.platinum,
          icon: Icons.speed,
          color: Color(0xFFE5E4E2),
          targetValue: 1,
          unit: 'achievement',
        ),
        const Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Complete 10 workouts before 7 AM',
          type: AchievementType.personal,
          tier: AchievementTier.silver,
          icon: Icons.wb_sunny,
          color: Color(0xFFC0C0C0),
          targetValue: 10,
          unit: 'workouts',
        ),
        const Achievement(
          id: 'night_owl',
          title: 'Night Owl',
          description: 'Complete 10 workouts after 10 PM',
          type: AchievementType.personal,
          tier: AchievementTier.silver,
          icon: Icons.nights_stay,
          color: Color(0xFFC0C0C0),
          targetValue: 10,
          unit: 'workouts',
        ),
        const Achievement(
          id: 'weekend_warrior_special',
          title: 'Weekend Warrior',
          description: 'Complete workouts on 20 weekends',
          type: AchievementType.personal,
          tier: AchievementTier.bronze,
          icon: Icons.weekend,
          color: Color(0xFFCD7F32),
          targetValue: 20,
          unit: 'weekends',
        ),
        const Achievement(
          id: 'preset_explorer',
          title: 'Preset Explorer',
          description: 'Try all 5 different workout presets',
          type: AchievementType.personal,
          tier: AchievementTier.bronze,
          icon: Icons.explore,
          color: Color(0xFFCD7F32),
          targetValue: 5,
          unit: 'presets',
        ),
      ];

  /// Get achievements by tier
  static List<Achievement> getAchievementsByTier(AchievementTier tier) {
    return allAchievements.where((achievement) => achievement.tier == tier).toList();
  }

  /// Get achievements by type
  static List<Achievement> getAchievementsByType(AchievementType type) {
    return allAchievements.where((achievement) => achievement.type == type).toList();
  }

  /// Get total points value for an achievement based on tier
  static int getAchievementPoints(Achievement achievement) {
    switch (achievement.tier) {
      case AchievementTier.bronze:
        return 10;
      case AchievementTier.silver:
        return 25;
      case AchievementTier.gold:
        return 50;
      case AchievementTier.platinum:
        return 100;
    }
  }

  /// Get total possible points
  static int get totalPossiblePoints {
    return allAchievements.fold(0, (sum, achievement) => sum + getAchievementPoints(achievement));
  }
}
