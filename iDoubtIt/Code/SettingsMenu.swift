//
//  SettingsMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

class SettingsMenu :SKScene  {
    
    override init() {
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
        
        let backButton = button(image: "back", name: "Back", color: .white, label: "")
        backButton.position = CGPoint(x: 10, y: screenHeight - 50)
        addChild(backButton)
        
        let wackyBtn = button(image: "button1", name: "Wacky", color: .black, label: "Wacky")
        wackyBtn.position = CGPoint(x: screenWidth / 2 - (wackyBtn.size.width * 1.5), y: screenHeight / 2 - wackyBtn.size.height / 2)
        wackyBtn.anchorPoint = CGPoint.zero
        if isWacky {
            wackyBtn.color = .green
        }
        else {
            wackyBtn.color = .red
        }
        addChild(wackyBtn)
        
        let soundBtn = button(image: "button1", name: "Sound", color: .black, label: "Sound")
        soundBtn.position = CGPoint(x: screenWidth / 4 + (soundBtn.size.width * 1.5), y: screenHeight / 2 - soundBtn.size.height / 2)
        soundBtn.anchorPoint = CGPoint.zero
        if soundOn {
            soundBtn.color = .green
        }
        else {
            soundBtn.color = .red
        }
        addChild(soundBtn)
        
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
            if (node.name == "Backbtn") {
                let scene = MainMenu()
                view?.showsFPS = true
                view?.showsNodeCount = true
                view?.ignoresSiblingOrder = false
                scene.scaleMode = .aspectFill
                view?.presentScene(scene)
            }
            if (node.name == "Wackybtn" || node.name == "Wackylabel") {
                var btn = SKSpriteNode()
                if node.name == "Wackybtn" {
                    btn = node as! SKSpriteNode
                }
                if node.name == "Wackylabel" {
                    btn = node.parent as! SKSpriteNode
                }
                if isWacky {
                    prefs.set(false, forKey: "Wacky")
                    btn.color = .red
                }
                else {
                    prefs.set(true, forKey: "Wacky")
                    btn.color = .green
                }
                isWacky = prefs.bool(forKey: "Wacky")
            }
            if (node.name == "Soundbtn" || node.name == "Soundlabel") {
                var btn = SKSpriteNode()
                if node.name == "Soundbtn" {
                    btn = node as! SKSpriteNode
                }
                if node.name == "Soundlabel" {
                    btn = node.parent as! SKSpriteNode
                }
                if soundOn {
                    prefs.set(false, forKey: "Sound")
                    btn.color = .red
                }
                else {
                    prefs.set(true, forKey: "Sound")
                    btn.color = .green
                }
                soundOn = prefs.bool(forKey: "Sound")
            }
        }
    }
}
