//
//  GameTheme.swift
//  iDoubtIt
//
//  Shared colors and scene decoration
//

import UIKit
import SpriteKit

enum GameTheme {

    static let backgroundTop = UIColor(red: 0.20, green: 0.48, blue: 0.86, alpha: 1)
    static let backgroundBottom = UIColor(red: 0.05, green: 0.20, blue: 0.46, alpha: 1)
    static let felt = UIColor(red: 0.10, green: 0.44, blue: 0.32, alpha: 0.92)
    static let feltBorder = UIColor(red: 0.05, green: 0.30, blue: 0.22, alpha: 1)

    static let cardRedFill = UIColor(red: 1.0, green: 0.91, blue: 0.91, alpha: 1)
    static let cardBlackFill = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
    static let cardJokerFill = UIColor(red: 1.0, green: 0.96, blue: 0.58, alpha: 1)
    static let cardBackFill = UIColor(red: 0.20, green: 0.30, blue: 0.52, alpha: 1)
    static let cardBackAccent = UIColor(red: 0.28, green: 0.40, blue: 0.65, alpha: 1)

    static let discardFill = UIColor(red: 1.0, green: 0.92, blue: 0.35, alpha: 0.92)
    static let gold = UIColor(red: 1.0, green: 0.84, blue: 0.35, alpha: 1)

    static let buttonGray = UIColor(red: 0.38, green: 0.40, blue: 0.44, alpha: 1)
    static let buttonGreen = UIColor(red: 0.22, green: 0.62, blue: 0.34, alpha: 1)
    static let buttonRed = UIColor(red: 0.78, green: 0.22, blue: 0.24, alpha: 1)

    static let titleFont = "AvenirNext-Bold"
    static let bodyFont = "AvenirNext-Medium"

    // MARK: - Scene decoration

    static func addBackground(to scene: SKScene, size: CGSize? = nil) {
        let s = size ?? scene.size

        let top = SKSpriteNode(color: backgroundTop, size: CGSize(width: s.width, height: s.height * 0.55))
        top.anchorPoint = CGPoint(x: 0, y: 0)
        top.position = CGPoint(x: 0, y: s.height * 0.45)
        top.zPosition = -20
        scene.addChild(top)

        let bottom = SKSpriteNode(color: backgroundBottom, size: CGSize(width: s.width, height: s.height * 0.55))
        bottom.anchorPoint = CGPoint(x: 0, y: 1)
        bottom.position = CGPoint(x: 0, y: s.height * 0.45)
        bottom.zPosition = -20
        scene.addChild(bottom)
    }

    static func addTableFelt(to scene: SKScene, size: CGSize) {
        let feltSize = CGSize(width: size.width * 0.9, height: size.height * 0.5)
        let table = SKShapeNode(ellipseOf: feltSize)
        table.fillColor = felt
        table.strokeColor = feltBorder
        table.lineWidth = 3.5
        table.position = CGPoint(x: size.width / 2, y: size.height / 2)
        table.zPosition = -9
        table.glowWidth = 1
        scene.addChild(table)

        let inner = SKShapeNode(ellipseOf: CGSize(width: feltSize.width * 0.92, height: feltSize.height * 0.88))
        inner.fillColor = .clear
        inner.strokeColor = UIColor.white.withAlphaComponent(0.12)
        inner.lineWidth = 1.5
        inner.position = table.position
        inner.zPosition = -8
        scene.addChild(inner)
    }

    static func makeHUDPanel(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let panel = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 14)
        panel.fillColor = UIColor.black.withAlphaComponent(0.32)
        panel.strokeColor = UIColor.white.withAlphaComponent(0.22)
        panel.lineWidth = 1
        return panel
    }

    static func makeTitleLabel(_ text: String, fontSize: CGFloat = 42) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = titleFont
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    static func makeSubtitleLabel(_ text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bodyFont
        label.fontSize = 18
        label.fontColor = UIColor.white.withAlphaComponent(0.85)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}
