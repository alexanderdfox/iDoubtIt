//
//  GameScene.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

enum CardLevel :CGFloat {
  case board = 20
  case moving = 40
  case enlarged = 60
}

class PlayScene: SKScene {
    
    override init() {
        super.init(size: screenSize.size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  override func didMove(to view: SKView) {
    
    let deck = Deck(wacky: isWacky)
    
    let bg = SKSpriteNode(imageNamed: background)
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    bg.size = CGSize(width: screenWidth, height: screenHeight)
    addChild(bg)
    
    let infoButton = button(image: "outerCircle", name:"Info", color: .white, label: "i")
    infoButton.colorBlendFactor = 0.75
    infoButton.position = CGPoint(x: screenWidth - 50, y: screenHeight - 50)
    addChild(infoButton)

    deck.naturalShuffle()
    deck.randShuffle()
    deck.naturalShuffle()
    for card in deck.gameDeck {
        card.position = CGPoint(x: screenWidth/2, y: screenHeight/2)
        addChild(card)
    }

  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card = atPoint(location) as? Card {
        card.zPosition = CardLevel.moving.rawValue
        if touch.tapCount == 2 {
          card.flipOver()
          return
        }        
        let rotR = SKAction.rotate(byAngle: 0.15, duration: 0.2)
        let rotL = SKAction.rotate(byAngle: -0.15, duration: 0.2)
        let cycle = SKAction.sequence([rotR, rotL, rotL, rotR])
        let wiggle = SKAction.repeatForever(cycle)
        card.run(wiggle, withKey: "wiggle")
        
        card.removeAction(forKey: "drop")
        card.run(SKAction.scale(to: 1.3, duration: 0.25), withKey: "pickup")
        print(card.getIcon())
        print(card.cardName)
        }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card = atPoint(location) as? Card {
        card.position = location
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      let node = atPoint(location)
      if let card = node as? Card {
        card.zPosition = CardLevel.board.rawValue
        
        card.removeAction(forKey: "wiggle")
        card.run(SKAction.rotate(toAngle: 0, duration: 0.2), withKey:"rotate")
        
        card.removeAction(forKey: "pickup")
        card.run(SKAction.scale(to: 1.0, duration: 0.25), withKey: "drop")
        
        card.removeFromParent()
        addChild(card)
      }
        if (node.name == "Infobtn" || node.name == "Infolabel") {
            let scene = MainMenu()
            view?.showsFPS = true
            view?.showsNodeCount = true
            view?.ignoresSiblingOrder = false
            scene.scaleMode = .aspectFill
            view?.presentScene(scene)
        }
    }
  }
}