# Backlog for Ads and Analytics Integrations

## Phase 1: Google Analytics (Firebase) Integration

This phase focuses on setting up the basic analytics infrastructure to understand user behavior and measure application engagement.

### Sprint 1: Basic Setup and Event Tracking
- [ ] Create a Firebase project and connect it to the Flutter application.
- [ ] Add the `firebase_core` and `firebase_analytics` packages to the project.
- [ ] Configure the `GoogleService-Info.plist` file for iOS.
- [ ] Configure the `google-services.json` file and `build.gradle` files for Android.
- [ ] Initialize Firebase Analytics to automatically track app opens and screen views (screen_view).
- [ ] Create custom events for basic user actions:
    - [ ] `workout_start` (when the user starts a workout)
    - [ ] `workout_pause` (when the user pauses a workout)
    - [ ] `workout_reset` (when the user resets a workout)
    - [ ] `workout_complete` (when the user completes a workout)
- [ ] Create events for settings changes:
    - [ ] `settings_change_sets` (when the number of sets is changed)
    - [ ] `settings_change_duration` (when the set duration is changed)
    - [ ] `settings_change_rest` (when the rest duration is changed)
- [ ] Verify that events are being triggered correctly using Firebase DebugView.

### Sprint 2: Advanced Analytics and Reporting
- [ ] Create funnels in the Firebase console to track the user's workout completion flow (e.g., `app_open` -> `workout_start` -> `workout_complete`).
- [ ] Set up user properties to segment users (e.g., `pro_user`, `selected_sound_pack`).
- [ ] Create an event to track preset usage: `preset_selected` (pass which preset was selected as a parameter).
- [ ] Add events to track ad interactions (after Phase 2):
    - [ ] `ad_reward_prompt`
    - [ ] `ad_reward_impression`
    - [ ] `interstitial_ad_prompt`
    - [ ] `interstitial_ad_impression`
- [ ] Create weekly/monthly reporting dashboards based on analytics data.

## Phase 2: Ad Integration (Google AdMob)

This phase focuses on integrating ad models to generate revenue from the application.

### Sprint 3: Banner and Interstitial Ads
- [ ] Create a Google AdMob account and create ad units for the application (Banner, Interstitial, Rewarded).
- [ ] Add the `google_mobile_ads` package to the project.
- [ ] Complete platform-specific configurations by adding the AdMob App ID for Android (`AndroidManifest.xml`) and iOS (`Info.plist`).
- [ ] Add a persistent banner ad at the bottom of the timer screen for non-pro users.
- [ ] Implement an interstitial ad to be shown after a workout is completed.
- [ ] Create robust logic to manage ad loading, display, and potential errors (e.g., no internet).
- [ ] Ensure that ads are only shown to "free" (non-pro) users (based on the `purchases_flutter` integration).
- [ ] Use test Ad IDs during the development process.

### Sprint 4: Rewarded Ads and Optimization
- [ ] Offer users a rewarded ad option they can watch in exchange for a specific reward.
    - [ ] Example Reward: "Unlock a premium sound pack for 24 hours by watching an ad."
- [ ] Implement logic to verify the completion of the rewarded ad and grant the reward to the user.
- [ ] Plan A/B tests to ensure that ad placements and frequency do not negatively impact the user experience.
- [ ] Replace test ad IDs with real AdMob ad unit IDs before publishing the app.
- [ ] Review compliance with ad policies for the App Store and Google Play Store. 