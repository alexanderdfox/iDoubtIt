import UIKit
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Use GameViewController as root
        let rootVC = GameViewController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        return true
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

    private func pauseSKView() {
        // Safely pause SKView if it exists
        if let skView = window?.rootViewController?.view as? SKView {
            skView.isPaused = true
        }
    }

    private func resumeSKView() {
        if let skView = window?.rootViewController?.view as? SKView {
            skView.isPaused = false
        }
    }

    // MARK: - Game State Saving

    private func saveGameState() {
        // Replace with actual game saving logic
        print("Game state saved safely.")
    }
}
