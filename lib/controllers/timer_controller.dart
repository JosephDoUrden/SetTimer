import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_model.dart';
import '../models/preset_model.dart';
import '../services/audio_service.dart';
import '../services/background_service.dart';
import '../services/voice_coaching_service.dart';

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
  final VoiceCoachingService _voiceCoachingService = VoiceCoachingService();

  DateTime? _pausedAt;

  TimerModel get timer => _timer;
  AudioService get audioService => _audioService;
  VoiceCoachingService get voiceCoachingService => _voiceCoachingService;

  // Initialize the timer controller
  Future<void> initialize() async {
    await _audioService.initialize();
    await _voiceCoachingService.initialize();
  }

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
      _voiceCoachingService.announceSetStart();
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
        // Play countdown sound for last 3 seconds
        if (_timer.remainingSeconds <= 3 && _timer.remainingSeconds > 0) {
          _audioService.playCountdown();
          _voiceCoachingService.announceCountdown(_timer.remainingSeconds);
        }

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
    _voiceCoachingService.announceSetEnd();

    // Announce progress
    _voiceCoachingService.announceProgress(_timer.currentSet, _timer.totalSets);

    // Mevcut set tamamlandı, şimdi kontrol et
    if (_timer.currentSet >= _timer.totalSets) {
      _completeWorkout();
    } else if (_timer.shouldRest) {
      _startRestPeriod();
    } else {
      _startNextSet();
    }
  }

  void _handleRestComplete() {
    _audioService.playRestEnd();
    _voiceCoachingService.announceRestEnd();
    _startNextSet();
  }

  void _startRestPeriod() {
    _timer = _timer.copyWith(
      state: TimerState.resting,
      isInRestPeriod: true,
      remainingSeconds: _timer.restDurationSeconds,
    );
    _audioService.playRestStart();
    _voiceCoachingService.announceRestStart();
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
    _voiceCoachingService.announceSetStart();
    notifyListeners();
  }

  void _completeWorkout() {
    _countdownTimer?.cancel();
    _pausedAt = null;

    // Unregister from app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

    _timer = _timer.copyWith(state: TimerState.completed);
    _audioService.playWorkoutComplete();
    _voiceCoachingService.announceWorkoutComplete();
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

  /// Get current timer settings as a PresetModel for saving as template
  PresetModel getCurrentSettingsAsPreset({
    required String name,
    required String description,
    String category = 'Custom',
    String? iconName,
  }) {
    return PresetModel.createCustom(
      name: name,
      description: description,
      totalSets: _timer.totalSets,
      setDurationSeconds: _timer.setDurationSeconds,
      restDurationSeconds: _timer.restDurationSeconds,
      restAfterSets: _timer.restAfterSets,
      category: category,
      iconName: iconName,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioService.stopAllSounds();
    _voiceCoachingService.stop();
    _backgroundService.disableBackgroundMode();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
