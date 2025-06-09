import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer_model.dart';
import '../services/audio_service.dart';
import '../services/background_service.dart';

class TimerController extends ChangeNotifier {
  TimerModel _timer = TimerModel(
    totalSets: 3,
    setDurationSeconds: 30,
    restDurationSeconds: 10,
    restAfterSets: 1,
  );

  Timer? _countdownTimer;
  final AudioService _audioService = AudioService();
  final BackgroundService _backgroundService = BackgroundService();

  TimerModel get timer => _timer;

  void updateTimerSettings({
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
  }) {
    _timer = _timer.copyWith(
      totalSets: totalSets,
      setDurationSeconds: setDurationSeconds,
      restDurationSeconds: restDurationSeconds,
      restAfterSets: restAfterSets,
      remainingSeconds: setDurationSeconds ?? _timer.setDurationSeconds,
      state: TimerState.idle,
      currentSet: 1,
      isInRestPeriod: false,
    );
    notifyListeners();
  }

  void startTimer() {
    if (_timer.state == TimerState.idle || _timer.state == TimerState.paused) {
      _timer = _timer.copyWith(state: TimerState.running);
      _audioService.playSetStart();
      _backgroundService.enableBackgroundMode();
      _startCountdown();
      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_timer.state == TimerState.running || _timer.state == TimerState.resting) {
      _countdownTimer?.cancel();
      _timer = _timer.copyWith(state: TimerState.paused);
      notifyListeners();
    }
  }

  void resetTimer() {
    _countdownTimer?.cancel();
    _timer = _timer.copyWith(
      state: TimerState.idle,
      currentSet: 1,
      remainingSeconds: _timer.setDurationSeconds,
      isInRestPeriod: false,
    );
    _backgroundService.disableBackgroundMode();
    notifyListeners();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer.remainingSeconds > 0) {
        _timer = _timer.copyWith(remainingSeconds: _timer.remainingSeconds - 1);
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });
  }

  void _handleTimerComplete() {
    if (_timer.isInRestPeriod) {
      _handleRestComplete();
    } else {
      _handleSetComplete();
    }
  }

  void _handleSetComplete() {
    _audioService.playSetEnd();

    if (_timer.isCompleted) {
      _completeWorkout();
    } else if (_timer.shouldRest) {
      _startRestPeriod();
    } else {
      _startNextSet();
    }
  }

  void _handleRestComplete() {
    _audioService.playRestEnd();
    _startNextSet();
  }

  void _startRestPeriod() {
    _timer = _timer.copyWith(
      state: TimerState.resting,
      isInRestPeriod: true,
      remainingSeconds: _timer.restDurationSeconds,
    );
    _audioService.playRestStart();
    notifyListeners();
  }

  void _startNextSet() {
    _timer = _timer.copyWith(
      currentSet: _timer.currentSet + 1,
      state: TimerState.running,
      isInRestPeriod: false,
      remainingSeconds: _timer.setDurationSeconds,
    );
    _audioService.playSetStart();
    notifyListeners();
  }

  void _completeWorkout() {
    _countdownTimer?.cancel();
    _timer = _timer.copyWith(state: TimerState.completed);
    _audioService.playWorkoutComplete();
    _backgroundService.disableBackgroundMode();
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioService.stopAllSounds();
    _backgroundService.disableBackgroundMode();
    super.dispose();
  }
}
