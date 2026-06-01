//
//  SceneDelegate.swift
//  iDoubtIt
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let root = GameViewController()
        window.rootViewController = root
        window.backgroundColor = GameTheme.backgroundTop
        self.window = window
        window.makeKeyAndVisible()

        configureMacCatalystWindow(windowScene)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }
        configureMacCatalystWindow(windowScene)
    }

    @available(iOS 16.0, *)
    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdateEffectiveGeometry geometry: UIWindowScene.Geometry
    ) {
        window?.rootViewController?.view.setNeedsLayout()
    }

    // MARK: - Mac Catalyst window

    private func configureMacCatalystWindow(_ windowScene: UIWindowScene) {
        #if targetEnvironment(macCatalyst)
        if let restrictions = windowScene.sizeRestrictions {
            restrictions.minimumSize = CGSize(width: 900, height: 560)
            restrictions.maximumSize = .zero
        }

        if #available(iOS 16.0, *) {
            let preferences = UIWindowScene.GeometryPreferences.Mac()
            windowScene.requestGeometryUpdate(preferences) { error in
                if error != nil {
                    print("Mac geometry update failed: \(error)")
                }
            }
        }

        guard let window = windowScene.windows.first else { return }
        let targetFrame = windowScene.screen.bounds
        if window.frame.size != targetFrame.size {
            window.frame = targetFrame
        }
        window.rootViewController?.view.setNeedsLayout()
        #endif
    }
}
