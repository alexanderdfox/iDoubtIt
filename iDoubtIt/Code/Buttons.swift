//
//  Buttons.swift
//  iDoubtIt
//

import Foundation
import SpriteKit
import UIKit

enum ButtonStyle {
    case menu
    case regular
    case compact

    var size: CGSize {
        let m = GameLayout.current
        switch self {
        case .menu: return m.buttonMenu
        case .regular: return m.buttonRegular
        case .compact: return m.buttonCompactSize
        }
    }

    var fontSize: CGFloat {
        let s = GameLayout.current.uiScale
        switch self {
        case .menu: return max(18, 22 * s)
        case .regular: return max(16, 20 * s)
        case .compact: return max(14, 17 * s)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .menu: return 14
        case .regular: return 12
        case .compact: return 10
        }
    }
}

func button(
    image: String = "",
    name: String,
    color: UIColor,
    label text: String,
    style: ButtonStyle = .regular
) -> SKSpriteNode {
    let buttonSize = style.size
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

    let shadow = SKShapeNode(rectOf: buttonSize, cornerRadius: style.cornerRadius)
    shadow.name = "btnShadow"
    shadow.fillColor = UIColor.black.withAlphaComponent(0.32)
    shadow.strokeColor = .clear
    shadow.position = CGPoint(x: 2, y: -4)
    shadow.zPosition = -2
    button.addChild(shadow)

    let fill = SKShapeNode(rectOf: buttonSize, cornerRadius: style.cornerRadius)
    fill.name = "btnFill"
    fill.fillColor = color
    fill.strokeColor = UIColor.black.withAlphaComponent(0.85)
    fill.lineWidth = 2
    fill.zPosition = -1
    button.addChild(fill)

    let shineH = buttonSize.height * 0.38
    let shine = SKShapeNode(
        rectOf: CGSize(width: buttonSize.width - 10, height: shineH),
        cornerRadius: style.cornerRadius - 4
    )
    shine.name = "btnShine"
    shine.fillColor = UIColor.white.withAlphaComponent(0.2)
    shine.strokeColor = .clear
    shine.position = CGPoint(x: 0, y: buttonSize.height * 0.12)
    shine.zPosition = 0
    button.addChild(shine)

    let labelFontSize = fittedFontSize(for: text, style: style)
    let shadowLabel = SKLabelNode(text: text)
    shadowLabel.name = "btnShadowLabel"
    shadowLabel.fontName = GameTheme.titleFont
    shadowLabel.fontSize = labelFontSize
    shadowLabel.fontColor = UIColor.black.withAlphaComponent(0.45)
    shadowLabel.verticalAlignmentMode = .center
    shadowLabel.horizontalAlignmentMode = .center
    shadowLabel.position = CGPoint(x: 1, y: -2)
    shadowLabel.zPosition = 1
    button.addChild(shadowLabel)

    let labelNode = SKLabelNode(text: text)
    labelNode.name = "btnLabel"
    labelNode.fontName = GameTheme.titleFont
    labelNode.fontSize = labelFontSize
    labelNode.fontColor = .white
    labelNode.verticalAlignmentMode = .center
    labelNode.horizontalAlignmentMode = .center
    labelNode.position = .zero
    labelNode.zPosition = 2
    button.addChild(labelNode)

    return button
}

private func fittedFontSize(for text: String, style: ButtonStyle) -> CGFloat {
    let maxW = style.size.width - 16
    var size = style.fontSize
    while size > 12 {
        let w = (text as NSString).size(withAttributes: [
            .font: UIFont(name: GameTheme.titleFont, size: size) ?? UIFont.systemFont(ofSize: size)
        ]).width
        if w <= maxW { break }
        size -= 1
    }
    return size
}

/// Resize an existing themed button after `GameLayout` changes (rotation, split view).
func applyButtonStyle(_ style: ButtonStyle, to button: SKSpriteNode) {
    let buttonSize = style.size
    let corner = style.cornerRadius
    button.size = buttonSize

    let rect = CGRect(
        x: -buttonSize.width / 2,
        y: -buttonSize.height / 2,
        width: buttonSize.width,
        height: buttonSize.height
    )

    if let shadow = button.childNode(withName: "btnShadow") as? SKShapeNode {
        shadow.path = CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
        shadow.position = CGPoint(x: 2, y: -4)
    }
    if let fill = button.childNode(withName: "btnFill") as? SKShapeNode {
        fill.path = CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    }
    if let shine = button.childNode(withName: "btnShine") as? SKShapeNode {
        let shineH = buttonSize.height * 0.38
        let shineRect = CGRect(
            x: -buttonSize.width / 2 + 5,
            y: -shineH / 2 + buttonSize.height * 0.12,
            width: buttonSize.width - 10,
            height: shineH
        )
        shine.path = CGPath(roundedRect: shineRect, cornerWidth: corner - 4, cornerHeight: corner - 4, transform: nil)
    }

    if let label = button.childNode(withName: "btnLabel") as? SKLabelNode,
       let text = label.text {
        let fontSize = fittedFontSize(for: text, style: style)
        label.fontSize = fontSize
        (button.childNode(withName: "btnShadowLabel") as? SKLabelNode)?.fontSize = fontSize
    }
}

extension SKSpriteNode {

    func setButtonTitle(_ text: String) {
        let styleGuess: ButtonStyle
        switch size.height {
        case ...46: styleGuess = .compact
        case 47...53: styleGuess = .regular
        default: styleGuess = .menu
        }
        let fontSize = fittedFontSize(for: text, style: styleGuess)
        (childNode(withName: "btnLabel") as? SKLabelNode)?.text = text
        (childNode(withName: "btnLabel") as? SKLabelNode)?.fontSize = fontSize
        (childNode(withName: "btnShadowLabel") as? SKLabelNode)?.text = text
        (childNode(withName: "btnShadowLabel") as? SKLabelNode)?.fontSize = fontSize
    }

    func setButtonFillColor(_ color: UIColor) {
        self.color = color
        (childNode(withName: "btnFill") as? SKShapeNode)?.fillColor = color
    }
}
