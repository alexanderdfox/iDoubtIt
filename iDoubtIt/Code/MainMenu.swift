//
//  Game.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

class MainMenu: SKScene  {
   
    override init() {
        super.init(size: screenSize.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        Pref().updateVars()

        let bg = SKSpriteNode(imageNamed: background)
        bg.anchorPoint = CGPoint.zero
        bg.position = CGPoint.zero
        bg.size = CGSize(width: screenWidth, height: screenHeight)
        addChild(bg)
        
        let playButton = button(image: "button1", name: "Play", color: .black, label: "Play")
        playButton.position = CGPoint(x: screenWidth / 2 - (playButton.size.width * 1.5), y: screenHeight / 2 - playButton.size.height / 2)
        addChild(playButton)
        
        let settingsButton = button(image: "button1", name: "Settings", color: .black, label: "Settings")
        settingsButton.position = CGPoint(x: screenWidth / 4 + (settingsButton.size.width * 1.5), y: playButton.position.y)
        addChild(settingsButton)
        
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
            if (node.name == "Playbtn" || node.name == "Playlabel") {
                let scene = PlayScene(size: screenSize.size)
                view?.showsFPS = true
                view?.showsNodeCount = true
                view?.ignoresSiblingOrder = false
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
            }
            if (node.name == "Settingsbtn" || node.name == "Settingslabel") {
                let scene = SettingsMenu()
                view?.showsFPS = true
                view?.showsNodeCount = true
                view?.ignoresSiblingOrder = false
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
            }
        }
    }


}
