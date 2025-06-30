import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

enum SoundPack {
  classic('Classic', 'Clean and professional workout sounds'),
  gym('Gym Beast', 'Intense motivational gym sounds'),
  nature('Nature Zen', 'Calming nature-inspired sounds'),
  electronic('Electronic', 'Modern electronic beats and beeps'),
  minimal('Minimal', 'Subtle and non-intrusive sounds');

  const SoundPack(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum SoundType { setStart, setEnd, restStart, restEnd, workoutComplete, countdown, warning }

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Audio settings
  SoundPack _currentSoundPack = SoundPack.classic;
  double _masterVolume = 1.0;  // Increased from 0.8 to 1.0 for louder sounds
  double _setVolume = 1.0;
  double _restVolume = 0.9;    // Increased from 0.8 to 0.9 for louder rest sounds
  double _completionVolume = 1.0;
  bool _isEnabled = true;
  bool _isVibrationEnabled = true;

  // Getters
  SoundPack get currentSoundPack => _currentSoundPack;
  double get masterVolume => _masterVolume;
  double get setVolume => _setVolume;
  double get restVolume => _restVolume;
  double get completionVolume => _completionVolume;
  bool get isEnabled => _isEnabled;
  bool get isVibrationEnabled => _isVibrationEnabled;

  // Initialize audio service
  Future<void> initialize() async {
    print('🎵 Initializing AudioService...');
    await _loadSettings();
    await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    print('🎵 AudioService initialized successfully');
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final soundPackIndex = prefs.getInt('sound_pack') ?? 0;
      _currentSoundPack = SoundPack.values[soundPackIndex.clamp(0, SoundPack.values.length - 1)];

      _masterVolume = prefs.getDouble('master_volume') ?? 1.0;  // Increased default from 0.8 to 1.0
      _setVolume = prefs.getDouble('set_volume') ?? 1.0;
      _restVolume = prefs.getDouble('rest_volume') ?? 0.9;    // Increased default from 0.8 to 0.9
      _completionVolume = prefs.getDouble('completion_volume') ?? 1.0;
      _isEnabled = prefs.getBool('audio_enabled') ?? true;
      _isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      
      print('🔄 Audio settings loaded - Master: ${(_masterVolume * 100).round()}%, Set: ${(_setVolume * 100).round()}%, Rest: ${(_restVolume * 100).round()}%, Completion: ${(_completionVolume * 100).round()}%, Pack: ${_currentSoundPack.displayName}');
    } catch (e) {
      print('❌ Error loading audio settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('sound_pack', _currentSoundPack.index);
      await prefs.setDouble('master_volume', _masterVolume);
      await prefs.setDouble('set_volume', _setVolume);
      await prefs.setDouble('rest_volume', _restVolume);
      await prefs.setDouble('completion_volume', _completionVolume);
      await prefs.setBool('audio_enabled', _isEnabled);
      await prefs.setBool('vibration_enabled', _isVibrationEnabled);
      
      print('✅ Audio settings saved - Master: ${(_masterVolume * 100).round()}%, Set: ${(_setVolume * 100).round()}%, Rest: ${(_restVolume * 100).round()}%, Completion: ${(_completionVolume * 100).round()}%');
    } catch (e) {
      print('❌ Error saving audio settings: $e');
    }
  }

  // Update sound pack
  Future<void> setSoundPack(SoundPack soundPack) async {
    _currentSoundPack = soundPack;
    await _saveSettings();
  }

  // Update volume settings
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
    print('🔊 Master volume changed to ${(_masterVolume * 100).round()}%');
    await _saveSettings();
  }

  Future<void> setSetVolume(double volume) async {
    _setVolume = volume.clamp(0.0, 1.0);
    print('🔊 Set volume changed to ${(_setVolume * 100).round()}%');
    await _saveSettings();
  }

  Future<void> setRestVolume(double volume) async {
    _restVolume = volume.clamp(0.0, 1.0);
    print('🔊 Rest volume changed to ${(_restVolume * 100).round()}%');
    await _saveSettings();
  }

  Future<void> setCompletionVolume(double volume) async {
    _completionVolume = volume.clamp(0.0, 1.0);
    print('🔊 Completion volume changed to ${(_completionVolume * 100).round()}%');
    await _saveSettings();
  }

  // Toggle audio/vibration
  Future<void> setAudioEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _isVibrationEnabled = enabled;
    await _saveSettings();
  }

  // Reset volume settings to optimized defaults for louder sound
  Future<void> resetVolumeToDefaults() async {
    _masterVolume = 1.0;   // Maximum master volume
    _setVolume = 1.0;      // Maximum set sounds
    _restVolume = 0.9;     // High rest sounds
    _completionVolume = 1.0; // Maximum completion sounds
    await _saveSettings();
  }

  // Calculate final volume for a sound type
  double _getFinalVolume(SoundType soundType) {
    if (!_isEnabled) return 0.0;

    double typeVolume;
    switch (soundType) {
      case SoundType.setStart:
      case SoundType.setEnd:
        typeVolume = _setVolume;
        break;
      case SoundType.restStart:
      case SoundType.restEnd:
        typeVolume = _restVolume;
        break;
      case SoundType.workoutComplete:
        typeVolume = _completionVolume;
        break;
      case SoundType.countdown:
      case SoundType.warning:
        typeVolume = _setVolume;
        break;
    }

    return (_masterVolume * typeVolume).clamp(0.0, 1.0);
  }

  // Get sound file path for current pack and sound type
  String _getSoundPath(SoundType soundType) {
    final packName = _currentSoundPack.name;
    final soundName = _getSoundFileName(soundType);
    return 'sounds/$packName/$soundName';
  }

  String _getSoundFileName(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return 'set_start.mp3';
      case SoundType.setEnd:
        return 'set_end.mp3';
      case SoundType.restStart:
        return 'rest_start.mp3';
      case SoundType.restEnd:
        return 'rest_end.mp3';
      case SoundType.workoutComplete:
        return 'workout_complete.mp3';
      case SoundType.countdown:
        return 'countdown.mp3';
      case SoundType.warning:
        return 'warning.mp3';
    }
  }

  // Play sound with current settings
  Future<void> _playSound(SoundType soundType) async {
    try {
      final volume = _getFinalVolume(soundType);
      if (volume <= 0.0) return;

      // Add haptic feedback if enabled
      if (_isVibrationEnabled) {
        _triggerHapticFeedback(soundType);
      }

      // Try to play custom sound first, fallback to system sound
      try {
        final soundPath = _getSoundPath(soundType);
        await _audioPlayer.stop();
        await _audioPlayer.setVolume(volume);
        await _audioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        // Fallback to system sounds if custom sounds fail
        print('Custom sound failed, using system sound: $e');
        await _playSystemSound(soundType, volume);
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Fallback system sound method
  Future<void> _playSystemSound(SoundType soundType, double volume) async {
    final config = _getSystemSoundConfig(soundType);
    
    // Use alarm volume for important sounds (set end, workout complete, warning)
    bool useAlarmVolume = soundType == SoundType.setEnd || 
                          soundType == SoundType.workoutComplete || 
                          soundType == SoundType.warning;
    
    await FlutterRingtonePlayer().play(
      android: config['android'],
      ios: config['ios'],
      looping: config['looping'] ?? false,
      volume: volume,
      asAlarm: useAlarmVolume,  // Use alarm volume for important sounds
    );
  }

  Map<String, dynamic> _getSystemSoundConfig(SoundType soundType) {
    // Enhanced system sound mapping based on sound pack
    switch (_currentSoundPack) {
      case SoundPack.classic:
        return _getClassicSystemSound(soundType);
      case SoundPack.gym:
        return _getGymSystemSound(soundType);
      case SoundPack.nature:
        return _getNatureSystemSound(soundType);
      case SoundPack.electronic:
        return _getElectronicSystemSound(soundType);
      case SoundPack.minimal:
        return _getMinimalSystemSound(soundType);
    }
  }

  Map<String, dynamic> _getClassicSystemSound(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.setEnd:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
      case SoundType.restStart:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.receivedMessage};
      case SoundType.restEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.workoutComplete:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.triTone};
      case SoundType.countdown:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.warning:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
    }
  }

  Map<String, dynamic> _getGymSystemSound(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
      case SoundType.setEnd:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.triTone};
      case SoundType.restStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.receivedMessage};
      case SoundType.restEnd:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
      case SoundType.workoutComplete:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.triTone};
      case SoundType.countdown:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.warning:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
    }
  }

  Map<String, dynamic> _getNatureSystemSound(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.setEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.receivedMessage};
      case SoundType.restStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.restEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.workoutComplete:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.triTone};
      case SoundType.countdown:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.warning:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.receivedMessage};
    }
  }

  Map<String, dynamic> _getElectronicSystemSound(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.setEnd:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
      case SoundType.restStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.receivedMessage};
      case SoundType.restEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.workoutComplete:
        return {'android': AndroidSounds.ringtone, 'ios': IosSounds.triTone};
      case SoundType.countdown:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.warning:
        return {'android': AndroidSounds.alarm, 'ios': IosSounds.alarm};
    }
  }

  Map<String, dynamic> _getMinimalSystemSound(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.setEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.restStart:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.restEnd:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.workoutComplete:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.receivedMessage};
      case SoundType.countdown:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
      case SoundType.warning:
        return {'android': AndroidSounds.notification, 'ios': IosSounds.glass};
    }
  }

  // Enhanced haptic feedback based on sound type and pack
  void _triggerHapticFeedback(SoundType soundType) {
    switch (soundType) {
      case SoundType.setStart:
        HapticFeedback.mediumImpact();
        break;
      case SoundType.setEnd:
        HapticFeedback.heavyImpact();
        break;
      case SoundType.restStart:
        HapticFeedback.lightImpact();
        break;
      case SoundType.restEnd:
        HapticFeedback.mediumImpact();
        break;
      case SoundType.workoutComplete:
        // Double vibration for completion
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 100), () {
          HapticFeedback.heavyImpact();
        });
        break;
      case SoundType.countdown:
        HapticFeedback.selectionClick();
        break;
      case SoundType.warning:
        HapticFeedback.heavyImpact();
        break;
    }
  }

  // Public sound methods
  Future<void> playSetStart() async {
    await _playSound(SoundType.setStart);
  }

  Future<void> playSetEnd() async {
    await _playSound(SoundType.setEnd);
  }

  Future<void> playRestStart() async {
    await _playSound(SoundType.restStart);
  }

  Future<void> playRestEnd() async {
    await _playSound(SoundType.restEnd);
  }

  Future<void> playWorkoutComplete() async {
    await _playSound(SoundType.workoutComplete);
  }

  Future<void> playCountdown() async {
    await _playSound(SoundType.countdown);
  }

  Future<void> playWarning() async {
    await _playSound(SoundType.warning);
  }

  // Test sound for settings
  Future<void> testSound(SoundType soundType) async {
    await _playSound(soundType);
  }

  // Stop all sounds
  Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
      await FlutterRingtonePlayer().stop();
    } catch (e) {
      print('Error stopping sounds: $e');
    }
  }

  // Get sound pack icon
  String getSoundPackIcon(SoundPack pack) {
    switch (pack) {
      case SoundPack.classic:
        return '🔔';
      case SoundPack.gym:
        return '💪';
      case SoundPack.nature:
        return '🌿';
      case SoundPack.electronic:
        return '🎵';
      case SoundPack.minimal:
        return '🔕';
    }
  }

  // Get sound pack color
  String getSoundPackColor(SoundPack pack) {
    switch (pack) {
      case SoundPack.classic:
        return '#00D4AA';
      case SoundPack.gym:
        return '#FF6B35';
      case SoundPack.nature:
        return '#4CAF50';
      case SoundPack.electronic:
        return '#9C27B0';
      case SoundPack.minimal:
        return '#757575';
    }
  }

  // Get detailed sound pack info
  Map<String, String> getSoundPackInfo(SoundPack pack) {
    switch (pack) {
      case SoundPack.classic:
        return {
          'theme': 'Professional & Clean',
          'mood': 'Focused',
          'intensity': 'Medium',
          'description': 'Clean bell tones and professional workout sounds'
        };
      case SoundPack.gym:
        return {
          'theme': 'Intense & Motivational',
          'mood': 'Energetic',
          'intensity': 'High',
          'description': 'Heavy beats and motivational gym atmosphere'
        };
      case SoundPack.nature:
        return {
          'theme': 'Calm & Natural',
          'mood': 'Peaceful',
          'intensity': 'Low',
          'description': 'Gentle chimes and nature-inspired sounds'
        };
      case SoundPack.electronic:
        return {
          'theme': 'Modern & Futuristic',
          'mood': 'Tech-savvy',
          'intensity': 'Medium-High',
          'description': 'Electronic beats and digital sound effects'
        };
      case SoundPack.minimal:
        return {
          'theme': 'Subtle & Unobtrusive',
          'mood': 'Zen',
          'intensity': 'Very Low',
          'description': 'Soft clicks and minimal notification sounds'
        };
    }
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
