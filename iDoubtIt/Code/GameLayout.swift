//
//  GameLayout.swift
//  iDoubtIt
//
//  Responsive metrics for all iPhone and iPad sizes (portrait and landscape).
//

import UIKit
import CoreGraphics

enum GameLayout {

    private(set) static var current = Metrics.forSize(CGSize(width: 390, height: 844))

    static func configure(for size: CGSize) {
        current = Metrics.forSize(size)
    }

    struct Metrics {
        let sceneSize: CGSize
        let isPad: Bool
        let isLandscape: Bool
        let uiScale: CGFloat

        let margins: GameTheme.LayoutMargins

        let cardSize: CGSize
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        let cardCornerRadius: CGFloat

        let edgeSide: CGFloat
        let edgeTop: CGFloat
        let edgeBottom: CGFloat
        let handMinGap: CGFloat
        let handPreferredGap: CGFloat

        let buttonMenu: CGSize
        let buttonRegular: CGSize
        let buttonCompact: CGFloat
        let buttonCompactSize: CGSize

        let titleSize: CGFloat
        let subtitleSize: CGFloat
        let captionSize: CGFloat
        let hudTurnSize: CGFloat
        let hudHintSize: CGFloat
        let hudClaimSize: CGFloat
        let seatLabelSize: CGFloat

        let hudPanelWidth: CGFloat
        let hudPanelHeight: CGFloat
        let actionBarWidth: CGFloat
        let actionBarHeight: CGFloat
        /// Y center for Play / Doubt (always above bottom safe area, below hand).
        let actionBarCenterY: CGFloat
        /// Horizontal offset from scene center to each action button center.
        let actionButtonSpread: CGFloat
        let settingsPanelWidth: CGFloat
        let settingsRowHeight: CGFloat

        let feltWidth: CGFloat
        let feltHeight: CGFloat

        static func forSize(_ size: CGSize) -> Metrics {
            let w = max(size.width, 1)
            let h = max(size.height, 1)
            let minE = min(w, h)
            let maxE = max(w, h)
            let isPad = UIDevice.current.userInterfaceIdiom == .pad || minE >= 600
            let isLandscape = w > h

            // Scale relative to iPhone 14 width; clamp so iPad / Pro Max stay readable.
            var uiScale = minE / 390.0
            if isPad { uiScale = min(uiScale, 1.22) }
            uiScale = max(0.78, min(uiScale, 1.32))

            let margins = GameTheme.LayoutMargins.forScene(width: w, height: h, isPad: isPad)

            let sideInset = max(
                isPad ? (isLandscape ? minE * 0.10 : minE * 0.08) : w * 0.06,
                margins.horizontal + 8
            )

            let availW = w - sideInset * 2
            let cardsAcrossEstimate: CGFloat = isPad ? 8 : 6
            let gapEstimate: CGFloat = 16 * uiScale
            let maxFromHand = (availW - gapEstimate * (cardsAcrossEstimate - 1)) / cardsAcrossEstimate

            var cardW: CGFloat
            if isPad {
                cardW = min(maxFromHand, isLandscape ? minE * 0.105 : minE * 0.115)
                cardW = min(cardW, isLandscape ? 118 : 128)
                cardW = max(cardW, 64)
            } else {
                cardW = min(w * 0.185, maxFromHand)
                cardW = min(cardW, 86)
                cardW = max(cardW, 48)
            }

            let cardH = cardW * (220.0 / 160.0)
            let cardSize = CGSize(width: cardW, height: cardH)
            let cardCorner = max(10, cardW * 0.125)

            let actionBarH = max(52, 60 * uiScale)
            let actionButtonGap = max(14, 18 * uiScale)
            let actionBarCenterY = margins.bottom + actionBarH * 0.5
            // Bottom edge of player-0 hand (SpriteKit y-up); hand center = handBottom + cardH/2.
            let handBottom = margins.bottom + actionBarH + max(10, 12 * uiScale)
            let topUI = margins.top + cardH * 0.35 + 88 * uiScale

            let edgeBottom = handBottom
            let edgeTop = max(h * 0.10, topUI)

            let handMin = max(10, 14 * uiScale)
            let handPref = max(handMin + 4, min(38, 26 * uiScale))

            let menuW = min(w * 0.52, max(180, 200 * uiScale))
            let menuH = max(48, 54 * uiScale)
            let regW = min(w * 0.38, max(130, 148 * uiScale))
            let regH = max(46, 52 * uiScale)
            let compactW = min(w * 0.24, max(88, 96 * uiScale))
            let compactH = max(40, 44 * uiScale)
            let actionBarW = min(w - 24, regW * 2 + actionButtonGap + 36)
            let actionSpread = regW * 0.5 + actionButtonGap * 0.5

            return Metrics(
                sceneSize: size,
                isPad: isPad,
                isLandscape: isLandscape,
                uiScale: uiScale,
                margins: margins,
                cardSize: cardSize,
                cardWidth: cardW,
                cardHeight: cardH,
                cardCornerRadius: cardCorner,
                edgeSide: sideInset,
                edgeTop: edgeTop,
                edgeBottom: edgeBottom,
                handMinGap: handMin,
                handPreferredGap: handPref,
                buttonMenu: CGSize(width: menuW, height: menuH),
                buttonRegular: CGSize(width: regW, height: regH),
                buttonCompact: compactH,
                buttonCompactSize: CGSize(width: compactW, height: compactH),
                titleSize: min(48, max(32, 42 * uiScale)),
                subtitleSize: max(14, 16 * uiScale),
                captionSize: max(14, 16 * uiScale),
                hudTurnSize: max(16, 19 * uiScale),
                hudHintSize: max(11, 13 * uiScale),
                hudClaimSize: max(14, 16 * uiScale),
                seatLabelSize: max(12, 14 * uiScale),
                hudPanelWidth: min(w - 24, max(260, 300 * uiScale)),
                hudPanelHeight: max(68, 78 * uiScale),
                actionBarWidth: actionBarW,
                actionBarHeight: actionBarH,
                actionBarCenterY: actionBarCenterY,
                actionButtonSpread: actionSpread,
                settingsPanelWidth: min(w - 32, isPad ? 480 : 400),
                settingsRowHeight: max(46, 52 * uiScale),
                feltWidth: min(w * 0.9, isPad ? 560 : 400),
                feltHeight: min(h * (isPad ? 0.44 : 0.40), isPad ? 300 : 240)
            )
        }
    }
}

/// Scenes that rebuild UI when the view size changes (rotation, split screen).
protocol LayoutResizing: AnyObject {
    func layoutForCurrentSize()
}
