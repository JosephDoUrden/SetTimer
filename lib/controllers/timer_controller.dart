import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timer_model.dart';
import '../models/preset_model.dart';
import '../services/audio_service.dart';
import '../services/background_service.dart';
import '../services/voice_coaching_service.dart';
import '../services/workout_session_service.dart';
import '../services/achievement_service.dart';

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
  final WorkoutSessionService _sessionService = WorkoutSessionService();
  final AchievementService _achievementService = AchievementService();

  DateTime? _pausedAt;
  PresetModel? _currentPreset;

  TimerModel get timer => _timer;
  AudioService get audioService => _audioService;
  VoiceCoachingService get voiceCoachingService => _voiceCoachingService;
  WorkoutSessionService get sessionService => _sessionService;

  // Initialize the timer controller
  Future<void> initialize() async {
    await _audioService.initialize();
    await _voiceCoachingService.initialize();
    await _sessionService.restoreActiveSession();
  }

  void updateTimerSettings({
    int? totalSets,
    int? setDurationSeconds,
    int? restDurationSeconds,
    int? restAfterSets,
    bool clearPreset = true, // Add flag to control preset clearing
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

      // Clear preset when settings are manually changed (unless called from loadPreset)
      if (clearPreset && _currentPreset != null) {
        // Check if the settings still match the current preset
        bool settingsMatch = (totalSets ?? _timer.totalSets) == _currentPreset!.totalSets &&
            (setDurationSeconds ?? _timer.setDurationSeconds) == _currentPreset!.setDurationSeconds &&
            (restDurationSeconds ?? _timer.restDurationSeconds) == _currentPreset!.restDurationSeconds &&
            (restAfterSets ?? _timer.restAfterSets) == _currentPreset!.restAfterSets;

        if (!settingsMatch) {
          clearCurrentPreset();
        }
      }

      print(
          'Settings updated: Sets=${totalSets ?? _timer.totalSets}, Duration=${setDurationSeconds ?? _timer.setDurationSeconds}s, Rest=${restDurationSeconds ?? _timer.restDurationSeconds}s, RestAfter=${restAfterSets ?? _timer.restAfterSets}');
      notifyListeners();
    } else {
      print('Cannot update settings while timer is running');
    }
  }

  void loadPreset(PresetModel preset) {
    _currentPreset = preset;
    updateTimerSettings(
      totalSets: preset.totalSets,
      setDurationSeconds: preset.setDurationSeconds,
      restDurationSeconds: preset.restDurationSeconds,
      restAfterSets: preset.restAfterSets,
      clearPreset: false, // Don't clear preset when loading
    );
    print('Preset loaded: ${preset.name} (${preset.category})');
  }

  /// Check if current workout is using a preset
  bool get isUsingPreset => _currentPreset != null;

  /// Get current preset name (null if custom workout)
  String? get currentPresetName => _currentPreset?.name;

  /// Clear current preset (when user modifies settings manually)
  void clearCurrentPreset() {
    _currentPreset = null;
    print('Preset cleared - now using custom settings');
  }

  void startTimer() async {
    if (_timer.state == TimerState.idle || _timer.state == TimerState.paused) {
      // Start or resume session tracking
      if (_timer.state == TimerState.idle) {
        // Start new session
        await _sessionService.startSession(
          timer: _timer,
          preset: _currentPreset,
        );
      } else {
        // Resume existing session
        await _sessionService.resumeSession();
      }

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

  void pauseTimer() async {
    if (_timer.state == TimerState.running || _timer.state == TimerState.resting) {
      _countdownTimer?.cancel();
      _timer = _timer.copyWith(state: TimerState.paused);

      // Pause session tracking
      await _sessionService.pauseSession();

      notifyListeners();
    }
  }

  void resetTimer() async {
    _countdownTimer?.cancel();
    _pausedAt = null;

    // Abandon current session if exists
    if (_sessionService.hasActiveSession) {
      await _sessionService.abandonSession();
    }

    // Unregister from app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

    // Completely reset timer to initial state
    _timer = _timer.copyWith(
      state: TimerState.idle,
      currentSet: 1, // Reset to first set
      remainingSeconds: _timer.setDurationSeconds, // Reset to full set duration
      isInRestPeriod: false, // Not in rest period
    );

    // Keep preset info when resetting (don't clear it)
    // _currentPreset stays the same so user can restart with same preset

    _backgroundService.disableBackgroundMode();
    notifyListeners();
    print(
        'Timer reset - currentSet: ${_timer.currentSet}/${_timer.totalSets}, progress: ${(_timer.progress * 100).toInt()}%, preset: ${_currentPreset?.name ?? 'none'}');
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

  void _handleSetComplete() async {
    _audioService.playSetEnd();
    _voiceCoachingService.announceSetEnd();

    // Update session progress
    await _sessionService.updateSessionProgress(_timer.currentSet);

    // Check if this was the last set
    if (_timer.currentSet >= _timer.totalSets) {
      print('✅ Workout completed - all sets finished');
      _completeWorkout();
      return; // Important: return early to prevent other logic
    }

    // Only announce progress if not the last set
    _voiceCoachingService.announceProgress(_timer.currentSet, _timer.totalSets);

    // If not the last set, check if we should rest
    if (_timer.shouldRest) {
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

  void _completeWorkout() async {
    _countdownTimer?.cancel();
    _pausedAt = null;

    try {
      // Complete session tracking
      await _sessionService.completeSession();

      // Update achievements and check for new unlocks
      final newlyUnlocked = await _achievementService.updateAchievementProgress();

      // Show achievement notifications if any achievements were unlocked
      if (newlyUnlocked.isNotEmpty) {
        // Add a small delay to ensure the completion screen is shown first
        await Future.delayed(const Duration(milliseconds: 1500));
        for (final achievement in newlyUnlocked) {
          print('🏆 Achievement unlocked: ${achievement.title}');
          // The achievement notification will be shown by the UI when it detects the achievement
        }
      }
    } catch (e) {
      print('⚠️ Error during workout completion: $e');
      // Continue with completion even if there are errors
    }

    // Unregister from app lifecycle events
    WidgetsBinding.instance.removeObserver(this);

    _timer = _timer.copyWith(state: TimerState.completed);
    _audioService.playWorkoutComplete();
    _voiceCoachingService.announceWorkoutComplete();
    _backgroundService.disableBackgroundMode();

    // Provide haptic feedback for workout completion
    HapticFeedback.heavyImpact();

    notifyListeners();
    print('✅ Workout completion flow finished successfully');
  }

  void _handleAppPaused() async {
    if (_timer.state == TimerState.running || _timer.state == TimerState.resting) {
      _pausedAt = DateTime.now();
      await _sessionService.pauseSession();
      print('📱 App paused - Timer will continue in background');
    }
  }

  void _handleAppResumed() async {
    if (_pausedAt != null && (_timer.state == TimerState.running || _timer.state == TimerState.resting)) {
      final pauseDuration = DateTime.now().difference(_pausedAt!);
      final secondsPassed = pauseDuration.inSeconds;

      if (secondsPassed > 0) {
        _syncTimerAfterBackground(secondsPassed);
      }

      await _sessionService.resumeSession();
      _pausedAt = null;
      print('📱 App resumed - Timer synced after ${secondsPassed}s in background');
    }
  }

  void _handleAppDetached() {
    // Clean up when app is completely closed
    _backgroundService.disableBackgroundMode();
  }

  void _syncTimerAfterBackground(int secondsPassed) async {
    int remainingSeconds = _timer.remainingSeconds - secondsPassed;

    while (remainingSeconds <= 0 && !_timer.isCompleted) {
      if (_timer.isInRestPeriod) {
        // Rest period completed - move to next set
        remainingSeconds += _timer.setDurationSeconds;
        _timer = _timer.copyWith(
          currentSet: _timer.currentSet + 1,
          isInRestPeriod: false,
          state: TimerState.running,
        );
        _audioService.playSetStart();

        // Update session progress
        await _sessionService.updateSessionProgress(_timer.currentSet);
      } else {
        // Set completed - check if workout is done
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
          // Start next set directly
          remainingSeconds += _timer.setDurationSeconds;
          _timer = _timer.copyWith(
            currentSet: _timer.currentSet + 1,
            state: TimerState.running,
          );
          _audioService.playSetStart();

          // Update session progress
          await _sessionService.updateSessionProgress(_timer.currentSet);
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
    _sessionService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
