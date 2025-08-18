//
//  Buttons.swift
//  iDoubtIt
//
//  Updated 2025 — Polished button factory
//

import Foundation
import SpriteKit
import UIKit

/// Creates a customizable SKSpriteNode button with rounded corners, shadow, and label overlay.
///
/// - Parameters:
///   - image: Optional background image name for the button (use "" for plain colored button).
///   - name: The base name of the button (used to name both the button and label).
///   - color: The color tint or fill color of the button.
///   - label: The text to display on top of the button.
///
/// - Returns: A configured SKSpriteNode representing a button.
func button(image: String = "", name: String, color: UIColor, label text: String) -> SKSpriteNode {
    
    let buttonSize = CGSize(width: 180, height: 60)
    let button: SKSpriteNode
    
    if image.isEmpty {
        // Plain colored button
        button = SKSpriteNode(color: color, size: buttonSize)
    } else {
        // Image-based button with color tint
        button = SKSpriteNode(imageNamed: image)
        button.color = color
        button.colorBlendFactor = 1
        button.size = buttonSize
    }
    
    button.name = "\(name)btn"
    button.isUserInteractionEnabled = false
    button.zPosition = 0
    
    // Rounded corners for all buttons
    let cornerShape = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
    cornerShape.fillColor = color
    cornerShape.strokeColor = .black
    cornerShape.lineWidth = 2
    cornerShape.zPosition = -1
    button.addChild(cornerShape)
    
    // Shadow label behind main label
    let shadowNode = SKLabelNode(text: text)
    shadowNode.fontName = "AvenirNext-Bold"
    shadowNode.fontSize = 22
    shadowNode.fontColor = UIColor.black.withAlphaComponent(0.6)
    shadowNode.position = CGPoint(x: 0 + 2, y: -6 - 2)
    shadowNode.verticalAlignmentMode = .center
    shadowNode.horizontalAlignmentMode = .center
    shadowNode.isUserInteractionEnabled = false
    shadowNode.zPosition = 1
    button.addChild(shadowNode)
    
    // Main label
    let labelNode = SKLabelNode(text: text)
    labelNode.fontName = shadowNode.fontName
    labelNode.fontSize = shadowNode.fontSize
    labelNode.fontColor = .white
    labelNode.position = CGPoint.zero
    labelNode.verticalAlignmentMode = .center
    labelNode.horizontalAlignmentMode = .center
    labelNode.isUserInteractionEnabled = false
    labelNode.zPosition = 2
    button.addChild(labelNode)
    
    return button
}
