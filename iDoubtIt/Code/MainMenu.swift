//
//  MainMenu.swift
//  iDoubtIt
//
//  Updated 2025 — Uses base button factory
//

import Foundation
import SpriteKit
import UIKit

class MainMenu: SKScene {

    // MARK: - Init
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        // Background: use color from preferences
        let bg = SKSpriteNode(color: Pref.shared.backgroundColor,
                              size: CGSize(width: screenWidth, height: screenHeight))
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.zPosition = -1
        addChild(bg)
        
        // MARK: - Buttons
        let playButton = button(name: "Play", color: .darkGray, label: "Play")
        playButton.position = CGPoint(x: screenWidth / 2 - 100, y: screenHeight / 2)
        addChild(playButton)
        
        let settingsButton = button(name: "Settings", color: .darkGray, label: "Settings")
        settingsButton.position = CGPoint(x: screenWidth / 2 + 100, y: screenHeight / 2)
        addChild(settingsButton)
    }

    // MARK: - Touch handling
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

        // Determine the actual button node
        let btnNode = (node.name?.hasSuffix("btn") ?? false) ? node : node.parent

        switch btnNode?.name {
        case "Playbtn":
            presentScene(PlayScene(size: view?.bounds.size ?? CGSize(width: screenWidth, height: screenHeight)))
        case "Settingsbtn":
            presentScene(SettingsMenu(size: view?.bounds.size ?? CGSize(width: screenWidth, height: screenHeight)))
        default:
            break
        }
    }

    // MARK: - Scene transition helper
    private func presentScene(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.showsFPS = true
        view?.showsNodeCount = true
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
