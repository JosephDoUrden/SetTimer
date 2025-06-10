import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  void playSetStart() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: false,
        volume: 0.8,
        asAlarm: false,
      );
    } catch (e) {
      print('Error playing set start sound: $e');
    }
  }

  void playSetEnd() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: false,
        volume: 0.8,
        asAlarm: false,
      );
    } catch (e) {
      print('Error playing set end sound: $e');
    }
  }

  void playRestStart() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.receivedMessage,
        looping: false,
        volume: 0.6,
        asAlarm: false,
      );
    } catch (e) {
      print('Error playing rest start sound: $e');
    }
  }

  void playRestEnd() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: false,
        volume: 0.8,
        asAlarm: false,
      );
    } catch (e) {
      print('Error playing rest end sound: $e');
    }
  }

  void playWorkoutComplete() {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.ringtone,
        ios: IosSounds.triTone,
        looping: false,
        volume: 1.0,
        asAlarm: false,
      );
    } catch (e) {
      print('Error playing workout complete sound: $e');
    }
  }

  void stopAllSounds() {
    try {
      FlutterRingtonePlayer().stop();
    } catch (e) {
      print('Error stopping sounds: $e');
    }
  }
}
