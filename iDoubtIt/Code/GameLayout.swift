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
        let isPhone: Bool
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
        /// Play / Doubt use compact sizing on iPhone.
        let actionUsesCompactButtons: Bool

        let titleSize: CGFloat
        let subtitleSize: CGFloat
        let captionSize: CGFloat
        let hudTurnSize: CGFloat
        let hudHintSize: CGFloat
        let hudClaimSize: CGFloat
        let seatLabelSize: CGFloat

        let hudPanelWidth: CGFloat
        let hudPanelHeight: CGFloat
        /// Center Y of the turn/claim HUD panel (SpriteKit coordinates).
        let hudCenterY: CGFloat
        let actionBarWidth: CGFloat
        let actionBarHeight: CGFloat
        let actionBarCenterY: CGFloat
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
            let isMacCatalyst = ProcessInfo.processInfo.isMacCatalystApp
            let isPad = isMacCatalyst
                || UIDevice.current.userInterfaceIdiom == .pad
                || minE >= 600
            let isPhone = !isPad && !isMacCatalyst && UIDevice.current.userInterfaceIdiom == .phone
            let isLandscape = w > h

            var uiScale = minE / 390.0
            if isPad { uiScale = min(uiScale, 1.22) }
            if isPhone { uiScale = min(uiScale, 1.0) }
            uiScale = max(0.72, min(uiScale, 1.32))

            let margins = GameTheme.LayoutMargins.forScene(
                width: w, height: h, isPad: isPad, isPhone: isPhone, isLandscape: isLandscape
            )

            let sideInset: CGFloat
            if isPhone && isLandscape {
                sideInset = max(margins.horizontal + 10, w * 0.05, minE * 0.06)
            } else if isPad {
                sideInset = max(isLandscape ? minE * 0.10 : minE * 0.08, margins.horizontal + 8)
            } else {
                sideInset = max(w * 0.06, margins.horizontal + 8)
            }

            let availW = w - sideInset * 2
            let cardsAcrossEstimate: CGFloat = isPhone ? 7 : (isPad ? 8 : 6)
            let gapEstimate: CGFloat = (isPhone ? 12 : 16) * uiScale
            let maxFromHand = (availW - gapEstimate * (cardsAcrossEstimate - 1)) / cardsAcrossEstimate

            var cardW: CGFloat
            if isPad {
                cardW = min(maxFromHand, isLandscape ? minE * 0.105 : minE * 0.115)
                cardW = min(cardW, isLandscape ? 118 : 128)
                cardW = max(cardW, 64)
            } else if isPhone {
                if isLandscape {
                    // Height is tight in landscape — size cards from vertical budget, not screen width.
                    let actionReserve = max(44, 48 * uiScale)
                    let hudReserve = max(50, 54 * uiScale)
                    let labelReserve: CGFloat = 14
                    let minCenterGap: CGFloat = max(28, minE * 0.08)
                    let maxCardH = (h - margins.top - margins.bottom - actionReserve - hudReserve
                        - labelReserve * 2 - minCenterGap) / 2.05
                    cardW = min(maxCardH / (220.0 / 160.0), maxFromHand, minE * 0.17)
                    cardW = min(cardW, 64)
                    cardW = max(cardW, 38)
                } else {
                    cardW = min(w * 0.17, maxFromHand)
                    cardW = min(cardW, 76)
                    cardW = max(cardW, 44)
                }
            } else {
                cardW = min(w * 0.185, maxFromHand)
                cardW = min(cardW, 86)
                cardW = max(cardW, 48)
            }

            let cardH = cardW * (220.0 / 160.0)
            let cardSize = CGSize(width: cardW, height: cardH)
            let cardCorner = max(8, cardW * 0.125)

            let actionBarH: CGFloat
            let actionButtonGap: CGFloat
            let regW: CGFloat
            let regH: CGFloat
            let actionUsesCompact: Bool

            if isPhone {
                actionUsesCompact = true
                actionBarH = max(42, 46 * uiScale)
                actionButtonGap = max(10, 14 * uiScale)
                regW = min(w * 0.22, max(108, 118 * uiScale))
                regH = max(40, 44 * uiScale)
            } else {
                actionUsesCompact = false
                actionBarH = max(52, 60 * uiScale)
                actionButtonGap = max(14, 18 * uiScale)
                regW = min(w * 0.38, max(130, 148 * uiScale))
                regH = max(46, 52 * uiScale)
            }

            let compactW = min(w * (isPhone ? 0.22 : 0.24), max(84, 96 * uiScale))
            let compactH = max(36, CGFloat(isPhone ? 40 : 44))

            let actionBarCenterY = margins.bottom + actionBarH * 0.5
            let handBottom = margins.bottom + actionBarH + (isPhone ? 6 : max(10, 12 * uiScale))

            let hudPanelH: CGFloat
            let hudPanelW: CGFloat
            let hudCenterY: CGFloat

            if isPhone {
                hudPanelH = max(50, 54 * uiScale)
                hudPanelW = min(w - sideInset * 2 - 8, max(220, w * 0.52))
                hudCenterY = h - margins.top - hudPanelH * 0.5 - 2
            } else {
                hudPanelH = max(68, 78 * uiScale)
                hudPanelW = min(w - 24, max(260, 300 * uiScale))
                let topUI = margins.top + cardH * 0.35 + 88 * uiScale
                hudCenterY = h - margins.top - cardH * 0.12 - hudPanelH / 2 - 6
            }

            let edgeBottom = handBottom
            let edgeTop: CGFloat
            if isPhone {
                let labelReserve: CGFloat = 12
                edgeTop = (h - hudCenterY) + hudPanelH * 0.5 + labelReserve + cardH + 6
            } else {
                edgeTop = max(h * 0.10, margins.top + cardH * 0.35 + 88 * uiScale)
            }

            let handMin = max(8, isPhone ? 10 : 14 * uiScale)
            let handPref = max(handMin + 2, min(isPhone ? 22 : 38, (isPhone ? 20 : 26) * uiScale))

            let menuW = min(w * (isPhone ? 0.48 : 0.52), max(168, 200 * uiScale))
            let menuH = max(isPhone ? CGFloat(44) : 48, (isPhone ? 48 : 54) * uiScale)
            let actionBarW = min(w - 20, (actionUsesCompact ? compactW : regW) * 2 + actionButtonGap + 28)
            let actionSpread = (actionUsesCompact ? compactW : regW) * 0.5 + actionButtonGap * 0.5

            let feltW: CGFloat
            let feltH: CGFloat
            if isPhone && isLandscape {
                feltW = min(w * 0.42, availW * 0.55, 320)
                feltH = min(h * 0.36, minE * 0.42, 140)
            } else if isPhone {
                feltW = min(w * 0.78, 340)
                feltH = min(h * 0.28, 200)
            } else {
                feltW = min(w * 0.9, isPad ? 560 : 400)
                feltH = min(h * (isPad ? 0.44 : 0.40), isPad ? 300 : 240)
            }

            return Metrics(
                sceneSize: size,
                isPad: isPad,
                isPhone: isPhone,
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
                actionUsesCompactButtons: actionUsesCompact,
                titleSize: isPhone ? min(36, max(28, 34 * uiScale)) : min(48, max(32, 42 * uiScale)),
                subtitleSize: max(13, (isPhone ? 14 : 16) * uiScale),
                captionSize: max(13, (isPhone ? 14 : 16) * uiScale),
                hudTurnSize: max(14, (isPhone ? 16 : 19) * uiScale),
                hudHintSize: max(10, (isPhone ? 11 : 13) * uiScale),
                hudClaimSize: max(13, (isPhone ? 14 : 16) * uiScale),
                seatLabelSize: max(11, (isPhone ? 12 : 14) * uiScale),
                hudPanelWidth: hudPanelW,
                hudPanelHeight: hudPanelH,
                hudCenterY: hudCenterY,
                actionBarWidth: actionBarW,
                actionBarHeight: actionBarH,
                actionBarCenterY: actionBarCenterY,
                actionButtonSpread: actionSpread,
                settingsPanelWidth: min(w - 24, isPad ? 480 : (isPhone ? min(360, w - 40) : 400)),
                settingsRowHeight: max(isPhone ? CGFloat(40) : 46, (isPhone ? 44 : 52) * uiScale),
                feltWidth: feltW,
                feltHeight: feltH
            )
        }
    }
}

/// Scenes that rebuild UI when the view size changes (rotation, split screen).
protocol LayoutResizing: AnyObject {
    func layoutForCurrentSize()
}
