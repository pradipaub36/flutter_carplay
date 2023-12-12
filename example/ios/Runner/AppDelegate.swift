import Flutter
import os
import UIKit

let flutterEngine = FlutterEngine(name: "SharedEngine", project: nil, allowHeadlessExecution: true)

@UIApplicationMain
@available(iOS 14.0, *)
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Custom Logs")
        logger.log("App Delegate called")
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)
        logger.log("Flutter engine ran from app delegate")

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
