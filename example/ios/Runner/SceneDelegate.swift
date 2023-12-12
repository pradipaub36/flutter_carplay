//
//  SceneDelegate.swift
//  Runner
//
//  Created by Oğuzhan Atalay on 20.08.2021.
//

import os

@available(iOS 14.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Custom Logs")

        window = UIWindow(windowScene: windowScene)
        // let flutterEngine = FlutterEngine(name: "SceneDelegateEngine")
        // flutterEngine.run()
        // GeneratedPluginRegistrant.register(with: flutterEngine)

        logger.log("Flutter engine ran from scene delegate")
        let controller = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        logger.log("Flutter view controller assigned from scene delegate")
    }
}
