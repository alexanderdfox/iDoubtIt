//
//  SettingsMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

class SettingsMenu: SKScene  {
    
    override func didMoveToView(view: SKView) {
        let bg = SKSpriteNode(imageNamed: "bg_blue")
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.size = CGSizeMake(screenWidth, screenHeight)
        addChild(bg)
        
        let backButton = SKSpriteNode(imageNamed: "back")
        backButton.color = .whiteColor()
        backButton.colorBlendFactor = 1
        backButton.anchorPoint = CGPoint.zero
        backButton.position = CGPointMake(25, screenHeight - 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        for touch in touches {
        //            let location = touch.locationInNode(self)
        //
        //        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        for touch in touches {
        //            let location = touch.locationInNode(self)
        //
        //        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            if (node.name == "backButton") {
               let scene = MainMenu(size: CGSize(width: screenWidth, height: screenHeight))
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