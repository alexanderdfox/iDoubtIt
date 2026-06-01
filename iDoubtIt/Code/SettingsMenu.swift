import Foundation
import SpriteKit
import UIKit

class SettingsMenu: SKScene {

    override init(size: CGSize = screenSize.size) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        GameTheme.addBackground(to: self, size: size)

        let title = GameTheme.makeTitleLabel("Settings", fontSize: 34)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        addChild(title)

        let panel = GameTheme.makeHUDPanel(width: min(size.width - 48, 300), height: 200)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        panel.zPosition = 0
        addChild(panel)

        let backButton = button(name: "Back", color: GameTheme.buttonGray, label: "Back")
        let margin: CGFloat = 20
        backButton.position = CGPoint(
            x: backButton.size.width / 2 + margin,
            y: size.height - backButton.size.height / 2 - margin
        )
        backButton.zPosition = 999
        addChild(backButton)

        addSettingButton(name: "Wacky", label: "Wacky", yOffset: 50, isActive: Pref.shared.isWacky)
        addSettingButton(name: "Sound", label: "Sound", yOffset: -10, isActive: Pref.shared.soundOn)
        addDifficultyButton()
    }

    private func addSettingButton(name: String, label: String, yOffset: CGFloat, isActive: Bool) {
        let btnColor: UIColor = isActive ? GameTheme.buttonGreen : GameTheme.buttonRed
        let btn = button(name: name, color: btnColor, label: label)
        btn.position = CGPoint(x: size.width / 2, y: size.height / 2 + yOffset)
        btn.zPosition = 1
        addChild(btn)
    }

    private func addDifficultyButton() {
        let current = Pref.shared.difficulty
        let btnColor: UIColor
        switch current {
        case Difficulty.easy.rawValue: btnColor = GameTheme.buttonGreen
        case Difficulty.medium.rawValue: btnColor = UIColor(red: 0.95, green: 0.72, blue: 0.12, alpha: 1)
        case Difficulty.hard.rawValue: btnColor = GameTheme.buttonRed
        default: btnColor = GameTheme.buttonGreen
        }

        let btn = button(name: "Difficulty", color: btnColor, label: "Difficulty")
        btn.position = CGPoint(x: size.width / 2, y: size.height / 2 - 70)
        btn.zPosition = 1
        addChild(btn)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            let btnNode = (node.name?.hasSuffix("btn") ?? false) ? node as? SKSpriteNode : node.parent as? SKSpriteNode
            guard let button = btnNode, let name = button.name else { continue }

            switch name {
            case "Backbtn":
                presentScene(MainMenu(size: size))

            case "Difficultybtn":
                var nextDifficulty = Difficulty.easy.rawValue
                switch Pref.shared.difficulty {
                case Difficulty.easy.rawValue: nextDifficulty = Difficulty.medium.rawValue
                case Difficulty.medium.rawValue: nextDifficulty = Difficulty.hard.rawValue
                case Difficulty.hard.rawValue: nextDifficulty = Difficulty.easy.rawValue
                default: nextDifficulty = Difficulty.easy.rawValue
                }
                Pref.shared.difficulty = nextDifficulty
                updateDifficultyButtonAppearance(button, difficulty: nextDifficulty)

            case "Wackybtn":
                Pref.shared.isWacky.toggle()
                button.color = Pref.shared.isWacky ? GameTheme.buttonGreen : GameTheme.buttonRed
                updateButtonFill(button, color: button.color)

            case "Soundbtn":
                Pref.shared.soundOn.toggle()
                button.color = Pref.shared.soundOn ? GameTheme.buttonGreen : GameTheme.buttonRed
                updateButtonFill(button, color: button.color)

            default: break
            }
        }
    }

    private func updateDifficultyButtonAppearance(_ button: SKSpriteNode, difficulty: Int) {
        let color: UIColor
        switch difficulty {
        case Difficulty.easy.rawValue: color = GameTheme.buttonGreen
        case Difficulty.medium.rawValue: color = UIColor(red: 0.95, green: 0.72, blue: 0.12, alpha: 1)
        case Difficulty.hard.rawValue: color = GameTheme.buttonRed
        default: color = GameTheme.buttonGreen
        }
        button.color = color
        updateButtonFill(button, color: color)
    }

    private func updateButtonFill(_ button: SKSpriteNode, color: UIColor) {
        button.children.compactMap { $0 as? SKShapeNode }.forEach { shape in
            if shape.strokeColor == .black { shape.fillColor = color }
        }
    }

    private func presentScene(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.showsFPS = false
        view?.showsNodeCount = false
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
