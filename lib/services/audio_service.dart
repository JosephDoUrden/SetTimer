import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class AudioService {
  final FlutterRingtonePlayer _player = FlutterRingtonePlayer();

  void playSetStart() {
    _player.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 0.8,
    );
  }

  void playSetEnd() {
    _player.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.alarm,
      looping: false,
      volume: 0.8,
    );
  }

  void playRestStart() {
    _player.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.receivedMessage,
      looping: false,
      volume: 0.6,
    );
  }

  void playRestEnd() {
    _player.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 0.8,
    );
  }

  void playWorkoutComplete() {
    _player.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.triTone,
      looping: false,
      volume: 1.0,
    );
  }

  void stopAllSounds() {
    _player.stop();
  }
}
