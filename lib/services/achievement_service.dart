import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement_model.dart';
import '../models/workout_session_model.dart';
import 'database_service.dart';
import 'workout_session_service.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final WorkoutSessionService _sessionService = WorkoutSessionService();

  final StreamController<Achievement> _achievementUnlockedController = StreamController<Achievement>.broadcast();
  Stream<Achievement> get achievementUnlocked => _achievementUnlockedController.stream;

  final StreamController<List<Achievement>> _achievementProgressController = StreamController<List<Achievement>>.broadcast();
  Stream<List<Achievement>> get achievementProgress => _achievementProgressController.stream;

  List<Achievement> _achievements = [];
  bool _isInitialized = false;
  Map<String, dynamic> _personalStats = {};

  /// Initialize the achievement system
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadAchievements();
    _isInitialized = true;
  }

  /// Load achievements from database or create defaults
  Future<void> _loadAchievements() async {
    // In a real implementation, this would load from database
    // For now, we'll initialize with default achievements and calculate progress
    _achievements = AchievementDefinitions.allAchievements.map((achievement) {
      return achievement.copyWith(); // Create mutable copies
    }).toList();

    await _updateAllAchievementProgress();
  }

  /// Get all achievements with current progress
  Future<List<Achievement>> getAllAchievements() async {
    if (!_isInitialized) await initialize();
    return List.from(_achievements);
  }

  /// Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  /// Get achievements by type
  Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.type == type).toList();
  }

  /// Get recently unlocked achievements (last 7 days)
  Future<List<Achievement>> getRecentlyUnlockedAchievements() async {
    final achievements = await getUnlockedAchievements();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return achievements.where((a) => a.unlockedAt != null && a.unlockedAt!.isAfter(sevenDaysAgo)).toList();
  }

  /// Update achievement progress after workout completion
  Future<List<Achievement>> updateAchievementProgress() async {
    if (!_isInitialized) await initialize();

    await _updateAllAchievementProgress();

    // Check for newly unlocked achievements
    final newlyUnlocked = <Achievement>[];
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (!achievement.isUnlocked && achievement.isCompleted) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        _achievements[i] = unlockedAchievement;
        newlyUnlocked.add(unlockedAchievement);

        // Show achievement notification
        await _showAchievementNotification(unlockedAchievement);

        // Emit achievement unlocked event
        _achievementUnlockedController.add(unlockedAchievement);
      }
    }

    // Emit progress update
    _achievementProgressController.add(List.from(_achievements));

    return newlyUnlocked;
  }

  /// Update progress for all achievements
  Future<void> _updateAllAchievementProgress() async {
    final analytics = await _sessionService.getAdvancedAnalytics();
    final personalBests = await _sessionService.getPersonalBests();
    final streak = await _sessionService.getWorkoutStreak();
    final sessions = await _sessionService.getWorkoutHistory(limit: null);

    // Store personal stats for complex calculations
    _personalStats = {
      'analytics': analytics,
      'personalBests': personalBests,
      'streak': streak,
      'sessions': sessions,
    };

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      int currentProgress = await _calculateAchievementProgress(achievement);
      _achievements[i] = achievement.copyWith(currentProgress: currentProgress);
    }
  }

  /// Calculate progress for a specific achievement
  Future<int> _calculateAchievementProgress(Achievement achievement) async {
    switch (achievement.type) {
      case AchievementType.streak:
        return _personalStats['streak'] as int;

      case AchievementType.totalWorkouts:
        return (_personalStats['analytics'] as Map<String, dynamic>)['totalWorkouts'] as int;

      case AchievementType.totalTime:
        return (_personalStats['analytics'] as Map<String, dynamic>)['totalWorkoutTime'] as int;

      case AchievementType.completion:
        return ((_personalStats['analytics'] as Map<String, dynamic>)['averageCompletionRate'] as double).round();

      case AchievementType.consistency:
        return ((_personalStats['analytics'] as Map<String, dynamic>)['workoutConsistency'] as double).round();

      case AchievementType.personal:
        return await _getPersonalAchievementProgress(achievement);
    }
  }

  /// Get progress for personal achievements with detailed tracking
  Future<int> _getPersonalAchievementProgress(Achievement achievement) async {
    final personalBests = _personalStats['personalBests'] as Map<String, dynamic>;
    final sessions = _personalStats['sessions'] as List<WorkoutSession>;

    switch (achievement.id) {
      case 'longest_workout':
        return personalBests['longestWorkout'] as int;

      case 'most_sets_50':
      case 'most_sets_100':
        return personalBests['mostSetsCompleted'] as int;

      case 'speed_demon':
        // Check if user completed 20 sets in under 10 minutes
        return _checkSpeedDemonAchievement(sessions) ? 1 : 0;

      case 'early_bird':
        return _countEarlyMorningWorkouts(sessions);

      case 'night_owl':
        return _countLateNightWorkouts(sessions);

      case 'weekend_warrior_special':
        return _countWeekendWorkouts(sessions);

      case 'preset_explorer':
        return _countUniquePresets(sessions);

      default:
        return 0;
    }
  }

  /// Check if user achieved speed demon (20 sets in under 10 minutes)
  bool _checkSpeedDemonAchievement(List<WorkoutSession> sessions) {
    for (final session in sessions) {
      if (session.completedSets >= 20 && session.actualWorkoutDurationSeconds <= 600) {
        return true;
      }
    }
    return false;
  }

  /// Count workouts completed before 7 AM
  int _countEarlyMorningWorkouts(List<WorkoutSession> sessions) {
    return sessions.where((session) => session.isCompleted && session.startTime.hour < 7).length;
  }

  /// Count workouts completed after 10 PM
  int _countLateNightWorkouts(List<WorkoutSession> sessions) {
    return sessions.where((session) => session.isCompleted && session.startTime.hour >= 22).length;
  }

  /// Count workouts completed on weekends
  int _countWeekendWorkouts(List<WorkoutSession> sessions) {
    final weekendDates = <String>{};
    for (final session in sessions) {
      if (session.isCompleted && (session.startTime.weekday == 6 || session.startTime.weekday == 7)) {
        final dateKey = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
        weekendDates.add(dateKey);
      }
    }
    return weekendDates.length;
  }

  /// Count unique presets used
  int _countUniquePresets(List<WorkoutSession> sessions) {
    final uniquePresets =
        sessions.where((session) => session.isCompleted && session.presetId != null).map((session) => session.presetId).toSet();
    return uniquePresets.length;
  }

  /// Show achievement notification with haptic feedback
  Future<void> _showAchievementNotification(Achievement achievement) async {
    // Haptic feedback for achievement unlock
    await HapticFeedback.mediumImpact();

    // In a real app, you would show a proper notification dialog or snackbar
    // TODO: Implement proper notification system
    // For now, we'll use debug prints in development
    if (kDebugMode) {
      debugPrint('🏆 Achievement Unlocked: ${achievement.title}');
      debugPrint('   ${achievement.description}');
      debugPrint('   Tier: ${achievement.tier.name.toUpperCase()}');
      debugPrint('   Points: ${AchievementDefinitions.getAchievementPoints(achievement)}');
    }
  }

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStatistics() async {
    final achievements = await getAllAchievements();
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();

    final tierCounts = <AchievementTier, int>{};
    final typeCounts = <AchievementType, int>{};
    int totalPoints = 0;

    for (final achievement in unlockedAchievements) {
      tierCounts[achievement.tier] = (tierCounts[achievement.tier] ?? 0) + 1;
      typeCounts[achievement.type] = (typeCounts[achievement.type] ?? 0) + 1;
      totalPoints += AchievementDefinitions.getAchievementPoints(achievement);
    }

    return {
      'totalAchievements': achievements.length,
      'unlockedAchievements': unlockedAchievements.length,
      'completionPercentage': (unlockedAchievements.length / achievements.length * 100).round(),
      'tierCounts': tierCounts,
      'typeCounts': typeCounts,
      'recentlyUnlocked': (await getRecentlyUnlockedAchievements()).length,
      'totalPoints': totalPoints,
      'totalPossiblePoints': AchievementDefinitions.totalPossiblePoints,
      'pointsPercentage': (totalPoints / AchievementDefinitions.totalPossiblePoints * 100).round(),
    };
  }

  /// Get next achievement to unlock for motivation
  Future<Achievement?> getNextAchievementToUnlock() async {
    final achievements = await getAllAchievements();
    final lockedAchievements = achievements.where((a) => !a.isUnlocked).toList();

    if (lockedAchievements.isEmpty) return null;

    // Sort by progress percentage (closest to completion first)
    lockedAchievements.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));

    return lockedAchievements.first;
  }

  /// Get achievements close to unlocking (above 80% progress)
  Future<List<Achievement>> getAchievementsCloseToUnlocking() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => !a.isUnlocked && a.progressPercentage >= 80).toList();
  }

  /// Get user's achievement level based on total points
  Future<Map<String, dynamic>> getUserAchievementLevel() async {
    final stats = await getAchievementStatistics();
    final totalPoints = stats['totalPoints'] as int;

    String level;
    String nextLevel;
    int pointsForNext;

    if (totalPoints < 100) {
      level = 'Beginner';
      nextLevel = 'Bronze';
      pointsForNext = 100 - totalPoints;
    } else if (totalPoints < 300) {
      level = 'Bronze';
      nextLevel = 'Silver';
      pointsForNext = 300 - totalPoints;
    } else if (totalPoints < 600) {
      level = 'Silver';
      nextLevel = 'Gold';
      pointsForNext = 600 - totalPoints;
    } else if (totalPoints < 1000) {
      level = 'Gold';
      nextLevel = 'Platinum';
      pointsForNext = 1000 - totalPoints;
    } else {
      level = 'Platinum';
      nextLevel = 'Legend';
      pointsForNext = 0;
    }

    return {
      'currentLevel': level,
      'nextLevel': nextLevel,
      'currentPoints': totalPoints,
      'pointsForNext': pointsForNext,
      'progress': pointsForNext > 0 ? (totalPoints / (totalPoints + pointsForNext) * 100).round() : 100,
    };
  }

  /// Format achievement progress text
  String formatAchievementProgress(Achievement achievement) {
    switch (achievement.unit) {
      case 'seconds':
        final currentHours = achievement.currentProgress ~/ 3600;
        final currentMinutes = (achievement.currentProgress % 3600) ~/ 60;
        final targetHours = achievement.targetValue ~/ 3600;
        final targetMinutes = (achievement.targetValue % 3600) ~/ 60;

        if (targetHours > 0) {
          return '${currentHours}h ${currentMinutes}m / ${targetHours}h ${targetMinutes}m';
        } else {
          return '${currentMinutes}m / ${targetMinutes}m';
        }

      case 'days':
      case 'workouts':
      case 'sets':
      case 'weekends':
      case 'presets':
        return '${achievement.currentProgress} / ${achievement.targetValue} ${achievement.unit}';

      case 'percent':
        return '${achievement.currentProgress}% / ${achievement.targetValue}%';

      case 'achievement':
        return achievement.isCompleted ? 'Completed!' : 'Not completed';

      default:
        return '${achievement.currentProgress} / ${achievement.targetValue}';
    }
  }

  /// Get motivation message based on progress
  String getMotivationMessage(Achievement achievement) {
    final progress = achievement.progressPercentage;

    if (achievement.isUnlocked) {
      return 'Achievement unlocked! 🏆';
    } else if (progress >= 90) {
      return 'So close! You\'ve got this! 💪';
    } else if (progress >= 70) {
      return 'Great progress! Keep it up! 🔥';
    } else if (progress >= 50) {
      return 'Halfway there! 📈';
    } else if (progress >= 25) {
      return 'Making progress! 🚀';
    } else if (progress > 0) {
      return 'Good start! Keep going! ⭐';
    } else {
      return 'Ready to start this challenge? 💡';
    }
  }

  /// Dispose resources
  void dispose() {
    _achievementUnlockedController.close();
    _achievementProgressController.close();
  }
}

/// Dialog to show when an achievement is unlocked
class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementUnlockedDialog> createState() => _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.1,
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF2A2A2A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.achievement.color.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.achievement.color.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Achievement Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.achievement.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.achievement.color,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        widget.achievement.icon,
                        size: 40,
                        color: widget.achievement.color,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Achievement Unlocked Text
                    Text(
                      'Achievement Unlocked!',
                      style: TextStyle(
                        color: widget.achievement.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Achievement Title
                    Text(
                      widget.achievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Achievement Description
                    Text(
                      widget.achievement.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Close Button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.achievement.color,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
