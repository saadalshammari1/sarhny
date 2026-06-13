import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Firebase.initializeApp runs Dart-side after didFinishLaunchingWithOptions
    // returns, so FlutterFire's APNs-registration swizzling misses this window.
    // Trigger the APNs handshake here so the device token can arrive before
    // FCM asks for it.
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
