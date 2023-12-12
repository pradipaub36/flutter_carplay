//
//  FlutterCarplayPluginSceneDelegate.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 21.08.2021.
//

import CarPlay
import os

@available(iOS 14.0, *)
class FlutterCarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private static var interfaceController: CPInterfaceController?
    private static var carWindow: CPWindow?
    private static var rootViewController: UIViewController?
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Custom Logs")

    public static func forceUpdateRootTemplate() {
        FlutterCarPlaySceneDelegate.logger.log("forceUpdateRootTemplate called")
        let rootTemplate = SwiftFlutterCarplayPlugin.rootTemplate
        let animated = SwiftFlutterCarplayPlugin.animated
        if carWindow == nil { FlutterCarPlaySceneDelegate.logger.log("Car window is null")
        }
        if rootViewController == nil { FlutterCarPlaySceneDelegate.logger.log("root view controller is null")
        }
        carWindow?.rootViewController = rootViewController

        interfaceController?.setRootTemplate(rootTemplate!, animated: animated)
    }

    // Fired when just before the carplay become active
    func sceneDidBecomeActive(_: UIScene) {
        SwiftFlutterCarplayPlugin.onCarplayConnectionChange(status: FCPConnectionTypes.connected)
    }

    // Fired when carplay entered background
    func sceneDidEnterBackground(_: UIScene) {
        SwiftFlutterCarplayPlugin.onCarplayConnectionChange(status: FCPConnectionTypes.background)
    }

    public static func pop(animated: Bool) {
        interfaceController?.popTemplate(animated: animated)
    }

    public static func popToRootTemplate(animated: Bool) {
        interfaceController?.popToRootTemplate(animated: animated)
    }

    public static func push(template: CPTemplate, animated: Bool) {
        interfaceController?.pushTemplate(template, animated: animated)
    }

    public static func closePresent(animated: Bool) {
        interfaceController?.dismissTemplate(animated: animated)
    }

    public static func presentTemplate(template: CPTemplate, animated: Bool,
                                       onPresent: @escaping (_ completed: Bool) -> Void)
    {
        interfaceController?.presentTemplate(template, animated: animated, completion: { completed, error in
            guard error != nil else {
                onPresent(false)
                return
            }
            onPresent(completed)
        })
    }

    func templateApplicationScene(_: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController, to window: CPWindow)
    {
        FlutterCarPlaySceneDelegate.logger.log("CarPlay connected")
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            FlutterCarPlaySceneDelegate.interfaceController = interfaceController
            FlutterCarPlaySceneDelegate.carWindow = window

            SwiftFlutterCarplayPlugin.onCarplayConnectionChange(status: FCPConnectionTypes.connected)
            let rootTemplate = SwiftFlutterCarplayPlugin.rootTemplate
            let rootViewController = SwiftFlutterCarplayPlugin.rootViewController

            guard rootTemplate != nil, rootViewController != nil else {
                if rootTemplate == nil { FlutterCarPlaySceneDelegate.logger.log("didConnect: rootTemplate is null")
                }
                if rootViewController == nil { FlutterCarPlaySceneDelegate.logger.log("didConnect: root view controller is null")
                }
                // FlutterCarPlaySceneDelegate.interfaceController = nil
                return
            }

            FlutterCarPlaySceneDelegate.carWindow?.rootViewController = rootViewController
            FlutterCarPlaySceneDelegate.rootViewController = rootViewController

            FlutterCarPlaySceneDelegate.interfaceController?.setRootTemplate(rootTemplate!, animated: SwiftFlutterCarplayPlugin.animated)
        }
    }

    func templateApplicationScene(_: CPTemplateApplicationScene,
                                  didDisconnect _: CPInterfaceController, from _: CPWindow)
    {
        FlutterCarPlaySceneDelegate.logger.log("CarPlay disconnected")
        SwiftFlutterCarplayPlugin.onCarplayConnectionChange(status: FCPConnectionTypes.disconnected)

        // FlutterCarPlaySceneDelegate.interfaceController = nil
    }

    func templateApplicationScene(_: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController _: CPInterfaceController)
    {
        SwiftFlutterCarplayPlugin.onCarplayConnectionChange(status: FCPConnectionTypes.disconnected)

        // FlutterCarPlaySceneDelegate.interfaceController = nil
    }
}
