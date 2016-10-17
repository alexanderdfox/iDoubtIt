//
//  GameScene.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

enum CardLevel :CGFloat {
  case board = 20
  case moving = 40
  case enlarged = 60
}

class PlayScene: SKScene {
    
  override func didMove(to view: SKView) {
    
    let deck = Deck(wacky: isWacky)
    
    let bg = SKSpriteNode(imageNamed: background)
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    bg.size = CGSize(width: screenWidth, height: screenHeight)
    addChild(bg)
    
    let infoButton = SKSpriteNode(imageNamed: "outerCircle")
    let infoLabel = SKLabelNode(text: "i")
    infoButton.color = .white
    infoButton.colorBlendFactor = 0.75
    infoLabel.fontColor = .black
    infoLabel.fontName = "Marker Felt"
    infoButton.anchorPoint = CGPoint.zero
    infoButton.position = CGPoint(x: screenWidth - 50, y: screenHeight - 50)
    infoLabel.position = CGPoint(x: infoButton.size.width / 2, y: infoButton.size.height / 4)
    infoButton.name = "infoButton"
    infoLabel.name = "infoLabel"
    addChild(infoButton)
    infoButton.addChild(infoLabel)

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
      if (node.name == "infoButton" || node.name == "infoLabel") {
          let scene = MainMenu(size: CGSize(width: screenWidth, height: screenHeight))
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
