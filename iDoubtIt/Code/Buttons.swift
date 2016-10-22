//
//  Buttons.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 10/17/16.
//
//

import Foundation
import SpriteKit
    
func button(image: String,name: String, color: UIColor, label: String) -> SKSpriteNode {
    let button = SKSpriteNode(imageNamed: image)
    let label = SKLabelNode(text: label)
    button.color = color
    button.colorBlendFactor = 1
    button.anchorPoint = CGPoint.zero
    label.fontName = "MarkerFelt"
    label.position = CGPoint(x: button.size.width / 2, y: button.size.height / 4)
    button.name = "\(name)btn"
    label.name = "\(name)label"
    button.isUserInteractionEnabled = false
    label.isUserInteractionEnabled = false
    button.addChild(label)
    return button
}
