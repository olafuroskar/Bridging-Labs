import Flutter
import AVFAudio
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      do {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default, options: [])
        try audioSession.setActive(true)
        print("Audio session successfully configured.")
      } catch {
        print("Failed to set audio session: \(error)")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
