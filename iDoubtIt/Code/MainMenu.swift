//
//  MainMenu.swift
//  iDoubtIt
//

import Foundation
import SpriteKit
import UIKit

class MainMenu: SKScene, LayoutResizing {

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        GameLayout.configure(for: size)
        buildUI()
    }

    func layoutForCurrentSize() {
        GameLayout.configure(for: size)
        removeAllChildren()
        buildUI()
    }

    private func buildUI() {
        GameTheme.addBackground(to: self, size: size)

        GameAudio.shared.unlock()
        GameAudio.shared.applyVolumes()
        if Pref.shared.musicOn { GameAudio.shared.syncMusic() }
        else { GameAudio.shared.stopMusic() }

        let L = GameLayout.current
        let cx = size.width / 2

        let phoneLandscape = L.isPhone && L.isLandscape
        let suits = SKLabelNode(text: "♠  ♥  ♦  ♣")
        suits.fontName = GameTheme.titleFont
        suits.fontSize = phoneLandscape ? min(28, size.height * 0.07) : min(34, size.width * 0.085)
        suits.fontColor = UIColor.white.withAlphaComponent(0.35)
        suits.position = CGPoint(x: cx, y: size.height * (phoneLandscape ? 0.84 : 0.72))
        suits.zPosition = 1
        addChild(suits)

        let title = GameTheme.makeTitleLabel("iDoubtIt", fontSize: L.titleSize)
        title.position = CGPoint(x: cx, y: size.height * (phoneLandscape ? 0.72 : 0.62))
        title.zPosition = 2
        addChild(title)

        let subtitle = GameTheme.makeSubtitleLabel("Play with friends or watch the AIs", fontSize: L.subtitleSize)
        subtitle.position = CGPoint(x: cx, y: size.height * (phoneLandscape ? 0.62 : 0.54))
        subtitle.zPosition = 2
        addChild(subtitle)

        let buttonY: [CGFloat] = phoneLandscape ? [0.48, 0.36, 0.24] : (L.isPhone ? [0.44, 0.32, 0.20] : [0.40, 0.30, 0.20])
        let playButton = button(name: "Play", color: GameTheme.buttonGreen, label: "Play", style: .menu)
        playButton.position = CGPoint(x: cx, y: size.height * buttonY[0])
        addChild(playButton)

        let watchButton = button(name: "Watch", color: GameTheme.buttonGray, label: "Watch AI", style: .menu)
        watchButton.position = CGPoint(x: cx, y: size.height * buttonY[1])
        addChild(watchButton)

        let settingsButton = button(name: "Settings", color: GameTheme.buttonGray, label: "Settings", style: .menu)
        settingsButton.position = CGPoint(x: cx, y: max(size.height * buttonY[2], L.margins.bottom + 44))
        addChild(settingsButton)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        GameAudio.shared.unlock()
        GameAudio.shared.ui()
        let node = atPoint(touch.location(in: self))
        let btnNode = buttonNode(from: node)

        switch btnNode?.name {
        case "Playbtn":
            presentPlayScene(mode: .humanPlay)
        case "Watchbtn":
            presentPlayScene(mode: .watchAI)
        case "Settingsbtn":
            presentScene(SettingsMenu(size: size))
        default:
            break
        }
    }

    private func buttonNode(from node: SKNode) -> SKNode? {
        var current: SKNode? = node
        while let c = current {
            if c.name?.hasSuffix("btn") == true { return c }
            current = c.parent
        }
        return nil
    }

    private func presentPlayScene(mode: PlayMode) {
        GameLayout.configure(for: size)
        let scene = PlayScene(size: size)
        scene.playMode = mode
        presentScene(scene)
    }

    private func presentScene(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.showsFPS = false
        view?.showsNodeCount = false
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
