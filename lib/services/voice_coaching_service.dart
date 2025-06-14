import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

enum VoiceGender { male, female }

enum CoachingStyle { motivational, calm, professional, energetic }

enum AnnouncementType { setStart, setEnd, restStart, restEnd, workoutComplete, countdown, warning, progress, encouragement }

class VoiceCoachingService {
  static final VoiceCoachingService _instance = VoiceCoachingService._internal();
  factory VoiceCoachingService() => _instance;
  VoiceCoachingService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  // Voice settings
  bool _isEnabled = true;
  bool _isCountdownEnabled = true;
  bool _isProgressEnabled = true;
  bool _isEncouragementEnabled = true;
  double _speechRate = 0.5;
  double _volume = 0.8;
  double _pitch = 1.0;
  String _language = 'en-US';
  VoiceGender _voiceGender = VoiceGender.female;
  CoachingStyle _coachingStyle = CoachingStyle.motivational;

  // Available voices
  List<Map<String, String>> _availableVoices = [];
  String? _selectedVoice;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isCountdownEnabled => _isCountdownEnabled;
  bool get isProgressEnabled => _isProgressEnabled;
  bool get isEncouragementEnabled => _isEncouragementEnabled;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;
  VoiceGender get voiceGender => _voiceGender;
  CoachingStyle get coachingStyle => _coachingStyle;
  List<Map<String, String>> get availableVoices => _availableVoices;
  String? get selectedVoice => _selectedVoice;

  // Initialize voice coaching service
  Future<void> initialize() async {
    await _loadSettings();
    await _initializeTts();
    await _loadAvailableVoices();
  }

  // Initialize TTS engine
  Future<void> _initializeTts() async {
    try {
      // Set up TTS handlers
      _flutterTts.setStartHandler(() {
        print("🎤 Voice coaching started");
      });

      _flutterTts.setCompletionHandler(() {
        print("🎤 Voice coaching completed");
      });

      _flutterTts.setErrorHandler((msg) {
        print("🎤 Voice coaching error: $msg");
      });

      // Configure TTS settings
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      // Platform specific settings
      if (Platform.isAndroid) {
        await _flutterTts.setQueueMode(1); // Flush queue mode
      }

      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.allowBluetooth],
        );
      }
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Load available voices
  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        _availableVoices = List<Map<String, String>>.from(voices);

        // Filter voices by language and gender preference
        _availableVoices = _availableVoices.where((voice) {
          final locale = voice['locale'] ?? '';
          return locale.startsWith(_language.split('-')[0]);
        }).toList();

        // Auto-select appropriate voice if none selected
        if (_selectedVoice == null && _availableVoices.isNotEmpty) {
          _selectBestVoice();
        }
      }
    } catch (e) {
      print('Error loading voices: $e');
    }
  }

  // Select best voice based on preferences
  void _selectBestVoice() {
    if (_availableVoices.isEmpty) return;

    // Try to find voice matching gender preference
    final genderKeywords = _voiceGender == VoiceGender.female
        ? ['female', 'woman', 'girl', 'samantha', 'karen', 'susan', 'victoria']
        : ['male', 'man', 'boy', 'alex', 'daniel', 'tom', 'david'];

    for (final voice in _availableVoices) {
      final name = (voice['name'] ?? '').toLowerCase();
      if (genderKeywords.any((keyword) => name.contains(keyword))) {
        _selectedVoice = voice['name'];
        return;
      }
    }

    // Fallback to first available voice
    _selectedVoice = _availableVoices.first['name'];
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isEnabled = prefs.getBool('voice_enabled') ?? true;
      _isCountdownEnabled = prefs.getBool('voice_countdown_enabled') ?? true;
      _isProgressEnabled = prefs.getBool('voice_progress_enabled') ?? true;
      _isEncouragementEnabled = prefs.getBool('voice_encouragement_enabled') ?? true;
      _speechRate = prefs.getDouble('voice_speech_rate') ?? 0.5;
      _volume = prefs.getDouble('voice_volume') ?? 0.8;
      _pitch = prefs.getDouble('voice_pitch') ?? 1.0;
      _language = prefs.getString('voice_language') ?? 'en-US';
      _selectedVoice = prefs.getString('voice_selected_voice');

      final genderIndex = prefs.getInt('voice_gender') ?? 1;
      _voiceGender = VoiceGender.values[genderIndex.clamp(0, VoiceGender.values.length - 1)];

      final styleIndex = prefs.getInt('voice_coaching_style') ?? 0;
      _coachingStyle = CoachingStyle.values[styleIndex.clamp(0, CoachingStyle.values.length - 1)];
    } catch (e) {
      print('Error loading voice settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('voice_enabled', _isEnabled);
      await prefs.setBool('voice_countdown_enabled', _isCountdownEnabled);
      await prefs.setBool('voice_progress_enabled', _isProgressEnabled);
      await prefs.setBool('voice_encouragement_enabled', _isEncouragementEnabled);
      await prefs.setDouble('voice_speech_rate', _speechRate);
      await prefs.setDouble('voice_volume', _volume);
      await prefs.setDouble('voice_pitch', _pitch);
      await prefs.setString('voice_language', _language);
      await prefs.setInt('voice_gender', _voiceGender.index);
      await prefs.setInt('voice_coaching_style', _coachingStyle.index);

      if (_selectedVoice != null) {
        await prefs.setString('voice_selected_voice', _selectedVoice!);
      }
    } catch (e) {
      print('Error saving voice settings: $e');
    }
  }

  // Update voice settings
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setCountdownEnabled(bool enabled) async {
    _isCountdownEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setProgressEnabled(bool enabled) async {
    _isProgressEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setEncouragementEnabled(bool enabled) async {
    _isEncouragementEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
    await _saveSettings();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
    await _saveSettings();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
    await _saveSettings();
  }

  Future<void> setVoiceGender(VoiceGender gender) async {
    _voiceGender = gender;
    _selectBestVoice();
    if (_selectedVoice != null) {
      await _flutterTts.setVoice({'name': _selectedVoice!, 'locale': _language});
    }
    await _saveSettings();
  }

  Future<void> setCoachingStyle(CoachingStyle style) async {
    _coachingStyle = style;
    await _saveSettings();
  }

  Future<void> setSelectedVoice(String voiceName) async {
    _selectedVoice = voiceName;
    await _flutterTts.setVoice({'name': voiceName, 'locale': _language});
    await _saveSettings();
  }

  // Get coaching message based on type and style
  String _getCoachingMessage(AnnouncementType type, {Map<String, dynamic>? context}) {
    switch (type) {
      case AnnouncementType.setStart:
        return _getSetStartMessage();
      case AnnouncementType.setEnd:
        return _getSetEndMessage();
      case AnnouncementType.restStart:
        return _getRestStartMessage();
      case AnnouncementType.restEnd:
        return _getRestEndMessage();
      case AnnouncementType.workoutComplete:
        return _getWorkoutCompleteMessage();
      case AnnouncementType.countdown:
        final seconds = context?['seconds'] ?? 3;
        return _getCountdownMessage(seconds);
      case AnnouncementType.warning:
        return _getWarningMessage();
      case AnnouncementType.progress:
        final currentSet = context?['currentSet'] ?? 1;
        final totalSets = context?['totalSets'] ?? 1;
        return _getProgressMessage(currentSet, totalSets);
      case AnnouncementType.encouragement:
        return _getEncouragementMessage();
    }
  }

  String _getSetStartMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        final messages = [
          "Let's go! Time to work!",
          "Push yourself! You've got this!",
          "Work time! Give it everything!",
          "Here we go! Make it count!",
          "Time to sweat! Let's do this!"
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.calm:
        final messages = [
          "Begin your set. Focus on your form.",
          "Work time. Breathe and concentrate.",
          "Start your exercise. Stay mindful.",
          "Time to work. Keep it steady.",
          "Begin. Find your rhythm."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.professional:
        final messages = [
          "Work interval begins now.",
          "Start your exercise.",
          "Work phase initiated.",
          "Begin your set.",
          "Exercise time starts now."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.energetic:
        final messages = [
          "GO GO GO! Work time!",
          "PUMP IT UP! Let's move!",
          "ENERGY TIME! Push hard!",
          "FIRE IT UP! Work mode!",
          "BEAST MODE ON! Let's go!"
        ];
        return messages[DateTime.now().millisecond % messages.length];
    }
  }

  String _getSetEndMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        final messages = [
          "Great work! Set complete!",
          "Awesome job! Well done!",
          "Excellent! You crushed it!",
          "Perfect! Keep it up!",
          "Outstanding effort!"
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.calm:
        final messages = [
          "Set complete. Well done.",
          "Good work. Take a breath.",
          "Nicely done. Rest now.",
          "Set finished. Relax.",
          "Complete. Good effort."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.professional:
        final messages = ["Set completed.", "Work interval finished.", "Exercise complete.", "Set concluded.", "Work phase ended."];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.energetic:
        final messages = ["BOOM! Set smashed!", "YEAH! Crushed it!", "AMAZING! Keep going!", "FANTASTIC! You rock!", "INCREDIBLE work!"];
        return messages[DateTime.now().millisecond % messages.length];
    }
  }

  String _getRestStartMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        final messages = [
          "Rest time! Catch your breath.",
          "Recovery time. You earned it!",
          "Take a breather. Stay ready!",
          "Rest up! Next set coming!",
          "Recover well. Stay focused!"
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.calm:
        final messages = [
          "Rest period. Breathe deeply.",
          "Recovery time. Stay relaxed.",
          "Rest now. Center yourself.",
          "Break time. Stay calm.",
          "Rest. Prepare for next set."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.professional:
        final messages = [
          "Rest interval begins.",
          "Recovery period started.",
          "Rest phase initiated.",
          "Break time commenced.",
          "Recovery interval active."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.energetic:
        final messages = [
          "REST TIME! Recharge!",
          "BREAK TIME! Stay pumped!",
          "RECOVERY! Keep the energy!",
          "REST UP! More to come!",
          "BREATHE! Stay fired up!"
        ];
        return messages[DateTime.now().millisecond % messages.length];
    }
  }

  String _getRestEndMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        final messages = [
          "Rest over! Ready to go again!",
          "Time's up! Let's get back to it!",
          "Break's over! You're ready!",
          "Back to work! You've got this!",
          "Ready? Let's do this!"
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.calm:
        final messages = [
          "Rest complete. Prepare to work.",
          "Break finished. Get ready.",
          "Rest over. Focus ahead.",
          "Recovery done. Next set coming.",
          "Break ended. Stay centered."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.professional:
        final messages = [
          "Rest period concluded.",
          "Recovery interval finished.",
          "Break time ended.",
          "Rest phase complete.",
          "Prepare for next set."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.energetic:
        final messages = ["TIME'S UP! Let's go!", "BREAK OVER! Fire up!", "READY? ATTACK!", "GO TIME! Unleash!", "GAME ON! Let's move!"];
        return messages[DateTime.now().millisecond % messages.length];
    }
  }

  String _getWorkoutCompleteMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        return "Incredible work! Workout complete! You absolutely crushed it today!";
      case CoachingStyle.calm:
        return "Workout complete. Excellent effort. Take time to appreciate what you've accomplished.";
      case CoachingStyle.professional:
        return "Training session concluded. All sets completed successfully.";
      case CoachingStyle.energetic:
        return "WORKOUT SMASHED! ABSOLUTELY INCREDIBLE! You are a champion!";
    }
  }

  String _getCountdownMessage(int seconds) {
    if (seconds <= 3) {
      return "$seconds";
    }
    return "Get ready in $seconds";
  }

  String _getWarningMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        return "Almost there! Keep pushing!";
      case CoachingStyle.calm:
        return "Nearly finished. Stay focused.";
      case CoachingStyle.professional:
        return "Approaching completion.";
      case CoachingStyle.energetic:
        return "FINAL PUSH! Don't stop!";
    }
  }

  String _getProgressMessage(int currentSet, int totalSets) {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        return "Set $currentSet of $totalSets complete! Keep the momentum!";
      case CoachingStyle.calm:
        return "Set $currentSet of $totalSets finished. Good progress.";
      case CoachingStyle.professional:
        return "Set $currentSet of $totalSets completed.";
      case CoachingStyle.energetic:
        return "SET $currentSet DONE! $totalSets total! Keep crushing!";
    }
  }

  String _getEncouragementMessage() {
    switch (_coachingStyle) {
      case CoachingStyle.motivational:
        final messages = [
          "You're doing amazing!",
          "Keep up the great work!",
          "You're stronger than you think!",
          "Push through! You've got this!",
          "Every rep counts!"
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.calm:
        final messages = [
          "Stay focused. You're doing well.",
          "Good form. Keep it up.",
          "Breathe. You're in control.",
          "Steady progress. Well done.",
          "Maintain your pace."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.professional:
        final messages = [
          "Maintaining good form.",
          "Consistent performance.",
          "On track with your goals.",
          "Proper execution.",
          "Meeting expectations."
        ];
        return messages[DateTime.now().millisecond % messages.length];

      case CoachingStyle.energetic:
        final messages = ["UNSTOPPABLE FORCE!", "PURE POWER!", "CRUSHING IT!", "BEAST MODE!", "INCREDIBLE ENERGY!"];
        return messages[DateTime.now().millisecond % messages.length];
    }
  }

  // Public announcement methods
  Future<void> announceSetStart() async {
    if (!_isEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.setStart);
    await _speak(message);
  }

  Future<void> announceSetEnd() async {
    if (!_isEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.setEnd);
    await _speak(message);
  }

  Future<void> announceRestStart() async {
    if (!_isEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.restStart);
    await _speak(message);
  }

  Future<void> announceRestEnd() async {
    if (!_isEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.restEnd);
    await _speak(message);
  }

  Future<void> announceWorkoutComplete() async {
    if (!_isEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.workoutComplete);
    await _speak(message);
  }

  Future<void> announceCountdown(int seconds) async {
    if (!_isEnabled || !_isCountdownEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.countdown, context: {'seconds': seconds});
    await _speak(message);
  }

  Future<void> announceProgress(int currentSet, int totalSets) async {
    if (!_isEnabled || !_isProgressEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.progress, context: {
      'currentSet': currentSet,
      'totalSets': totalSets,
    });
    await _speak(message);
  }

  Future<void> announceEncouragement() async {
    if (!_isEnabled || !_isEncouragementEnabled) return;
    final message = _getCoachingMessage(AnnouncementType.encouragement);
    await _speak(message);
  }

  // Test voice with sample message
  Future<void> testVoice() async {
    final message = _getCoachingMessage(AnnouncementType.encouragement);
    await _speak(message);
  }

  // Core speak method
  Future<void> _speak(String message) async {
    try {
      await _flutterTts.stop(); // Stop any ongoing speech
      await _flutterTts.speak(message);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  // Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _flutterTts.stop();
  }
}
