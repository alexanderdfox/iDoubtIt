//
//  GameViewController.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

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
}
