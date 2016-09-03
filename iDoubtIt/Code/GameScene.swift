/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

let screenSize: CGRect = UIScreen.mainScreen().bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let deck = Deck.init(wacky: true)

enum CardLevel :CGFloat {
  case board = 20
  case moving = 40
  case enlarged = 60
}

class GameScene: SKScene {

  override func didMoveToView(view: SKView) {
    let bg = SKSpriteNode(imageNamed: "bg_blue")
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    bg.size = CGSizeMake(screenWidth, screenHeight)
    addChild(bg)
    
    let infoButton = SKSpriteNode(imageNamed: "outerCircle")
    let infoLabel = SKLabelNode(text: "i")
    infoButton.color = .whiteColor()
    infoButton.colorBlendFactor = 0.75
    infoLabel.fontColor = .blackColor()
    infoLabel.fontName = "Marker Felt"
    infoButton.anchorPoint = CGPoint.zero
    infoButton.position = CGPointMake(screenWidth - 50, screenHeight - 50)
    infoLabel.position = CGPointMake(infoButton.size.width / 2, infoButton.size.height / 4)
    infoButton.name = "infoButton"
    infoLabel.name = "infoLabel"
    addChild(infoButton)
    infoButton.addChild(infoLabel)

    deck.randShuffle()
    for card in deck.gameDeck as NSArray as! [Card] {
        card.position.x = screenWidth/2 - card.size.width/2
        card.position.y = screenHeight/2 - card.size.height/2
        card.flip()
        addChild(card as SKSpriteNode)
    }

  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInNode(self)
      if let card = nodeAtPoint(location) as? Card {
        card.zPosition = CardLevel.moving.rawValue
        if touch.tapCount == 2 {
          card.flip()
          return
        }
        if touch.tapCount == 3 {
            card.enlarge()
            return
        }
        if card.enlarged { return }
        
        let rotR = SKAction.rotateByAngle(0.15, duration: 0.2)
        let rotL = SKAction.rotateByAngle(-0.15, duration: 0.2)
        let cycle = SKAction.sequence([rotR, rotL, rotL, rotR])
        let wiggle = SKAction.repeatActionForever(cycle)
        card.runAction(wiggle, withKey: "wiggle")
        
        card.removeActionForKey("drop")
        card.runAction(SKAction.scaleTo(1.3, duration: 0.25), withKey: "pickup")
        print(card.getIcon())
        print(card.cardName)
        }
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInNode(self)
      if let card = nodeAtPoint(location) as? Card {
        if card.enlarged { return }
        card.position = location
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    for touch in touches {
      let location = touch.locationInNode(self)
      let node = nodeAtPoint(location)
      if let card = node as? Card {
        if card.enlarged { return }
        
        card.zPosition = CardLevel.board.rawValue
        
        card.removeActionForKey("wiggle")
        card.runAction(SKAction.rotateToAngle(0, duration: 0.2), withKey:"rotate")
        
        card.removeActionForKey("pickup")
        card.runAction(SKAction.scaleTo(1.0, duration: 0.25), withKey: "drop")
        
        card.removeFromParent()
        addChild(card)
      }
      if (node.name == "infoButton" || node.name == "infoLabel") {
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