# SetTimer 🏋️‍♂️

A minimalist workout timer app designed specifically for set-based workouts like ab/core training, HIIT, and interval training. Focus on your workout while SetTimer handles the timing automatically.

## ✨ Features

- **Custom Set Configuration**: Set any number of sets (1-20)
- **Flexible Duration**: Configure set duration from 10 seconds to 5 minutes
- **Smart Rest Intervals**: Automatic rest periods after every N sets
- **Auto-Progression**: Automatically moves between sets and rest periods
- **Background Support**: Continue workouts with screen locked or app in background
- **Audio Alerts**: Clear sound notifications for set start/end and rest periods
- **Modern UI**: Dark theme with beautiful gradients and intuitive controls
- **One-Tap Start**: Simple interface focused on workout flow
- **Progress Tracking**: Visual progress bar and set counter

## 📱 Screenshots

![SetTimer App Interface](https://via.placeholder.com/300x600/0A0A0A/00D4AA?text=SetTimer+UI)

## 🚀 Getting Started

### Prerequisites

- Flutter 3.5.3 or higher
- Dart SDK
- Android Studio / Xcode for device testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/JosephDoUrden/SetTimer.git
   cd SetTimer
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

#### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

#### iOS
```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Build from command line
flutter build ios --release
```

## 🎯 How to Use

1. **Configure Settings**: Tap the settings button to customize:
   - Total number of sets
   - Duration per set
   - Rest duration
   - Rest interval (after how many sets)

2. **Start Workout**: Tap the play button to begin
3. **Hands-Free Operation**: The app automatically handles:
   - Set countdown
   - Rest periods
   - Moving to next set
   - Workout completion

4. **Control Options**:
   - **Pause**: Pause the current timer
   - **Reset**: Reset to beginning
   - **Settings**: Modify configuration (only when stopped)

## 🏗️ Architecture

SetTimer follows clean architecture principles with MVC pattern:

```
lib/
├── controllers/          # Business logic and state management
│   └── timer_controller.dart
├── models/              # Data models
│   └── timer_model.dart
├── services/            # External services
│   ├── audio_service.dart
│   └── background_service.dart
├── views/               # UI components
│   └── timer_view.dart
└── main.dart           # App entry point
```

### Key Technologies

- **State Management**: Provider pattern
- **Audio**: flutter_ringtone_player for system sounds
- **Background Processing**: Custom lifecycle management
- **UI**: Material Design 3 with custom dark theme

## 🎨 Design Philosophy

SetTimer embraces minimalism with a focus on:

- **Zero Distraction**: Clean interface without unnecessary elements
- **Workout Flow**: Automatic progression eliminates manual intervention
- **Visual Clarity**: High contrast dark theme with accent colors
- **Accessibility**: Large touch targets and clear visual hierarchy

### Color Palette

- **Primary (Work)**: `#00D4AA` - Energizing teal
- **Secondary (Rest)**: `#FF6B35` - Calming orange
- **Background**: `#0A0A0A` to `#2A2A2A` gradient
- **Text**: White with varying opacity for hierarchy

## 🔧 Configuration

### Default Settings
- **Sets**: 3
- **Set Duration**: 30 seconds
- **Rest Duration**: 10 seconds
- **Rest Interval**: Every 1 set

### Customization Ranges
- **Total Sets**: 1-20
- **Set Duration**: 10-300 seconds
- **Rest Duration**: 5-120 seconds
- **Rest Interval**: 1-5 sets

## 📱 Platform Support

### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 34 (Android 14)
- **Permissions**: WAKE_LOCK, VIBRATE
- **Features**: Background processing, system sounds

### iOS
- **Deployment Target**: iOS 12.0+
- **Orientation**: Portrait only
- **Background Modes**: background-processing, background-fetch
- **Audio**: Background audio session support

## 🧪 Testing

### Manual Testing Checklist

- [ ] Timer counts down correctly
- [ ] Set transitions work automatically
- [ ] Rest periods trigger at correct intervals
- [ ] Background mode maintains timer
- [ ] Sound alerts play at appropriate times
- [ ] Settings persist between sessions
- [ ] App handles orientation locks
- [ ] No crashes during extended use

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Development Guidelines

- Follow Flutter best practices
- Maintain clean architecture separation
- Add tests for new features
- Update documentation for API changes
- Use conventional commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- flutter_ringtone_player package for audio functionality
- Provider package for state management

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/JosephDoUrden/SetTimer/issues)
- **Email**: yusufhansck@gmail.com
- **Documentation**: [Wiki](https://github.com/JosephDoUrden/SetTimer/wiki)

## 👨‍💻 Author

**Yusufhan Saçak**
- **Email:** yusufhansck@gmail.com
- **Medium:** [My Medium Profile](https://medium.com/@yusufhansacak)
- **Twitter:** [@0xSCK](https://twitter.com/0xSCK)
- **LinkedIn:** [Yusufhan Saçak](https://www.linkedin.com/in/yusufhansacak/)
- **Website:** [yusufhan.dev](https://yusufhan.dev/)

---

**SetTimer** - Focus on your workout, let us handle the timing. 💪

Built with ❤️ using Flutter
