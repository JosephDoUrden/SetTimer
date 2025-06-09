enum TimerState { idle, running, paused, resting, completed }

class TimerModel {
  final int totalSets;
  final int setDurationSeconds;
  final int restDurationSeconds;
  final int restAfterSets;

  int currentSet;
  int remainingSeconds;
  TimerState state;
  bool isInRestPeriod;

  TimerModel({
    required this.totalSets,
    required this.setDurationSeconds,
    required this.restDurationSeconds,
    required this.restAfterSets,
    this.currentSet = 1,
    int? remainingSeconds,
    this.state = TimerState.idle,
    this.isInRestPeriod = false,
  }) : remainingSeconds = remainingSeconds ?? setDurationSeconds;

  TimerModel copyWith({
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
    int? currentSet,
    int? remainingSeconds,
    TimerState? state,
    bool? isInRestPeriod,
  }) {
    return TimerModel(
      totalSets: totalSets ?? this.totalSets,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      restAfterSets: restAfterSets ?? this.restAfterSets,
      currentSet: currentSet ?? this.currentSet,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      state: state ?? this.state,
      isInRestPeriod: isInRestPeriod ?? this.isInRestPeriod,
    );
  }

  double get progress => currentSet / totalSets;
  bool get isCompleted => currentSet > totalSets;
  bool get shouldRest => currentSet % restAfterSets == 0 && currentSet < totalSets;
}
