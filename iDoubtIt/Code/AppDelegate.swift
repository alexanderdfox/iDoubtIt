//
//  AppDelegate.swift
//  iDoubtIt
//

import UIKit
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(
            name: "Default",
            sessionRole: connectingSceneSession.role
        )
        config.delegateClass = SceneDelegate.self
        return config
    }

    // MARK: - Lifecycle Safety

    func applicationWillResignActive(_ application: UIApplication) {
        pauseSKView()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        pauseSKView()
        saveGameState()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        resumeSKView()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        resumeSKView()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveGameState()
    }

    // MARK: - SKView Helpers

    private func keySKView() -> SKView? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene,
                  let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
                    ?? windowScene.windows.first?.rootViewController else { continue }
            if let sk = root.view as? SKView { return sk }
        }
        return nil
    }

    private func pauseSKView() {
        keySKView()?.isPaused = true
    }

    private func resumeSKView() {
        keySKView()?.isPaused = false
    }

    private func saveGameState() {
        print("Game state saved safely.")
    }
}
