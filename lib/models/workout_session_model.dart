import 'package:uuid/uuid.dart';

enum SessionStatus { inProgress, completed, paused, abandoned }

class WorkoutSession {
  final String id;
  final String? presetId;
  final String? presetName;
  final int totalSets;
  final int setDurationSeconds;
  final int restDurationSeconds;
  final int restAfterSets;
  final int completedSets;
  final SessionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalPausedDurationSeconds;
  final int actualWorkoutDurationSeconds;
  final double completionPercentage;
  final Map<String, dynamic>? metadata;

  WorkoutSession({
    String? id,
    this.presetId,
    this.presetName,
    required this.totalSets,
    required this.setDurationSeconds,
    required this.restDurationSeconds,
    required this.restAfterSets,
    this.completedSets = 0,
    this.status = SessionStatus.inProgress,
    DateTime? startTime,
    this.endTime,
    this.totalPausedDurationSeconds = 0,
    this.actualWorkoutDurationSeconds = 0,
    double? completionPercentage,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        completionPercentage = completionPercentage ?? (completedSets / totalSets * 100);

  WorkoutSession copyWith({
    String? id,
    String? presetId,
    String? presetName,
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
    int? completedSets,
    SessionStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? totalPausedDurationSeconds,
    int? actualWorkoutDurationSeconds,
    double? completionPercentage,
    Map<String, dynamic>? metadata,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      presetName: presetName ?? this.presetName,
      totalSets: totalSets ?? this.totalSets,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      restAfterSets: restAfterSets ?? this.restAfterSets,
      completedSets: completedSets ?? this.completedSets,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPausedDurationSeconds: totalPausedDurationSeconds ?? this.totalPausedDurationSeconds,
      actualWorkoutDurationSeconds: actualWorkoutDurationSeconds ?? this.actualWorkoutDurationSeconds,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'presetId': presetId,
      'presetName': presetName,
      'totalSets': totalSets,
      'setDurationSeconds': setDurationSeconds,
      'restDurationSeconds': restDurationSeconds,
      'restAfterSets': restAfterSets,
      'completedSets': completedSets,
      'status': status.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalPausedDurationSeconds': totalPausedDurationSeconds,
      'actualWorkoutDurationSeconds': actualWorkoutDurationSeconds,
      'completionPercentage': completionPercentage,
      'metadata': metadata?.toString(),
    };
  }

  // Create from JSON (database)
  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      presetId: json['presetId'],
      presetName: json['presetName'],
      totalSets: json['totalSets'],
      setDurationSeconds: json['setDurationSeconds'],
      restDurationSeconds: json['restDurationSeconds'],
      restAfterSets: json['restAfterSets'],
      completedSets: json['completedSets'],
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.inProgress,
      ),
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      totalPausedDurationSeconds: json['totalPausedDurationSeconds'],
      actualWorkoutDurationSeconds: json['actualWorkoutDurationSeconds'],
      completionPercentage: json['completionPercentage']?.toDouble() ?? 0.0,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  // Convenience getters
  Duration get totalDuration => endTime != null ? endTime!.difference(startTime) : DateTime.now().difference(startTime);

  Duration get actualWorkoutDuration => Duration(seconds: actualWorkoutDurationSeconds);
  Duration get totalPausedDuration => Duration(seconds: totalPausedDurationSeconds);

  bool get isCompleted => status == SessionStatus.completed;
  bool get isInProgress => status == SessionStatus.inProgress;
  bool get isPaused => status == SessionStatus.paused;
  bool get isAbandoned => status == SessionStatus.abandoned;

  String get formattedDuration {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get workoutTypeDescription {
    if (presetName != null && presetName!.isNotEmpty) {
      return presetName!;
    }
    return 'Custom Workout';
  }

  @override
  String toString() {
    return 'WorkoutSession(id: $id, sets: $completedSets/$totalSets, status: $status, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
