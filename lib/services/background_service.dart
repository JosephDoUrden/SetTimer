import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class BackgroundService {
  bool _isBackgroundModeEnabled = false;

  Future<void> enableBackgroundMode() async {
    try {
      // Set system UI to immersive mode for better focus
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );

      // Prevent system UI from showing during timer
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      _isBackgroundModeEnabled = true;
      developer.log('Background Mode Enabled - Immersive UI activated', name: 'BackgroundService');
    } catch (e) {
      developer.log('Failed to enable background mode: $e', name: 'BackgroundService', level: 1000);
    }
  }

  Future<void> disableBackgroundMode() async {
    try {
      // Restore normal system UI
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      // Reset system UI overlay style to default
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

      _isBackgroundModeEnabled = false;
      developer.log('Background Mode Disabled - Normal UI restored', name: 'BackgroundService');
    } catch (e) {
      developer.log('Failed to disable background mode: $e', name: 'BackgroundService', level: 1000);
    }
  }

  bool get isEnabled => _isBackgroundModeEnabled;
}
