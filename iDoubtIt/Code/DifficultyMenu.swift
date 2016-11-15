//
//  SettingsMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

class DifficultyMenu :SKScene  {
    
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
        
        let easybtn = button(image: "button1", name: "Easy", color: .black, label: "Easy")
        easybtn.position = CGPoint(x: screenWidth / 2 - (easybtn.size.width), y: screenHeight / 2 - easybtn.size.height / 2)
        easybtn.anchorPoint = CGPoint.zero
        if difficulty == Difficulty.easy.rawValue {
            easybtn.color = .green
        }
        else {
            easybtn.color = .red
        }
        addChild(easybtn)

        let mediumbtn = button(image: "button1", name: "Medium", color: .black, label: "Medium")
        mediumbtn.position = CGPoint(x: screenWidth / 2 - (mediumbtn.size.width * 1.5), y: screenHeight / 2 - mediumbtn.size.height / 2)
        mediumbtn.anchorPoint = CGPoint.zero
        if difficulty == Difficulty.medium.rawValue {
            mediumbtn.color = .green
        }
        else {
            mediumbtn.color = .red
        }
        addChild(mediumbtn)
        
        let hardbtn = button(image: "button1", name: "Hard", color: .black, label: "Hard")
        hardbtn.position = CGPoint(x: screenWidth / 2 - (hardbtn.size.width * 3), y: screenHeight / 2 - hardbtn.size.height / 2)
        hardbtn.anchorPoint = CGPoint.zero
        if difficulty == Difficulty.hard.rawValue {
            hardbtn.color = .green
        }
        else {
            hardbtn.color = .red
        }
        addChild(hardbtn)
        
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
            if (node.name == "Easybtn" || node.name == "Easylabel") {
                var btn = SKSpriteNode()
                if node.name == "Easybtn" {
                    btn = node as! SKSpriteNode
                }
                if node.name == "Easylabel" {
                    btn = node.parent as! SKSpriteNode
                }
                prefs.set(Difficulty.easy.rawValue, forKey: "Difficulty")
                btn.color = .green
                difficulty = prefs.integer(forKey: "Difficulty")
            }
            if (node.name == "Mediumbtn" || node.name == "Mediumlabel") {
                var btn = SKSpriteNode()
                if node.name == "Mediumbtn" {
                    btn = node as! SKSpriteNode
                }
                if node.name == "Mediumlabel" {
                    btn = node.parent as! SKSpriteNode
                }
                prefs.set(Difficulty.medium.rawValue, forKey: "Difficulty")
                btn.color = .green
                difficulty = prefs.integer(forKey: "Difficulty")
            }
            if (node.name == "Hardbtn" || node.name == "Hardlabel") {
                var btn = SKSpriteNode()
                if node.name == "Hardbtn" {
                    btn = node as! SKSpriteNode
                }
                if node.name == "Hardlabel" {
                    btn = node.parent as! SKSpriteNode
                }
                prefs.set(Difficulty.hard.rawValue, forKey: "Difficulty")
                btn.color = .green
                difficulty = prefs.integer(forKey: "Difficulty")
            }
        }
    }
}
