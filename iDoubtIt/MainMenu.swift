//
//  MainMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

class MainMenu: SKScene  {
    
    override func didMoveToView(view: SKView) {
        let bg = SKSpriteNode(imageNamed: "bg_blue")
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.size = CGSizeMake(screenWidth, screenHeight)
        addChild(bg)
        
        let playButton = SKSpriteNode(imageNamed: "button1")
        let playLabel = SKLabelNode(text: "Play")
        playButton.color = .greenColor()
        playButton.colorBlendFactor = 1
        playLabel.fontName = "MarkerFelt"
        playButton.anchorPoint = CGPoint.zero
        playButton.position = CGPointMake(screenHeight/4, screenWidth/2)
        playLabel.position = CGPointMake(playButton.size.width / 2, playButton.size.height / 4 + 5)
        playButton.name = "playButton"
        playLabel.name = "playLabel"
        addChild(playButton)
        playButton.addChild(playLabel)
        
        let settingsButton = SKSpriteNode(imageNamed: "button1")
        let settingsLabel = SKLabelNode(text: "Settings")
        settingsButton.color = .redColor()
        settingsButton.colorBlendFactor = 1
        settingsLabel.fontName = "MarkerFelt"
        settingsButton.anchorPoint = CGPoint.zero
        settingsButton.position = CGPointMake(screenHeight/4 * 3, screenWidth/2)
        settingsLabel.position = CGPointMake(playButton.size.width / 2, playButton.size.height / 4 + 5)
        settingsButton.name = "settingsButton"
        settingsLabel.name = "settingsLabel"
        addChild(settingsButton)
        settingsButton.addChild(settingsLabel)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            let node = nodeAtPoint(location)
//
//        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            let node = nodeAtPoint(location)
//
//        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            if (node.name == "playButton" || node.name == "playLabel") {
                let scene = GameScene(size: CGSize(width: screenWidth, height: screenHeight))
                let skView = view! as SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.ignoresSiblingOrder = false
                scene.scaleMode = .AspectFill
                skView.presentScene(scene)
            }
            if (node.name == "settingsButton" || node.name == "settingsLabel") {
                let scene = SettingsMenu(size: CGSize(width: screenWidth, height: screenHeight))
                let skView = view! as SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                skView.ignoresSiblingOrder = false
                scene.scaleMode = .AspectFill
                skView.presentScene(scene)
            }
        }
    }


}