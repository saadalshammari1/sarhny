import Flutter
import FirebaseMessaging
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Trigger the APNs handshake explicitly. FlutterFire asks for the FCM token
    // from Dart after login, but iOS may otherwise delay APNs registration long
    // enough for Firebase Messaging to report "APNS token has not been set yet".
    application.registerForRemoteNotifications()

    // Clear any stale badge on cold launch — if the user already tapped the
    // app icon, the badge should reset even before any notifications screen
    // is opened.
    clearBadge(application)
    return result
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    // Fires on every foreground transition, not just cold launches. This is
    // what fixes the "badge stuck after opening the app" report.
    clearBadge(application)
  }

  private func clearBadge(_ application: UIApplication) {
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    } else {
      application.applicationIconBadgeNumber = 0
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("Sarhny APNs registration failed: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
