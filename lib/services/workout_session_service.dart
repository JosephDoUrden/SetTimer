import 'dart:async';
import '../models/workout_session_model.dart';
import '../models/timer_model.dart';
import '../models/preset_model.dart';
import 'database_service.dart';

class WorkoutSessionService {
  static final WorkoutSessionService _instance = WorkoutSessionService._internal();
  factory WorkoutSessionService() => _instance;
  WorkoutSessionService._internal();

  final DatabaseService _databaseService = DatabaseService();

  WorkoutSession? _currentSession;
  DateTime? _lastPauseTime;
  int _totalPausedSeconds = 0;
  int _actualWorkoutSeconds = 0;
  Timer? _workoutTimer;

  WorkoutSession? get currentSession => _currentSession;
  bool get hasActiveSession =>
      _currentSession != null && (_currentSession!.status == SessionStatus.inProgress || _currentSession!.status == SessionStatus.paused);

  /// Start a new workout session
  Future<WorkoutSession> startSession({
    required TimerModel timer,
    PresetModel? preset,
  }) async {
    // End any existing session first
    if (_currentSession != null) {
      await _endCurrentSession(SessionStatus.abandoned);
    }

    // Create new session
    _currentSession = WorkoutSession(
      presetId: preset?.id,
      presetName: preset?.name,
      totalSets: timer.totalSets,
      setDurationSeconds: timer.setDurationSeconds,
      restDurationSeconds: timer.restDurationSeconds,
      restAfterSets: timer.restAfterSets,
      status: SessionStatus.inProgress,
    );

    // Reset tracking variables
    _totalPausedSeconds = 0;
    _actualWorkoutSeconds = 0;
    _lastPauseTime = null;

    // Start workout timer
    _startWorkoutTimer();

    // Save to database
    await _databaseService.saveWorkoutSession(_currentSession!);

    print('📊 Started new workout session: ${_currentSession!.id}');
    return _currentSession!;
  }

  /// Update session progress (called when set completes)
  Future<void> updateSessionProgress(int completedSets) async {
    if (_currentSession == null) return;

    final completionPercentage = (completedSets / _currentSession!.totalSets) * 100;

    _currentSession = _currentSession!.copyWith(
      completedSets: completedSets,
      completionPercentage: completionPercentage,
      actualWorkoutDurationSeconds: _actualWorkoutSeconds,
      totalPausedDurationSeconds: _totalPausedSeconds,
    );

    // Update in database
    await _databaseService.updateWorkoutSession(_currentSession!);

    print('📊 Updated session progress: $completedSets/${_currentSession!.totalSets} sets (${completionPercentage.toStringAsFixed(1)}%)');
  }

  /// Pause the current session
  Future<void> pauseSession() async {
    if (_currentSession == null || _currentSession!.status != SessionStatus.inProgress) return;

    _lastPauseTime = DateTime.now();
    _workoutTimer?.cancel();

    _currentSession = _currentSession!.copyWith(
      status: SessionStatus.paused,
      actualWorkoutDurationSeconds: _actualWorkoutSeconds,
      totalPausedDurationSeconds: _totalPausedSeconds,
    );

    await _databaseService.updateWorkoutSession(_currentSession!);

    print('📊 Paused workout session: ${_currentSession!.id}');
  }

  /// Resume the current session
  Future<void> resumeSession() async {
    if (_currentSession == null || _currentSession!.status != SessionStatus.paused) return;

    // Calculate paused duration
    if (_lastPauseTime != null) {
      final pausedDuration = DateTime.now().difference(_lastPauseTime!);
      _totalPausedSeconds += pausedDuration.inSeconds;
      _lastPauseTime = null;
    }

    _currentSession = _currentSession!.copyWith(
      status: SessionStatus.inProgress,
      totalPausedDurationSeconds: _totalPausedSeconds,
    );

    // Resume workout timer
    _startWorkoutTimer();

    await _databaseService.updateWorkoutSession(_currentSession!);

    print('📊 Resumed workout session: ${_currentSession!.id}');
  }

  /// Complete the current session
  Future<void> completeSession() async {
    if (_currentSession == null) return;

    // Store session ID before clearing it
    final sessionId = _currentSession!.id;

    await _endCurrentSession(SessionStatus.completed);
    print('📊 Completed workout session: $sessionId');
  }

  /// Abandon the current session
  Future<void> abandonSession() async {
    if (_currentSession == null) return;

    // Store session ID before clearing it
    final sessionId = _currentSession!.id;

    await _endCurrentSession(SessionStatus.abandoned);
    print('📊 Abandoned workout session: $sessionId');
  }

  /// End the current session with given status
  Future<void> _endCurrentSession(SessionStatus status) async {
    if (_currentSession == null) return;

    _workoutTimer?.cancel();

    // Calculate final durations
    if (_lastPauseTime != null) {
      final pausedDuration = DateTime.now().difference(_lastPauseTime!);
      _totalPausedSeconds += pausedDuration.inSeconds;
    }

    _currentSession = _currentSession!.copyWith(
      status: status,
      endTime: DateTime.now(),
      actualWorkoutDurationSeconds: _actualWorkoutSeconds,
      totalPausedDurationSeconds: _totalPausedSeconds,
    );

    await _databaseService.updateWorkoutSession(_currentSession!);

    // Clear current session
    _currentSession = null;
    _lastPauseTime = null;
    _totalPausedSeconds = 0;
    _actualWorkoutSeconds = 0;
  }

  /// Start tracking actual workout time
  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession?.status == SessionStatus.inProgress) {
        _actualWorkoutSeconds++;
      }
    });
  }

  /// Get workout history with pagination
  Future<List<WorkoutSession>> getWorkoutHistory({
    int? limit = 20,
    int? offset = 0,
  }) async {
    return await _databaseService.getAllWorkoutSessions(
      limit: limit,
      offset: offset,
    );
  }

  /// Get workout sessions for a specific date range
  Future<List<WorkoutSession>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _databaseService.getWorkoutSessionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get workout statistics
  Future<Map<String, dynamic>> getWorkoutStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _databaseService.getWorkoutStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get today's workout sessions
  Future<List<WorkoutSession>> getTodaysWorkouts() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getSessionsByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Get this week's workout sessions
  Future<List<WorkoutSession>> getThisWeeksWorkouts() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday + 1);
    final endOfWeek = DateTime(now.year, now.month, now.day + (7 - now.weekday), 23, 59, 59);

    return await getSessionsByDateRange(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  /// Get this month's workout sessions
  Future<List<WorkoutSession>> getThisMonthsWorkouts() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await getSessionsByDateRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Delete a workout session
  Future<void> deleteSession(String sessionId) async {
    await _databaseService.deleteWorkoutSession(sessionId);
  }

  /// Get workout streak (consecutive days with completed workouts)
  Future<int> getWorkoutStreak() async {
    final sessions = await _databaseService.getAllWorkoutSessions();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();

    if (completedSessions.isEmpty) return 0;

    // Group sessions by date
    final sessionsByDate = <String, List<WorkoutSession>>{};
    for (final session in completedSessions) {
      final dateKey = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      sessionsByDate[dateKey] = (sessionsByDate[dateKey] ?? [])..add(session);
    }

    // Sort dates in descending order
    final sortedDates = sessionsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    // Count consecutive days
    int streak = 0;
    DateTime? lastDate;

    for (final dateKey in sortedDates) {
      final parts = dateKey.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (lastDate == null) {
        // First date
        streak = 1;
        lastDate = date;
      } else {
        // Check if this date is consecutive to the last date
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = date;
        } else {
          break; // Streak broken
        }
      }
    }

    return streak;
  }

  /// Get personal best metrics
  Future<Map<String, dynamic>> getPersonalBests() async {
    final sessions = await _databaseService.getAllWorkoutSessions();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();

    if (completedSessions.isEmpty) {
      return {
        'longestWorkout': 0,
        'mostSetsCompleted': 0,
        'bestCompletionRate': 0.0,
        'longestStreak': await getWorkoutStreak(),
      };
    }

    // Find longest workout
    final longestWorkout = completedSessions.map((s) => s.actualWorkoutDurationSeconds).reduce((a, b) => a > b ? a : b);

    // Find most sets completed
    final mostSetsCompleted = completedSessions.map((s) => s.completedSets).reduce((a, b) => a > b ? a : b);

    // Calculate best completion rate
    final bestCompletionRate = completedSessions.map((s) => s.completionPercentage).reduce((a, b) => a > b ? a : b);

    return {
      'longestWorkout': longestWorkout,
      'mostSetsCompleted': mostSetsCompleted,
      'bestCompletionRate': bestCompletionRate,
      'longestStreak': await getWorkoutStreak(),
    };
  }

  /// Restore session from database on app restart
  Future<void> restoreActiveSession() async {
    final activeSession = await _databaseService.getCurrentActiveSession();
    if (activeSession != null) {
      _currentSession = activeSession;

      // If session was in progress, mark as paused since app was closed
      if (_currentSession!.status == SessionStatus.inProgress) {
        await pauseSession();
      }

      print('📊 Restored active session: ${_currentSession!.id}');
    }
  }

  /// Get advanced workout analytics
  Future<Map<String, dynamic>> getAdvancedAnalytics() async {
    final sessions = await _databaseService.getAllWorkoutSessions();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();

    if (completedSessions.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalWorkoutTime': 0,
        'averageWorkoutTime': 0,
        'averageCompletionRate': 0.0,
        'mostUsedPresets': <String, int>{},
        'workoutFrequency': <String, int>{},
        'monthlyProgress': <String, Map<String, dynamic>>{},
        'weeklyProgress': <String, Map<String, dynamic>>{},
        'timeOfDayDistribution': <String, int>{},
        'workoutConsistency': 0.0,
      };
    }

    // Basic totals
    final totalWorkouts = completedSessions.length;
    final totalWorkoutTime = completedSessions.fold(0, (sum, s) => sum + s.actualWorkoutDurationSeconds);
    final averageWorkoutTime = totalWorkoutTime ~/ totalWorkouts;
    final averageCompletionRate = completedSessions.fold(0.0, (sum, s) => sum + s.completionPercentage) / totalWorkouts;

    // Most used presets
    final presetUsage = <String, int>{};
    for (final session in completedSessions) {
      if (session.presetName != null) {
        presetUsage[session.presetName!] = (presetUsage[session.presetName!] ?? 0) + 1;
      }
    }

    // Workout frequency by day of week
    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final workoutFrequency = <String, int>{};
    for (final session in completedSessions) {
      final weekdayName = weekdayNames[session.startTime.weekday - 1];
      workoutFrequency[weekdayName] = (workoutFrequency[weekdayName] ?? 0) + 1;
    }

    // Monthly progress
    final monthlyProgress = <String, Map<String, dynamic>>{};
    for (final session in completedSessions) {
      final monthKey = '${session.startTime.year}-${session.startTime.month.toString().padLeft(2, '0')}';
      if (!monthlyProgress.containsKey(monthKey)) {
        monthlyProgress[monthKey] = {
          'workouts': 0,
          'totalTime': 0,
          'averageCompletion': 0.0,
          'sessionsData': <WorkoutSession>[],
        };
      }
      monthlyProgress[monthKey]!['workouts'] = (monthlyProgress[monthKey]!['workouts'] as int) + 1;
      monthlyProgress[monthKey]!['totalTime'] = (monthlyProgress[monthKey]!['totalTime'] as int) + session.actualWorkoutDurationSeconds;
      (monthlyProgress[monthKey]!['sessionsData'] as List<WorkoutSession>).add(session);
    }

    // Calculate average completion for each month
    monthlyProgress.forEach((key, data) {
      final sessions = data['sessionsData'] as List<WorkoutSession>;
      data['averageCompletion'] = sessions.fold(0.0, (sum, s) => sum + s.completionPercentage) / sessions.length;
      data.remove('sessionsData'); // Remove the temporary data
    });

    // Weekly progress (last 12 weeks)
    final weeklyProgress = <String, Map<String, dynamic>>{};
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final weekKey = 'Week ${weekStart.month}/${weekStart.day}';

      final weekSessions = completedSessions
          .where((s) => s.startTime.isAfter(weekStart) && s.startTime.isBefore(weekEnd.add(const Duration(days: 1))))
          .toList();

      weeklyProgress[weekKey] = {
        'workouts': weekSessions.length,
        'totalTime': weekSessions.fold(0, (sum, s) => sum + s.actualWorkoutDurationSeconds),
        'averageCompletion':
            weekSessions.isEmpty ? 0.0 : weekSessions.fold(0.0, (sum, s) => sum + s.completionPercentage) / weekSessions.length,
      };
    }

    // Time of day distribution
    final timeOfDayDistribution = <String, int>{
      'Morning (6-12)': 0,
      'Afternoon (12-18)': 0,
      'Evening (18-24)': 0,
      'Night (0-6)': 0,
    };

    for (final session in completedSessions) {
      final hour = session.startTime.hour;
      if (hour >= 6 && hour < 12) {
        timeOfDayDistribution['Morning (6-12)'] = timeOfDayDistribution['Morning (6-12)']! + 1;
      } else if (hour >= 12 && hour < 18) {
        timeOfDayDistribution['Afternoon (12-18)'] = timeOfDayDistribution['Afternoon (12-18)']! + 1;
      } else if (hour >= 18) {
        timeOfDayDistribution['Evening (18-24)'] = timeOfDayDistribution['Evening (18-24)']! + 1;
      } else {
        timeOfDayDistribution['Night (0-6)'] = timeOfDayDistribution['Night (0-6)']! + 1;
      }
    }

    // Workout consistency (percentage of days with workouts in last 30 days)
    final last30Days = now.subtract(const Duration(days: 30));
    final recentSessions = completedSessions.where((s) => s.startTime.isAfter(last30Days)).toList();
    final uniqueDays = recentSessions.map((s) => '${s.startTime.year}-${s.startTime.month}-${s.startTime.day}').toSet();
    final workoutConsistency = (uniqueDays.length / 30.0) * 100;

    return {
      'totalWorkouts': totalWorkouts,
      'totalWorkoutTime': totalWorkoutTime,
      'averageWorkoutTime': averageWorkoutTime,
      'averageCompletionRate': averageCompletionRate,
      'mostUsedPresets': presetUsage,
      'workoutFrequency': workoutFrequency,
      'monthlyProgress': monthlyProgress,
      'weeklyProgress': weeklyProgress,
      'timeOfDayDistribution': timeOfDayDistribution,
      'workoutConsistency': workoutConsistency,
    };
  }

  /// Get workout intensity analysis
  Future<Map<String, dynamic>> getWorkoutIntensityAnalysis() async {
    final sessions = await _databaseService.getAllWorkoutSessions();
    final completedSessions = sessions.where((s) => s.status == SessionStatus.completed).toList();

    if (completedSessions.isEmpty) {
      return {
        'intensityTrend': <String, double>{},
        'averageIntensity': 0.0,
        'intensityDistribution': <String, int>{},
      };
    }

    // Calculate intensity based on completion rate and workout duration
    final intensityTrend = <String, double>{};
    final intensityDistribution = <String, int>{'Low': 0, 'Medium': 0, 'High': 0};

    for (final session in completedSessions) {
      final dateKey = '${session.startTime.month}/${session.startTime.day}';

      // Intensity score based on completion rate and relative workout duration
      final intensityScore =
          (session.completionPercentage / 100) * (session.actualWorkoutDurationSeconds / 1800.0); // Normalize to 30 minutes

      intensityTrend[dateKey] = intensityScore;

      // Categorize intensity
      if (intensityScore < 0.3) {
        intensityDistribution['Low'] = intensityDistribution['Low']! + 1;
      } else if (intensityScore < 0.7) {
        intensityDistribution['Medium'] = intensityDistribution['Medium']! + 1;
      } else {
        intensityDistribution['High'] = intensityDistribution['High']! + 1;
      }
    }

    final averageIntensity = intensityTrend.values.fold(0.0, (sum, val) => sum + val) / intensityTrend.length;

    return {
      'intensityTrend': intensityTrend,
      'averageIntensity': averageIntensity,
      'intensityDistribution': intensityDistribution,
    };
  }

  /// Dispose resources
  void dispose() {
    _workoutTimer?.cancel();
    _currentSession = null;
  }
}
