# Product Requirement Document: SetTimer

## Overview
SetTimer is a minimalist workout timer tailored specifically for ab/core workouts. It enables users to focus solely on their sets without manually tracking time or breaks.

## Target Audience
- Fitness enthusiasts
- Beginners doing home workouts
- People following HIIT or set-based training

## Key Features
1. **Custom Set Count** - Users can select number of sets (e.g. 9)
2. **Custom Set Duration** - Users can set duration per set (e.g. 30 sec)
3. **Auto Rest Feature** - Users can define rest interval (e.g. every 3 sets)
4. **Rest Duration** - Fixed or custom (e.g. 30 seconds)
5. **Auto Start Next Set** - App will automatically start next set
6. **Progress Tracker** - Shows current set / total sets
7. **Sound Alerts** - Start, end, and rest periods will be indicated with sound
8. **Clean UI** - Focused only on current timer and controls
9. **Background Mode Support** - Keeps working when screen is locked

## Out of Scope for MVP
- Workout history or tracking
- Different workout types (cardio, strength etc.)
- Social or community features
- User authentication

## Technical Stack
- Flutter 3.x
- Provider or simple GetX for state management
- `assets_audio_player` or `flutter_ringtone_player` for sounds
- Minimal animation with `flutter_countdown_timer` or custom `Timer.periodic`

## Milestones (Day Plan)
- **Hour 1–2:** Setup project, timer UI
- **Hour 3–4:** Logic for set/rest switching
- **Hour 5–6:** Add sound and polish UI
- **Hour 7:** Android + iOS build
- **Hour 8:** Publish to Play Store & prepare App Store (TestFlight)

## Success Metrics
- App finishes all sets/rests automatically
- User never has to touch screen mid-workout
- Simple UX with one-tap start
