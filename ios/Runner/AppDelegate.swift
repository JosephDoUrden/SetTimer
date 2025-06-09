import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Configure audio session for background playback
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Failed to configure audio session: \(error)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    super.applicationDidEnterBackground(application)
    // App entered background - timer should continue via Flutter's lifecycle management
  }
  
  override func applicationWillEnterForeground(_ application: UIApplication) {
    super.applicationWillEnterForeground(application)
    // App returning to foreground - Flutter will handle timer sync
  }
}
