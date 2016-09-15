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

let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let deck = Deck.init(wacky: true)
var soundOn :Bool = true
var isWacky :Bool = false
var difficulty :Int = 0
var background :String = Background.bg_blue.rawValue
var cardCover :String = cardBack.cardBack_blue4.rawValue

enum CardLevel :CGFloat {
  case board = 20
  case moving = 40
  case enlarged = 60
}

class GameScene: SKScene {
    
  override func didMove(to view: SKView) {
    let prefs = UserDefaults.standard
    
    if (prefs.object(forKey: "Sound") == nil) {
        prefs.set(true, forKey: "Sound")
    } else {
        soundOn = prefs.bool(forKey: "Sound")
    }
    if (prefs.object(forKey: "Wacky") == nil) {
        prefs.set(false, forKey: "Wacky")
    } else {
        isWacky = prefs.bool(forKey: "Wacky")
    }
    if (prefs.object(forKey: "Difficulty") == nil) {
        prefs.set(Difficulty.easy.rawValue, forKey: "Difficulty")
    } else {
        difficulty = prefs.integer(forKey: "Difficulty")
    }
    if (prefs.object(forKey: "Background") == nil) {
        prefs.setValue(Background.bg_blue.rawValue, forKey: "Background")
    } else {
        background = prefs.string(forKey: "Background")!
    }
    if (prefs.object(forKey: "CardCover") == nil) {
        prefs.setValue(cardBack.cardBack_blue4.rawValue, forKey: "CardCover")
    } else {
        cardCover = prefs.string(forKey: "CardCover")!
    }
    
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

    deck.randShuffle()
    for card in deck.gameDeck as NSArray as! [Card] {
        card.position.x = screenWidth/2 - card.size.width/2
        card.position.y = screenHeight/2 - card.size.height/2
        card.flip()
        addChild(card as SKSpriteNode)
    }

  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card = atPoint(location) as? Card {
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
        if card.enlarged { return }
        card.position = location
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches {
      let location = touch.location(in: self)
      let node = atPoint(location)
      if let card = node as? Card {
        if card.enlarged { return }
        
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
