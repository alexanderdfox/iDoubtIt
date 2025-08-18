import Foundation
import SpriteKit
import UIKit

class SettingsMenu: SKScene {
    
    // MARK: - Init
    override init(size: CGSize = screenSize.size) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene setup
    override func didMove(to view: SKView) {
        // Background
        let bg = SKSpriteNode(color: Pref.shared.backgroundColor, size: self.size)
        bg.anchorPoint = .zero
        bg.position = .zero
        bg.zPosition = -1
        addChild(bg)
        
        // Back button (top-left)
        let backButton = button(name: "Back", color: .darkGray, label: "Back")
        
        // Make sure it stays fully on screen
        let margin: CGFloat = 20
        let halfWidth = backButton.size.width / 2
        let halfHeight = backButton.size.height / 2
        backButton.position = CGPoint(x: halfWidth + margin,
                                      y: size.height - halfHeight - margin)
        backButton.zPosition = 999
        addChild(backButton)
        
        // Toggle buttons (centered)
        addSettingButton(name: "Wacky", label: "Wacky", yOffset: 40, isActive: Pref.shared.isWacky)
        addSettingButton(name: "Sound", label: "Sound", yOffset: -40, isActive: Pref.shared.soundOn)
        
        // Difficulty button (bottom-center)
        addDifficultyButton()
    }
    
    // MARK: - Toggle button helper
    private func addSettingButton(name: String, label: String, yOffset: CGFloat, isActive: Bool) {
        let btnColor: UIColor = isActive ? .systemGreen : .systemRed
        let btn = button(name: name, color: btnColor, label: label)
        btn.position = CGPoint(x: size.width / 2, y: size.height / 2 + yOffset)
        addChild(btn)
    }
    
    // MARK: - Difficulty button helper
    private func addDifficultyButton() {
        let current = Pref.shared.difficulty
        let btnColor: UIColor
        switch current {
        case Difficulty.easy.rawValue: btnColor = .systemGreen
        case Difficulty.medium.rawValue: btnColor = .systemYellow
        case Difficulty.hard.rawValue: btnColor = .systemRed
        default: btnColor = .systemGreen
        }
        
        let btn = button(name: "Difficulty", color: btnColor, label: "Difficulty")
        btn.position = CGPoint(x: size.width / 2, y: size.height / 4)
        addChild(btn)
    }
    
    // MARK: - Touch handling
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
                
                switch nextDifficulty {
                case Difficulty.easy.rawValue: button.color = .systemGreen
                case Difficulty.medium.rawValue: button.color = .systemYellow
                case Difficulty.hard.rawValue: button.color = .systemRed
                default: button.color = .systemGreen
                }
                
            case "Wackybtn":
                Pref.shared.isWacky.toggle()
                button.color = Pref.shared.isWacky ? .systemGreen : .systemRed
                
            case "Soundbtn":
                Pref.shared.soundOn.toggle()
                button.color = Pref.shared.soundOn ? .systemGreen : .systemRed
                
            default: break
            }
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
