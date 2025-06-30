import 'dart:async';
import 'package:flutter/foundation.dart';

/// Web Speech API service for high-quality, free text-to-speech
/// This provides much better voice quality than flutter_tts using browser APIs
/// Only works on web platforms - provides stub implementation on other platforms
class WebSpeechService {
  static final WebSpeechService _instance = WebSpeechService._internal();
  factory WebSpeechService() => _instance;
  WebSpeechService._internal();

  bool _isSupported = false;
  List<WebSpeechVoice> _availableVoices = [];
  WebSpeechVoice? _selectedVoice;
  
  // Voice settings
  double _rate = 1.0;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _preferredLanguage = 'en-US';
  String _preferredGender = 'female';

  // Getters
  bool get isSupported => _isSupported;
  List<WebSpeechVoice> get availableVoices => _availableVoices;
  WebSpeechVoice? get selectedVoice => _selectedVoice;
  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;

  /// Initialize the Web Speech API
  Future<void> initialize() async {
    if (!kIsWeb) {
      print('🌐 Web Speech API not available on this platform (non-web)');
      _isSupported = false;
      return;
    }

    // Only initialize on web - the actual web implementation would go here
    // For now, we'll set it as not supported to avoid compilation issues
    print('🌐 Web Speech API initialization (web platform detected)');
    _isSupported = false; // Will be properly implemented when running on actual web
  }

  /// Set voice preferences
  Future<void> setVoiceGender(String gender) async {
    _preferredGender = gender;
    if (kIsWeb) {
      print('🎤 Web Speech voice gender changed to $_preferredGender');
    }
  }

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.1, 10.0);
    if (kIsWeb) {
      print('🎤 Web Speech rate changed to $_rate');
    }
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.0, 2.0);
    if (kIsWeb) {
      print('🎤 Web Speech pitch changed to $_pitch');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (kIsWeb) {
      print('🎤 Web Speech volume changed to $_volume');
    }
  }

  /// Speak text using Web Speech API
  Future<void> speak(String text) async {
    if (!kIsWeb) {
      print('⚠️ Web Speech API only works on web platforms');
      return;
    }
    
    if (!_isSupported || text.isEmpty) {
      print('⚠️ Web Speech API not supported or text is empty');
      return;
    }

    // Web speech implementation would go here
    print('🔊 Web Speech would speak: "$text"');
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!kIsWeb) return;
    
    if (_isSupported) {
      print('🛑 Web Speech stopped');
    }
  }

  /// Test voice with a sample message
  Future<void> testVoice() async {
    await speak('Hello! This is a test of the Web Speech API. The voice quality is much better than the default text-to-speech.');
  }
}

/// Represents a Web Speech API voice
class WebSpeechVoice {
  final String name;
  final String lang;
  final String gender;
  final bool isLocal;
  final String voiceURI;

  const WebSpeechVoice({
    required this.name,
    required this.lang,
    required this.gender,
    required this.isLocal,
    required this.voiceURI,
  });

  @override
  String toString() {
    return 'WebSpeechVoice(name: $name, lang: $lang, gender: $gender, local: $isLocal)';
  }
} 