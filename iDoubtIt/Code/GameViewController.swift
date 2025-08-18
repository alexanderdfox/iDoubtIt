//
//  GameViewController.swift
//  iDoubtIt
//
//  Updated 2025
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow this controller to respond to key events
        self.becomeFirstResponder()
        
        setupScene()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        // Create SKView if it doesn't exist
        let skView: SKView
        if let existingSKView = self.view as? SKView {
            skView = existingSKView
        } else {
            skView = SKView(frame: self.view.bounds)
            self.view = skView
        }
        
        // Create and configure the main menu scene
        let scene = MainMenu(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = UIColor.systemBlue  // Plain blue background
        
        // Configure SKView debugging info (optional)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = false
        
        // Present the scene with a smooth fade transition
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Responder
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
