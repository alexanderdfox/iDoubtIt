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

    static let discardFill = UIColor(red: 1.0, green: 0.92, blue: 0.35, alpha: 1)
    static let gold = UIColor(red: 1.0, green: 0.84, blue: 0.35, alpha: 1)

    static let buttonGray = UIColor(red: 0.38, green: 0.40, blue: 0.44, alpha: 1)
    static let buttonGreen = UIColor(red: 0.22, green: 0.62, blue: 0.34, alpha: 1)
    static let buttonRed = UIColor(red: 0.78, green: 0.22, blue: 0.24, alpha: 1)
    static let buttonYellow = UIColor(red: 0.95, green: 0.72, blue: 0.12, alpha: 1)

    static let titleFont = "AvenirNext-Bold"
    static let bodyFont = "AvenirNext-Medium"
    static let emojiFont = "Apple Color Emoji"

    // MARK: - Layout

    struct LayoutMargins {
        let top: CGFloat
        let bottom: CGFloat
        let horizontal: CGFloat
    }

    static func layoutMargins(for size: CGSize) -> LayoutMargins {
        let w = size.width
        let h = size.height
        let minE = min(w, h)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad || minE >= 600
        let isPhone = !isPad && UIDevice.current.userInterfaceIdiom == .phone
        return LayoutMargins.forScene(
            width: w, height: h, isPad: isPad, isPhone: isPhone, isLandscape: w > h
        )
    }
}

extension GameTheme.LayoutMargins {
    static func forScene(
        width: CGFloat,
        height: CGFloat,
        isPad: Bool,
        isPhone: Bool = false,
        isLandscape: Bool = false
    ) -> GameTheme.LayoutMargins {
        let minE = min(width, height)
        let hasHomeIndicator = minE >= 812 || max(width, height) >= 812

        let isMacCatalyst = ProcessInfo.processInfo.isMacCatalystApp
        if isMacCatalyst {
            return GameTheme.LayoutMargins(top: 24, bottom: 20, horizontal: 32)
        }
        if isPad {
            return GameTheme.LayoutMargins(top: 40, bottom: 28, horizontal: 28)
        }
        if isPhone && isLandscape {
            // Landscape: safe areas on the sides; keep vertical margins modest.
            return GameTheme.LayoutMargins(top: 14, bottom: 10, horizontal: 22)
        }
        if isPhone {
            return GameTheme.LayoutMargins(
                top: hasHomeIndicator ? 48 : 36,
                bottom: hasHomeIndicator ? 28 : 18,
                horizontal: 18
            )
        }
        let top: CGFloat = hasHomeIndicator ? 50 : 26
        let bottom: CGFloat = hasHomeIndicator ? 30 : 14
        return GameTheme.LayoutMargins(top: top, bottom: bottom, horizontal: 18)
    }
}

extension GameTheme {

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
        let m = GameLayout.current
        let feltSize = CGSize(width: m.feltWidth, height: m.feltHeight)
        let table = SKShapeNode(ellipseOf: feltSize)
        table.fillColor = felt
        table.strokeColor = feltBorder
        table.lineWidth = 3.5
        table.position = CGPoint(x: size.width / 2, y: size.height / 2)
        table.zPosition = -9
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
        panel.fillColor = UIColor.black.withAlphaComponent(0.38)
        panel.strokeColor = UIColor.white.withAlphaComponent(0.25)
        panel.lineWidth = 1.5
        return panel
    }

    static func makeActionBar(width: CGFloat, height: CGFloat = 64) -> SKShapeNode {
        let bar = makeHUDPanel(width: width, height: height)
        bar.name = "actionBar"
        return bar
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

    static func makeSubtitleLabel(_ text: String, fontSize: CGFloat = 17) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bodyFont
        label.fontSize = fontSize
        label.fontColor = UIColor.white.withAlphaComponent(0.88)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }

    static func makeCaptionLabel(_ text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bodyFont
        label.fontSize = 16
        label.fontColor = UIColor.white.withAlphaComponent(0.92)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .left
        return label
    }

    static func rankShort(_ value: Value) -> String {
        switch value {
        case .Ace: return "A"
        case .Two: return "2"
        case .Three: return "3"
        case .Four: return "4"
        case .Five: return "5"
        case .Six: return "6"
        case .Seven: return "7"
        case .Eight: return "8"
        case .Nine: return "9"
        case .Ten: return "10"
        case .Jack: return "J"
        case .Queen: return "Q"
        case .King: return "K"
        case .Joker: return "JK"
        }
    }

    static func suitSymbol(_ suit: Suit) -> String {
        switch suit {
        case .Hearts: return "♥"
        case .Diamonds: return "♦"
        case .Spades: return "♠"
        case .Clubs: return "♣"
        case .NoSuit: return ""
        }
    }
}
