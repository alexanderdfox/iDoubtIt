//
//  Buttons.swift
//  iDoubtIt
//

import Foundation
import SpriteKit
import UIKit

func button(image: String = "", name: String, color: UIColor, label text: String) -> SKSpriteNode {

    let buttonSize = CGSize(width: 180, height: 60)
    let button: SKSpriteNode

    if image.isEmpty {
        button = SKSpriteNode(color: .clear, size: buttonSize)
    } else {
        button = SKSpriteNode(imageNamed: image)
        button.color = color
        button.colorBlendFactor = 1
        button.size = buttonSize
    }

    button.name = "\(name)btn"
    button.isUserInteractionEnabled = false
    button.zPosition = 0

    let shadow = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
    shadow.fillColor = UIColor.black.withAlphaComponent(0.35)
    shadow.strokeColor = .clear
    shadow.position = CGPoint(x: 2, y: -3)
    shadow.zPosition = -2
    button.addChild(shadow)

    let cornerShape = SKShapeNode(rectOf: buttonSize, cornerRadius: 12)
    cornerShape.fillColor = color
    cornerShape.strokeColor = .black
    cornerShape.lineWidth = 2
    cornerShape.zPosition = -1
    button.addChild(cornerShape)

    let shine = SKShapeNode(
        rectOf: CGSize(width: buttonSize.width - 12, height: buttonSize.height * 0.42),
        cornerRadius: 8
    )
    shine.fillColor = UIColor.white.withAlphaComponent(0.22)
    shine.strokeColor = .clear
    shine.position = CGPoint(x: 0, y: buttonSize.height * 0.14)
    shine.zPosition = 0
    button.addChild(shine)

    let shadowNode = SKLabelNode(text: text)
    shadowNode.fontName = GameTheme.titleFont
    shadowNode.fontSize = 22
    shadowNode.fontColor = UIColor.black.withAlphaComponent(0.55)
    shadowNode.position = CGPoint(x: 2, y: -8)
    shadowNode.verticalAlignmentMode = .center
    shadowNode.horizontalAlignmentMode = .center
    shadowNode.zPosition = 1
    button.addChild(shadowNode)

    let labelNode = SKLabelNode(text: text)
    labelNode.fontName = shadowNode.fontName
    labelNode.fontSize = shadowNode.fontSize
    labelNode.fontColor = .white
    labelNode.verticalAlignmentMode = .center
    labelNode.horizontalAlignmentMode = .center
    labelNode.zPosition = 2
    button.addChild(labelNode)

    return button
}
