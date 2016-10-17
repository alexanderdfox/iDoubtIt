//
//  SettingsMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

class SettingsMenu :SKScene  {
    
    fileprivate var wackyModeBtn :SKSpriteNode
    fileprivate var soundBtn :SKSpriteNode

    override init() {
        wackyModeBtn = SKSpriteNode(imageNamed: "button0")
        soundBtn = SKSpriteNode(imageNamed: "button0")
        super.init(size: screenSize.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: background)
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.size = CGSize(width: screenWidth, height: screenHeight)
        addChild(bg)
        
        let backButton = SKSpriteNode(imageNamed: "back")
        backButton.color = .white
        backButton.colorBlendFactor = 1
        backButton.anchorPoint = CGPoint.zero
        backButton.position = CGPoint(x: 25, y: screenHeight - 50)
        backButton.name = "backButton"
        addChild(backButton)
        
        let wackyLabel = SKLabelNode(text: "Wacky")
        wackyModeBtn.position = CGPoint(x: screenWidth / 2 - (wackyModeBtn.size.width * 1.5), y: screenHeight / 2 - wackyModeBtn.size.height / 2)
        wackyModeBtn.anchorPoint = CGPoint.zero
        wackyLabel.position = CGPoint(x: wackyModeBtn.size.width / 2, y: wackyModeBtn.size.height / 4 + 5)
        wackyLabel.fontName = "MarkerFelt"
        if isWacky {
            wackyModeBtn.color = .green
        }
        else {
            wackyModeBtn.color = .red
        }
        wackyModeBtn.colorBlendFactor = 1
        wackyModeBtn.name = "wackyMode"
        wackyLabel.name = "wackyMode"
        addChild(wackyModeBtn)
        wackyModeBtn.addChild(wackyLabel)
        
        let soundLabel = SKLabelNode(text: "Sound")
        soundBtn.position = CGPoint(x: screenWidth / 4 + (soundBtn.size.width * 1.5), y: screenHeight / 2 - soundBtn.size.height / 2)
        soundBtn.anchorPoint = CGPoint.zero
        soundLabel.position = CGPoint(x: soundBtn.size.width / 2, y: soundBtn.size.height / 4 + 5)
        soundLabel.fontName = "MarkerFelt"
        if soundOn {
            soundBtn.color = .green
        }
        else {
            soundBtn.color = .red
        }
        soundBtn.colorBlendFactor = 1
        soundBtn.name = "soundButton"
        soundLabel.name = "soundButton"
        addChild(soundBtn)
        soundBtn.addChild(soundLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        for touch in touches {
        //            let location = touch.locationInNode(self)
        //
        //        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        for touch in touches {
        //            let location = touch.locationInNode(self)
        //
        //        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let prefs = UserDefaults.standard
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if (node.name == "backButton") {
               let scene = MainMenu(size: CGSize(width: screenWidth, height: screenHeight))
               let skView = view! as SKView
               skView.showsFPS = true
               skView.showsNodeCount = true
               skView.ignoresSiblingOrder = false
               scene.scaleMode = .aspectFill
               skView.presentScene(scene)
            }
            if (node.name == "wackyMode") {
                if isWacky {
                    prefs.set(false, forKey: "Wacky")
                    wackyModeBtn.color = .red
                }
                else {
                    prefs.set(true, forKey: "Wacky")
                    wackyModeBtn.color = .green
                }
                isWacky = prefs.bool(forKey: "Wacky")
            }
            if (node.name == "soundButton") {
                if soundOn {
                    prefs.set(false, forKey: "Sound")
                    soundBtn.color = .red
                }
                else {
                    prefs.set(true, forKey: "Sound")
                    soundBtn.color = .green
                }
                soundOn = prefs.bool(forKey: "Sound")
            }
        }
    }
}
