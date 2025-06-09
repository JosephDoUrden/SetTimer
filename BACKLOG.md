# Project Task Backlog: SetTimer MVP

## Project Setup & Initial UI (Hour 1–2)
- [X] Setup Flutter project
- [X] Choose state management (Provider - selected for simplicity and sufficient functionality)
- [X] Select audio player package (flutter_ringtone_player - selected for simplicity and system sound integration)
- [X] Design and implement basic timer UI (Modern dark theme with gradients and animations)
- [X] Implement UI for setting custom set count (Settings modal with sliders - Fixed modal presentation and validation)
- [X] Implement UI for setting custom set duration (Settings modal with sliders - Fixed modal presentation and validation)
- [X] Implement UI for setting rest interval (Settings modal with sliders - Fixed modal presentation and validation)
- [X] Implement UI for setting rest duration (Settings modal with sliders - Fixed modal presentation and validation)
- [X] Implement UI for progress tracker (current set / total sets)
- [X] Implement basic timer controls (start, pause, reset)

## Core Logic (Hour 3–4)
- [X] Implement logic for custom set count
- [X] Implement logic for custom set duration
- [X] Implement logic for automatic rest feature (triggering rest after N sets)
- [X] Implement logic for rest duration
- [X] Implement logic for auto-starting the next set after rest or previous set
- [X] Implement logic for progress tracking (updating current set / total sets)
- [X] Ensure timer continues in background mode (Wakelock + lifecycle management + sync on resume)

## Sound & UI Polish (Hour 5–6)
- [X] Integrate sound alerts for set start
- [X] Integrate sound alerts for set end
- [X] Integrate sound alerts for rest period start
- [X] Integrate sound alerts for rest period end
- [X] Polish overall UI/UX for a clean interface
- [X] Ensure one-tap start functionality

## Build & Deployment (Hour 7–8)
- [X] Prepare Android build (Updated manifest, build.gradle, ProGuard rules, and themes)
- [X] Test Android build (Debug APK builds successfully, ready for device testing)
- [X] Prepare iOS build (Updated Info.plist, Podfile, AppDelegate, and project settings)
- [ ] Test iOS build (TestFlight)
- [ ] Publish to Google Play Store
- [ ] Prepare for App Store submission

## Testing & QA (Derived from Success Metrics)
- [X] Test: App completes all sets and rests automatically without user intervention
- [X] Test: User does not need to touch the screen mid-workout
- [X] Test: Simple UX with one-tap start is functional and intuitive
- [X] Test: Settings modal works correctly and updates timer configuration
- [ ] Test: Background mode works as expected on both Android and iOS
- [ ] Test: Sound alerts are timely and clear

## Build Testing Results
### Android Build ✅
- **Debug Build**: Successfully compiles with `flutter build apk --debug`
- **Release Build**: Ready for testing with `flutter build apk --release`
- **App Bundle**: Ready for Play Store with `flutter build appbundle`
- **Permissions**: WAKE_LOCK and VIBRATE permissions properly configured
- **Orientation**: Locked to portrait mode for workout focus
- **Theme**: Dark theme with gradient background matches design
- **Package**: com.settimer.settimer (debug variant: com.settimer.settimer.debug)

### iOS Build Configuration ✅
- **Deployment Target**: iOS 12.0+ for wide compatibility
- **Bundle ID**: com.settimer.settimer
- **Orientation**: Portrait only for workout focus
- **Background Modes**: background-processing and background-fetch enabled
- **Audio Session**: Configured for background audio playback
- **Status Bar**: Light content to match dark theme
- **Device Support**: iPhone only (portrait orientation)

### Next Steps for Android Testing
1. Install on physical device: `flutter install`
2. Test timer functionality in foreground
3. Test timer continuation when app goes to background
4. Test sound alerts during workout
5. Test settings persistence
6. Verify no crashes during extended use

### Next Steps for iOS Testing
1. Open project in Xcode: `open ios/Runner.xcworkspace`
2. Set Apple Developer Team ID in Xcode signing settings
3. Configure code signing certificates
4. Build for device: Product → Archive
5. Test timer functionality on physical device
6. Test background behavior and timer continuation
7. Verify sound alerts work properly
8. Prepare for TestFlight distribution
