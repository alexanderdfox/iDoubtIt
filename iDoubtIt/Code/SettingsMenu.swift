import Foundation
import SpriteKit
import UIKit

class SettingsMenu: SKScene, LayoutResizing {

    private var valueButtons: [String: SKSpriteNode] = [:]

    override init(size: CGSize = screenSize.size) {
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
        valueButtons.removeAll()
        buildUI()
    }

    private func buildUI() {
        let L = GameLayout.current
        GameTheme.addBackground(to: self, size: size)

        let title = GameTheme.makeTitleLabel("Settings", fontSize: min(34, L.titleSize))
        title.position = CGPoint(x: size.width / 2, y: size.height - L.margins.top - 24)
        addChild(title)

        let intro = GameTheme.makeSubtitleLabel("Options apply to your next game.", fontSize: L.subtitleSize)
        intro.position = CGPoint(x: size.width / 2, y: title.position.y - 30)
        addChild(intro)

        let backButton = button(name: "Back", color: GameTheme.buttonGray, label: "Back", style: .compact)
        backButton.position = CGPoint(
            x: L.margins.horizontal + backButton.size.width / 2,
            y: size.height - L.margins.top - backButton.size.height / 2
        )
        backButton.zPosition = 999
        addChild(backButton)

        let panelW = L.settingsPanelWidth
        let rowH = L.settingsRowHeight
        let panelH = rowH * 7 + 20
        let panel = GameTheme.makeHUDPanel(width: panelW, height: panelH)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.46)
        panel.zPosition = 0
        addChild(panel)

        let rows = ["Humans", "Wacky", "Sound", "SfxVol", "Music", "MusicVol", "Difficulty"]
        let startY = panel.position.y + panelH / 2 - rowH * 0.6
        let captionX = size.width / 2 - panelW / 2 + 18
        let buttonX = size.width / 2 + panelW / 2 - L.buttonCompactSize.width / 2 - 12

        for (i, name) in rows.enumerated() {
            let y = startY - CGFloat(i) * rowH
            let caption = GameTheme.makeCaptionLabel(labelCaption(for: name))
            caption.fontSize = L.captionSize
            caption.position = CGPoint(x: captionX, y: y)
            caption.zPosition = 1
            addChild(caption)

            let btn = button(name: name, color: GameTheme.buttonGreen, label: "—", style: .compact)
            btn.position = CGPoint(x: buttonX, y: y)
            btn.zPosition = 2
            addChild(btn)
            valueButtons[name] = btn
        }

        refreshAllValues()
    }

    private func labelCaption(for name: String) -> String {
        switch name {
        case "Humans": return "Human players"
        case "Wacky": return "Wacky mode"
        case "Sound": return "Sound effects"
        case "SfxVol": return "Effects volume"
        case "Music": return "Background music"
        case "MusicVol": return "Music volume"
        case "Difficulty": return "AI difficulty"
        default: return name
        }
    }

    private func refreshAllValues() {
        updateValueButton("Humans", text: "\(Pref.shared.humanCount)")
        updateValueButton("Wacky", text: Pref.shared.isWacky ? "On" : "Off", active: Pref.shared.isWacky)
        updateValueButton("Sound", text: Pref.shared.soundOn ? "On" : "Off", active: Pref.shared.soundOn)
        updateValueButton("SfxVol", text: "\(Int(Pref.shared.sfxVolume * 100))%")
        updateValueButton("Music", text: Pref.shared.musicOn ? "On" : "Off", active: Pref.shared.musicOn)
        updateValueButton("MusicVol", text: "\(Int(Pref.shared.musicVolume * 100))%")

        let d = Pref.shared.difficulty
        let dLabel: String
        let dColor: UIColor
        switch d {
        case Difficulty.easy.rawValue: dLabel = "Easy"; dColor = GameTheme.buttonGreen
        case Difficulty.hard.rawValue: dLabel = "Hard"; dColor = GameTheme.buttonRed
        default: dLabel = "Med"; dColor = GameTheme.buttonYellow
        }
        updateValueButton("Difficulty", text: dLabel, active: true, color: dColor)
    }

    private func updateValueButton(_ key: String, text: String, active: Bool = true, color: UIColor? = nil) {
        guard let btn = valueButtons[key] else { return }
        btn.setButtonTitle(text)
        let c = color ?? (active ? GameTheme.buttonGreen : GameTheme.buttonRed)
        btn.setButtonFillColor(c)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        GameAudio.shared.unlock()
        GameAudio.shared.ui()

        for touch in touches {
            let node = atPoint(touch.location(in: self))
            guard let button = buttonNode(from: node), let name = button.name else { continue }

            switch name {
            case "Backbtn":
                presentScene(MainMenu(size: size))

            case "Humansbtn":
                var n = Pref.shared.humanCount + 1
                if n > 4 { n = 1 }
                Pref.shared.humanCount = n
                refreshAllValues()

            case "Wackybtn":
                Pref.shared.isWacky.toggle()
                refreshAllValues()

            case "Soundbtn":
                Pref.shared.soundOn.toggle()
                GameAudio.shared.applyVolumes()
                refreshAllValues()

            case "SfxVolbtn":
                cycleSfxVolume()
                GameAudio.shared.applyVolumes()
                refreshAllValues()

            case "Musicbtn":
                Pref.shared.musicOn.toggle()
                if Pref.shared.musicOn { GameAudio.shared.syncMusic() }
                else { GameAudio.shared.stopMusic() }
                refreshAllValues()

            case "MusicVolbtn":
                cycleMusicVolume()
                GameAudio.shared.applyVolumes()
                if Pref.shared.musicOn { GameAudio.shared.syncMusic() }
                refreshAllValues()

            case "Difficultybtn":
                switch Pref.shared.difficulty {
                case Difficulty.easy.rawValue: Pref.shared.difficulty = Difficulty.medium.rawValue
                case Difficulty.medium.rawValue: Pref.shared.difficulty = Difficulty.hard.rawValue
                default: Pref.shared.difficulty = Difficulty.easy.rawValue
                }
                refreshAllValues()

            default: break
            }
        }
    }

    private func buttonNode(from node: SKNode) -> SKSpriteNode? {
        var current: SKNode? = node
        while let c = current {
            if let sprite = c as? SKSpriteNode, c.name?.hasSuffix("btn") == true { return sprite }
            current = c.parent
        }
        return nil
    }

    private func cycleSfxVolume() {
        let steps: [Double] = [0, 0.25, 0.5, 0.7, 1.0]
        let current = Pref.shared.sfxVolume
        let idx = steps.firstIndex(where: { abs($0 - current) < 0.01 }) ?? 2
        Pref.shared.sfxVolume = steps[(idx + 1) % steps.count]
    }

    private func cycleMusicVolume() {
        let steps: [Double] = [0, 0.25, 0.5, 0.7, 1.0]
        let current = Pref.shared.musicVolume
        let idx = steps.firstIndex(where: { abs($0 - current) < 0.01 }) ?? 2
        Pref.shared.musicVolume = steps[(idx + 1) % steps.count]
    }

    private func presentScene(_ scene: SKScene) {
        scene.scaleMode = .aspectFill
        view?.showsFPS = false
        view?.showsNodeCount = false
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
