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

  double get progress {
    if (state == TimerState.idle) {
      return 0.0; // Reset durumunda progress sıfır olmalı
    } else if (state == TimerState.completed) {
      return 1.0; // Complete durumunda progress tam olmalı
    } else {
      // Running/paused/resting durumlarında normal hesaplama
      return (currentSet - 1) / totalSets; // currentSet-1 çünkü aktif set henüz tamamlanmadı
    }
  }

  bool get isCompleted => state == TimerState.completed;
  bool get shouldRest => currentSet % restAfterSets == 0 && currentSet < totalSets;
}
