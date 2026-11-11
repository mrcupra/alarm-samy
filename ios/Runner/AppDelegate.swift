import Flutter
import UIKit
import AVFoundation
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    configurePersistentAudioSession()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configurePersistentAudioSession() {
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth]
      )
      try session.setActive(true)
    } catch {
      print("Alarm Samy AVAudioSession error: \(error)")
    }
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    configurePersistentAudioSession()
    if backgroundTaskId == .invalid {
      backgroundTaskId = application.beginBackgroundTask(withName: "AlarmSamyLockScreenGuardian") { [weak self] in
        if let id = self?.backgroundTaskId, id != .invalid {
          application.endBackgroundTask(id)
          self?.backgroundTaskId = .invalid
        }
      }
    }
    super.applicationDidEnterBackground(application)
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    if backgroundTaskId != .invalid {
      application.endBackgroundTask(backgroundTaskId)
      backgroundTaskId = .invalid
    }
    configurePersistentAudioSession()
    super.applicationWillEnterForeground(application)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
