import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_model.dart';
import '../services/audio_service.dart';
import '../services/background_service.dart';

class TimerController extends ChangeNotifier with WidgetsBindingObserver {
  TimerModel _timer = TimerModel(
    totalSets: 3,
    setDurationSeconds: 30,
    restDurationSeconds: 10,
    restAfterSets: 1,
  );

  Timer? _countdownTimer;
  final AudioService _audioService = AudioService();
  final BackgroundService _backgroundService = BackgroundService();

  DateTime? _pausedAt;

  TimerModel get timer => _timer;

  void updateTimerSettings({
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
  }) {
    // Only update if timer is not running
    if (_timer.state != TimerState.running && _timer.state != TimerState.resting) {
      final newSetDuration = setDurationSeconds ?? _timer.setDurationSeconds;

      _timer = _timer.copyWith(
        totalSets: totalSets,
        setDurationSeconds: newSetDuration,
        restDurationSeconds: restDurationSeconds,
        restAfterSets: restAfterSets,
        remainingSeconds: _timer.state == TimerState.idle ? newSetDuration : _timer.remainingSeconds,
        currentSet: _timer.state == TimerState.idle ? 1 : _timer.currentSet,
        isInRestPeriod: _timer.state == TimerState.idle ? false : _timer.isInRestPeriod,
      );

      print('Settings updated: Sets=$totalSets, Duration=${setDurationSeconds}s, Rest=${restDurationSeconds}s, RestAfter=$restAfterSets');
      notifyListeners();
    } else {
      print('Cannot update settings while timer is running');
    }
  }

  void startTimer() {
    if (_timer.state == TimerState.idle || _timer.state == TimerState.paused) {
      _timer = _timer.copyWith(state: TimerState.running);
      _audioService.playSetStart();
      _backgroundService.enableBackgroundMode();

      // Register for app lifecycle events
      WidgetsBinding.instance.addObserver(this);

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
    _pausedAt = null;

    // Unregister from app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

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
    _pausedAt = null;

    // Unregister from app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

    _timer = _timer.copyWith(state: TimerState.completed);
    _audioService.playWorkoutComplete();
    _backgroundService.disableBackgroundMode();

    // Provide haptic feedback for workout completion
    HapticFeedback.heavyImpact();

    notifyListeners();
  }

  void _handleAppPaused() {
    if (_timer.state == TimerState.running || _timer.state == TimerState.resting) {
      _pausedAt = DateTime.now();
      print('📱 App paused - Timer will continue in background');
    }
  }

  void _handleAppResumed() {
    if (_pausedAt != null && (_timer.state == TimerState.running || _timer.state == TimerState.resting)) {
      final pauseDuration = DateTime.now().difference(_pausedAt!);
      final secondsPassed = pauseDuration.inSeconds;

      if (secondsPassed > 0) {
        _syncTimerAfterBackground(secondsPassed);
      }

      _pausedAt = null;
      print('📱 App resumed - Timer synced after ${secondsPassed}s in background');
    }
  }

  void _handleAppDetached() {
    // Clean up when app is completely closed
    _backgroundService.disableBackgroundMode();
  }

  void _syncTimerAfterBackground(int secondsPassed) {
    int remainingSeconds = _timer.remainingSeconds - secondsPassed;

    while (remainingSeconds <= 0 && !_timer.isCompleted) {
      if (_timer.isInRestPeriod) {
        // Rest period completed
        remainingSeconds += _timer.setDurationSeconds;
        _timer = _timer.copyWith(
          currentSet: _timer.currentSet + 1,
          isInRestPeriod: false,
          state: TimerState.running,
        );
        _audioService.playSetStart();
      } else {
        // Set completed
        if (_timer.currentSet >= _timer.totalSets) {
          // Workout completed
          _completeWorkout();
          return;
        } else if (_timer.shouldRest) {
          // Start rest period
          remainingSeconds += _timer.restDurationSeconds;
          _timer = _timer.copyWith(
            isInRestPeriod: true,
            state: TimerState.resting,
          );
          _audioService.playRestStart();
        } else {
          // Start next set
          remainingSeconds += _timer.setDurationSeconds;
          _timer = _timer.copyWith(
            currentSet: _timer.currentSet + 1,
            state: TimerState.running,
          );
          _audioService.playSetStart();
        }
      }
    }

    _timer = _timer.copyWith(remainingSeconds: remainingSeconds);
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioService.stopAllSounds();
    _backgroundService.disableBackgroundMode();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
