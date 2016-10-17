//
//  Game.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let prefs = UserDefaults.standard

class MainMenu: SKScene  {
   
    override func didMove(to view: SKView) {
        
        Pref().updateVars()

        let bg = SKSpriteNode(imageNamed: background)
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.size = CGSize(width: screenWidth, height: screenHeight)
        addChild(bg)
        
        let playButton = SKSpriteNode(imageNamed: "button1")
        let playLabel = SKLabelNode(text: "Play")
        playButton.color = .blue
        playButton.colorBlendFactor = 1
        playLabel.fontName = "MarkerFelt"
        playButton.anchorPoint = CGPoint.zero
        playButton.position = CGPoint(x: screenWidth / 2 - (playButton.size.width * 1.5), y: screenHeight / 2 - playButton.size.height / 2)
        playLabel.position = CGPoint(x: playButton.size.width / 2, y: playButton.size.height / 4 + 5)
        playButton.name = "playButton"
        playLabel.name = "playLabel"
        addChild(playButton)
        playButton.addChild(playLabel)
        
        let settingsButton = SKSpriteNode(imageNamed: "button1")
        let settingsLabel = SKLabelNode(text: "Settings")
        settingsButton.color = .purple
        settingsButton.colorBlendFactor = 1
        settingsLabel.fontName = "MarkerFelt"
        settingsButton.anchorPoint = CGPoint.zero
        settingsButton.position = CGPoint(x: screenWidth / 4 + (settingsButton.size.width * 1.5), y: playButton.position.y)
        settingsLabel.position = CGPoint(x: playButton.size.width / 2, y: playButton.size.height / 4 + 5)
        settingsButton.name = "settingsButton"
        settingsLabel.name = "settingsLabel"
        addChild(settingsButton)
        settingsButton.addChild(settingsLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            let node = nodeAtPoint(location)
//
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            let node = nodeAtPoint(location)
//
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            if (node.name == "playButton" || node.name == "playLabel") {
                let scene = PlayScene(size: CGSize(width: screenWidth, height: screenHeight))
                let skView = view! as SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.ignoresSiblingOrder = false
                scene.scaleMode = .aspectFill
                skView.presentScene(scene)
            }
            if (node.name == "settingsButton" || node.name == "settingsLabel") {
                let scene = SettingsMenu()
                let skView = view! as SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.ignoresSiblingOrder = false
                scene.scaleMode = .aspectFill
                skView.presentScene(scene)
            }
        }
    }


}
