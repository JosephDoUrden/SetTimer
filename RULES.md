# Development Rules for SetTimer 🏋️‍♂️

This document outlines the development rules, guidelines, and best practices for the SetTimer Flutter project when using Cursor IDE.

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture Rules](#architecture-rules)
3. [Code Style & Conventions](#code-style--conventions)
4. [File Organization](#file-organization)
5. [State Management](#state-management)
6. [Error Handling](#error-handling)
7. [Dependencies & Imports](#dependencies--imports)
8. [Platform-Specific Guidelines](#platform-specific-guidelines)
9. [Testing Standards](#testing-standards)
10. [Performance Guidelines](#performance-guidelines)
11. [Commit & Version Control](#commit--version-control)
12. [Documentation Requirements](#documentation-requirements)

## 🎯 Project Overview

SetTimer is a minimalist workout timer app for set-based workouts, HIIT, and interval training. The app follows clean architecture principles with MVC pattern and uses Provider for state management.

### Core Technologies
- **Framework**: Flutter 3.5.3+
- **State Management**: Provider pattern with ChangeNotifier
- **Audio**: flutter_ringtone_player, audioplayers
- **Voice Coaching**: flutter_tts
- **Storage**: sqflite, shared_preferences
- **Analytics**: fl_chart
- **Wake Lock**: wakelock_plus

## 🏗️ Architecture Rules

### MVC Pattern Enforcement
```
lib/
├── controllers/     # Business logic and state management
├── models/         # Data models and entities
├── services/       # External services and utilities
├── views/          # UI screens and layouts
├── widgets/        # Reusable UI components
└── main.dart       # App entry point
```

### Rules:
1. **Controllers** MUST extend `ChangeNotifier` and handle business logic only
2. **Models** MUST be immutable with `copyWith()` methods
3. **Services** MUST handle external APIs, storage, and platform features
4. **Views** MUST be StatelessWidget that consume Provider state
5. **Widgets** MUST be reusable components with clear props

### Dependency Flow
- Views → Controllers → Services → Models
- Never import Views in Controllers or Services
- Never import Controllers in Services

## 🎨 Code Style & Conventions

### Naming Conventions
```dart
// Classes: PascalCase
class TimerController extends ChangeNotifier {}

// Variables and functions: camelCase
int remainingSeconds = 30;
void startTimer() {}

// Constants: SCREAMING_SNAKE_CASE
static const int MAX_SETS = 20;

// Private members: _prefixed
String _privateMethod() {}

// Files: snake_case.dart
timer_controller.dart
audio_service.dart
```

### Code Formatting
- **Line Length**: Maximum 120 characters
- **Indentation**: 2 spaces (no tabs)
- **Trailing Commas**: Always use for multi-line arguments
- **Imports**: Group and sort alphabetically

```dart
// ✅ Good
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text('Hello World'),
        ElevatedButton(
          onPressed: onPressed,
          child: Text('Button'),
        ),
      ],
    ),
  );
}
```

### Documentation Standards
```dart
/// Starts the workout timer with current settings.
/// 
/// This method handles:
/// - Session tracking initialization
/// - Audio feedback
/// - Background mode enabling
/// - Screen wake lock
/// 
/// Throws [TimerException] if timer is already running.
void startTimer() async {
  // Implementation
}
```

## 📁 File Organization

### Service Files
- Each service handles ONE specific domain
- Services MUST be stateless and injectable
- Use dependency injection pattern

```dart
// ✅ Good - Single responsibility
class AudioService {
  Future<void> initialize() async {}
  void playSetStart() {}
  void playSetEnd() {}
}

// ❌ Bad - Multiple responsibilities
class UtilityService {
  void playSound() {}
  void saveData() {}
  void sendAnalytics() {}
}
```

### Model Files
- One model per file
- Include `copyWith()`, `toJson()`, `fromJson()` methods
- Use `@immutable` annotation

```dart
@immutable
class TimerModel {
  final int totalSets;
  final int setDurationSeconds;
  final TimerState state;

  const TimerModel({
    required this.totalSets,
    required this.setDurationSeconds,
    required this.state,
  });

  TimerModel copyWith({
    int? totalSets,
    int? setDurationSeconds,
    TimerState? state,
  }) {
    return TimerModel(
      totalSets: totalSets ?? this.totalSets,
      setDurationSeconds: setDurationSeconds ?? this.setDurationSeconds,
      state: state ?? this.state,
    );
  }
}
```

## 🔄 State Management

### Provider Pattern Rules
1. **Controllers** extend `ChangeNotifier`
2. Use `Consumer<T>` for reactive UI updates
3. Use `context.read<T>()` for one-time actions
4. NEVER call `notifyListeners()` in getters

```dart
// ✅ Good - Reactive UI
Consumer<TimerController>(
  builder: (context, controller, child) {
    return Text('${controller.timer.remainingSeconds}');
  },
),

// ✅ Good - One-time action
ElevatedButton(
  onPressed: () => context.read<TimerController>().startTimer(),
  child: Text('Start'),
),

// ❌ Bad - Using watch for actions
ElevatedButton(
  onPressed: () => context.watch<TimerController>().startTimer(),
  child: Text('Start'),
),
```

### State Mutation Rules
- NEVER mutate state directly
- Always use `copyWith()` for state updates
- Call `notifyListeners()` after state changes

```dart
// ✅ Good
void updateSettings(int newDuration) {
  _timer = _timer.copyWith(setDurationSeconds: newDuration);
  notifyListeners();
}

// ❌ Bad
void updateSettings(int newDuration) {
  _timer.setDurationSeconds = newDuration; // Direct mutation
}
```

## ⚠️ Error Handling

### Exception Handling Rules
1. Use specific exception types
2. Handle async operations with try-catch
3. Log errors with context
4. Never suppress exceptions silently

```dart
// ✅ Good
Future<void> initializeAudio() async {
  try {
    await audioService.initialize();
    print('✅ Audio service initialized successfully');
  } on AudioException catch (e) {
    print('🔊 Audio initialization failed: ${e.message}');
    throw TimerException('Failed to initialize audio: ${e.message}');
  } catch (e) {
    print('⚠️ Unexpected error during audio init: $e');
    rethrow;
  }
}

// ❌ Bad
Future<void> initializeAudio() async {
  try {
    await audioService.initialize();
  } catch (e) {
    // Silent failure
  }
}
```

### Logging Standards
```dart
// Use structured logging with emojis for clarity
print('🏁 Timer started - Sets: ${timer.totalSets}, Duration: ${timer.setDurationSeconds}s');
print('⏸️ Timer paused at ${timer.remainingSeconds}s remaining');
print('⚠️ Warning: Battery optimization may affect background timers');
print('❌ Error: Failed to save workout session - ${e.toString()}');
print('✅ Workout completed successfully in ${duration.inMinutes}m ${duration.inSeconds % 60}s');
```

## 📦 Dependencies & Imports

### Import Organization
```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Flutter framework imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

// 4. Local imports (relative paths)
import '../models/timer_model.dart';
import '../services/audio_service.dart';
```

### Dependency Rules
- NEVER add dependencies without discussion
- Keep dependencies minimal and focused
- Use specific version constraints in `pubspec.yaml`
- Document why each dependency is needed

```yaml
# ✅ Good - Specific versions with reasoning
dependencies:
  # State management for reactive UI
  provider: ^6.1.1
  
  # Audio playback for workout feedback
  audioplayers: ^5.2.1
  
  # Voice coaching functionality
  flutter_tts: ^4.0.2

# ❌ Bad - Loose constraints
dependencies:
  provider: any
  audioplayers: ^5.0.0
```

## 📱 Platform-Specific Guidelines

### iOS Considerations
- Handle background audio sessions properly
- Request microphone permissions for TTS
- Test on multiple iOS versions (12.0+)
- Consider iOS-specific UI guidelines

### Android Considerations
- Handle wake locks carefully
- Consider battery optimization warnings
- Test on various Android versions (API 21+)
- Handle different screen densities

### Platform-Specific Code
```dart
// ✅ Good - Platform-specific implementations
class AudioService {
  Future<void> initialize() async {
    if (Platform.isIOS) {
      await _initializeIOSAudioSession();
    } else if (Platform.isAndroid) {
      await _initializeAndroidAudioFocus();
    }
  }
}
```

## 🧪 Testing Standards

### Test File Organization
```
test/
├── unit/
│   ├── controllers/
│   ├── models/
│   └── services/
├── widget/
│   ├── views/
│   └── widgets/
└── integration/
    └── app_test.dart
```

### Testing Rules
1. Aim for 80%+ code coverage
2. Test business logic thoroughly
3. Mock external dependencies
4. Write descriptive test names

```dart
// ✅ Good test structure
group('TimerController', () {
  late TimerController controller;
  late MockAudioService mockAudioService;

  setUp(() {
    mockAudioService = MockAudioService();
    controller = TimerController(audioService: mockAudioService);
  });

  group('startTimer', () {
    test('should start timer when in idle state', () {
      // Arrange
      expect(controller.timer.state, TimerState.idle);

      // Act
      controller.startTimer();

      // Assert
      expect(controller.timer.state, TimerState.running);
      verify(mockAudioService.playSetStart()).called(1);
    });

    test('should throw exception when timer is already running', () {
      // Arrange
      controller.startTimer();

      // Act & Assert
      expect(() => controller.startTimer(), throwsA(isA<TimerException>()));
    });
  });
});
```

## ⚡ Performance Guidelines

### Widget Performance
1. Use `const` constructors wherever possible
2. Implement `shouldRebuild` for expensive widgets
3. Use `ListView.builder` for long lists
4. Minimize widget rebuilds with proper `Consumer` placement

```dart
// ✅ Good - Const constructor
const TimerDisplay({
  super.key,
  required this.remainingSeconds,
});

// ✅ Good - Selective rebuilds
Consumer<TimerController>(
  builder: (context, controller, child) {
    return Text('${controller.timer.remainingSeconds}');
  },
  child: const ExpensiveWidget(), // Won't rebuild
),
```

### Memory Management
1. Dispose controllers, timers, and streams
2. Cancel subscriptions in dispose methods
3. Use weak references for callbacks

```dart
@override
void dispose() {
  _countdownTimer?.cancel();
  _audioService.dispose();
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
}
```

## 🔄 Commit & Version Control

### Commit Message Format
```
<type>(<scope>): <description>

<optional body>

<optional footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```bash
feat(timer): add voice coaching support
fix(audio): resolve iOS background audio issue
docs(readme): update installation instructions
refactor(models): simplify timer state management
```

### Branch Naming
```bash
feature/voice-coaching
bugfix/ios-audio-session
hotfix/critical-timer-bug
```

## 📚 Documentation Requirements

### Code Documentation
1. Document all public APIs
2. Include usage examples for complex functions
3. Document platform-specific behavior
4. Keep comments up-to-date with code changes

### README Updates
- Update feature lists when adding functionality
- Include new screenshots for UI changes
- Update installation steps for new dependencies
- Maintain accurate architecture documentation

### Changelog Maintenance
- Document breaking changes
- Include migration guides
- List new features and bug fixes
- Reference issue numbers

## 🚀 Cursor IDE Specific Guidelines

### AI Assistant Usage
1. Provide context about SetTimer's architecture when asking for help
2. Mention specific patterns used (Provider, MVC)
3. Reference existing code structures for consistency
4. Ask for platform-specific implementations when needed

### Code Generation
1. Use existing models as templates for new models
2. Follow established patterns for controllers and services
3. Maintain consistent error handling patterns
4. Ensure generated code follows our naming conventions

### Refactoring
1. Use IDE refactoring tools for renaming
2. Verify all references are updated
3. Run tests after major refactoring
4. Update documentation for API changes

---

## 📝 Final Notes

These rules ensure consistency, maintainability, and quality across the SetTimer codebase. When in doubt:

1. **Follow existing patterns** in the codebase
2. **Ask for clarification** rather than guessing
3. **Test thoroughly** on both platforms
4. **Document your changes** appropriately

Remember: SetTimer is a minimalist app focused on workout timing. Every feature and change should align with this core principle of simplicity and effectiveness.

**Happy coding! 🏋️‍♂️** 