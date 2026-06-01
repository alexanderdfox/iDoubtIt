//
//  MainMenu.swift
//  iDoubtIt
//

import Foundation
import SpriteKit
import UIKit

class MainMenu: SKScene {

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        let sceneSize = CGSize(width: screenWidth, height: screenHeight)
        GameTheme.addBackground(to: self, size: sceneSize)

        let suits = SKLabelNode(text: "♠  ♥  ♦  ♣")
        suits.fontName = GameTheme.titleFont
        suits.fontSize = 36
        suits.fontColor = UIColor.white.withAlphaComponent(0.35)
        suits.position = CGPoint(x: screenWidth / 2, y: screenHeight * 0.62)
        suits.zPosition = 1
        addChild(suits)

        let title = GameTheme.makeTitleLabel("iDoubtIt", fontSize: 48)
        title.position = CGPoint(x: screenWidth / 2, y: screenHeight * 0.52)
        title.zPosition = 2
        addChild(title)

        let subtitle = GameTheme.makeSubtitleLabel("The bluffing card game")
        subtitle.position = CGPoint(x: screenWidth / 2, y: screenHeight * 0.44)
        subtitle.zPosition = 2
        addChild(subtitle)

        let playButton = button(name: "Play", color: GameTheme.buttonGreen, label: "Play")
        playButton.position = CGPoint(x: screenWidth / 2 - 105, y: screenHeight * 0.32)
        addChild(playButton)

        let settingsButton = button(name: "Settings", color: GameTheme.buttonGray, label: "Settings")
        settingsButton.position = CGPoint(x: screenWidth / 2 + 105, y: screenHeight * 0.32)
        addChild(settingsButton)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
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

    private func presentScene(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.showsFPS = false
        view?.showsNodeCount = false
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
