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

import UIKit
import SpriteKit

enum Background :String {
    case bg_blue
}

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.becomeFirstResponder()
    
    let scene = MainMenu(size: CGSize(width: screenWidth, height: screenHeight))
    let skView = self.view as! SKView
    
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = false
    scene.scaleMode = .aspectFill
    skView.presentScene(scene)
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }

  override var canBecomeFirstResponder : Bool {
      return true
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
      if motion == .motionShake {
          for card in deck.gameDeck as NSArray as! [Card] {
              let myX = (CGFloat(arc4random()).truncatingRemainder(dividingBy: (screenWidth - 50))) + 25
              let myY = (CGFloat(arc4random()).truncatingRemainder(dividingBy: (screenHeight - 50))) + 25
              let myPoint = CGPoint.init(x: myX, y: myY)
              let cardMove = SKAction.move(to: myPoint, duration: 1.0)
              card.run(cardMove)
          }
      }
  }
}
