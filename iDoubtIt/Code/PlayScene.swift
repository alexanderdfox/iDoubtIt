import Foundation
import SpriteKit

// MARK: - Card Level Constants
enum CardLevel: CGFloat { 
    case board = 20
    case moving = 40
    case enlarged = 60
}

// MARK: - Game State Management
enum GameState {
    case waitingForHuman
    case waitingForAI
    case gameOver
}

// MARK: - Game Errors
enum GameError: Error, LocalizedError {
    case invalidPlayerIndex
    case noPlayersFound
    case noHumanPlayerFound
    case noCardsInDiscardPile
    case invalidGameState
    case cardNotFound
    case playerHandEmpty
    case gameOver
    
    var errorDescription: String? {
        switch self {
        case .invalidPlayerIndex:
            return "Invalid player index"
        case .noPlayersFound:
            return "No players found in game"
        case .noHumanPlayerFound:
            return "No human player found"
        case .noCardsInDiscardPile:
            return "No cards in discard pile"
        case .invalidGameState:
            return "Invalid game state for this action"
        case .cardNotFound:
            return "Card not found in player's hand"
        case .playerHandEmpty:
            return "Player's hand is empty"
        case .gameOver:
            return "Game is over"
        }
    }
}

// MARK: - PlayScene Class
class PlayScene: SKScene, LayoutResizing {
    
    // MARK: - Properties
    var playMode: PlayMode = .humanPlay
    var discardPile: SKSpriteNode!
    var players: [Player] = []
    var pickedCard: Card?
    var isWacky: Bool = false
    
    // MARK: - Private Properties
    private var isWatchAI: Bool { playMode == .watchAI }
    private var doubtButton: SKSpriteNode?
    private var playButton: SKSpriteNode?
    private var seatLabelNodes: [SKLabelNode] = []
    private var seatHighlightNodes: [SKShapeNode] = []
    private var toastLabel: SKLabelNode?
    private var gameOverContainer: SKNode?
    
    // MARK: - Game State Management
    private var currentPlayerIndex: Int = 0
    private var currentRankIndex: Int = 0
    private var gameState: GameState = .waitingForHuman
    private var lastPlayedCards: [Card] = []
    private var lastPlayedValue: Value?
    private var lastPlayerName: String = ""
    private var hudPanel: SKShapeNode?
    private var turnIndicator: SKLabelNode?
    private var turnHintLabel: SKLabelNode?
    private var rankIndicator: SKLabelNode?
    private var actionBar: SKShapeNode?
    private let controlsZ: CGFloat = 1200
    private var pileCountLabel: SKLabelNode?
    private var selectedCards: [Card] = []
    private var maxCardsPerPlay: Int { isWacky ? 6 : 4 }
    
    private var currentRank: Value {
        Value(rawValue: currentRankIndex + 1) ?? .Ace
    }
    
    private var L: GameLayout.Metrics { GameLayout.current }
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        GameLayout.configure(for: size)
        GameAudio.shared.unlock()
        GameAudio.shared.applyVolumes()
        if Pref.shared.musicOn { GameAudio.shared.syncMusic() }
        setupScene()
        startGame()
    }
    
    // MARK: - Setup Methods
    private func setupScene() {
        self.isUserInteractionEnabled = true
        isWacky = Pref.shared.isWacky
        setupBackground()
        setupDiscardPile()
        setupDeckAndPlayers()
        setupBackButton()
        setupDoubtButton()
        setupPlayButton()
        setupTurnIndicator()
        setupSeatLabels()
        setupSeatHighlights()
        setupToast()
        updateActionButtonsForMode()
    }
    
    private func setupBackground() {
        GameTheme.addBackground(to: self, size: size)
        GameTheme.addTableFelt(to: self, size: size)
    }
    
    private func setupBackButton() {
        let m = L.margins
        let backButton = button(name: "Back", color: GameTheme.buttonGray, label: "Back", style: .compact)
        backButton.position = CGPoint(
            x: m.horizontal + backButton.size.width / 2,
            y: size.height - m.top - backButton.size.height / 2
        )
        backButton.zPosition = 999
        addChild(backButton)
    }
    
    private func setupDiscardPile() {
        let cardSize = L.cardSize
        discardPile = SKSpriteNode(color: .clear, size: cardSize)
        discardPile.position = CGPoint(x: size.width/2, y: size.height/2)
        discardPile.zPosition = CardLevel.board.rawValue + 5
        discardPile.name = "DiscardPile"
        
        let corner = max(12, L.cardCornerRadius)
        let shadow = SKShapeNode(rectOf: cardSize, cornerRadius: corner)
        shadow.name = "discardShadow"
        shadow.fillColor = UIColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: -5)
        shadow.zPosition = 0
        discardPile.addChild(shadow)
        
        let fill = SKShapeNode(rectOf: cardSize, cornerRadius: corner)
        fill.name = "discardFill"
        fill.fillColor = GameTheme.discardFill
        fill.strokeColor = .black
        fill.lineWidth = 2
        fill.zPosition = 1
        discardPile.addChild(fill)
        
        let label = SKLabelNode(text: "Discard")
        label.fontName = GameTheme.bodyFont
        label.fontSize = 16
        label.fontColor = UIColor(white: 0.12, alpha: 0.9)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 14)
        label.zPosition = 2
        discardPile.addChild(label)
        
        pileCountLabel = SKLabelNode(text: "")
        pileCountLabel?.fontName = GameTheme.titleFont
        pileCountLabel?.fontSize = 26
        pileCountLabel?.fontColor = UIColor(white: 0.1, alpha: 0.95)
        pileCountLabel?.verticalAlignmentMode = .center
        pileCountLabel?.horizontalAlignmentMode = .center
        pileCountLabel?.position = CGPoint(x: 0, y: -16)
        pileCountLabel?.zPosition = 2
        if let pileCountLabel = pileCountLabel {
            discardPile.addChild(pileCountLabel)
        }
        
        addChild(discardPile)
    }
    
    private func updatePileCountLabel() {
        let count = cardsOnDiscardPile().count
        pileCountLabel?.text = count > 0 ? "\(count)" : ""
    }
    
    private func setupDeckAndPlayers() {
        do {
            let deck = try createAndShuffleDeck()
            try createPlayers()
            try dealCards(from: deck)
            layoutAllHands()
            updatePileCountLabel()
        } catch {
            print("Error setting up game: \(error.localizedDescription)")
            createBasicPlayers()
        }
    }
    
    private func createAndShuffleDeck() throws -> Deck {
        let deck = Deck(wacky: isWacky)
        try deck.naturalShuffle()
        try deck.randShuffle()
        try deck.naturalShuffle()
        return deck
    }
    
    private func createPlayers() throws {
        players = buildPlayerList()
        for player in players { addChild(player) }
    }
    
    private func createBasicPlayers() {
        players = buildPlayerList()
        for player in players { addChild(player) }
    }
    
    private func buildPlayerList() -> [Player] {
        let level = Difficulty(rawValue: Pref.shared.difficulty) ?? .easy
        let humanCount = isWatchAI ? 0 : Pref.shared.humanCount
        return (0..<4).map { i in
            let human = i < humanCount
            let name = human ? "Player \(i + 1)" : "AI \(i + 1)"
            return Player(human: human, playerName: name, level: level, wacky: isWacky)
        }
    }
    
    private func dealCards(from deck: Deck) throws {
        guard !deck.gameDeck.isEmpty else {
            throw GameError.noCardsInDiscardPile
        }
        
        for (index, card) in deck.gameDeck.enumerated() {
            let playerIndex = index % players.count
            players[playerIndex].addCard(card)
        }
    }
    
    private func setupTurnIndicator() {
        let m = L.margins
        let panelW = L.hudPanelWidth
        let panelH = L.hudPanelHeight
        let panelY = size.height - m.top - L.cardHeight * 0.12 - panelH / 2 - 6

        let panel = GameTheme.makeHUDPanel(width: panelW, height: panelH)
        panel.position = CGPoint(x: size.width / 2, y: panelY)
        panel.zPosition = 999
        panel.name = "hudPanel"
        addChild(panel)
        hudPanel = panel

        turnIndicator = SKLabelNode(text: "Player 1's turn")
        turnIndicator?.fontName = GameTheme.titleFont
        turnIndicator?.fontSize = L.hudTurnSize
        turnIndicator?.fontColor = .white
        turnIndicator?.verticalAlignmentMode = .center
        turnIndicator?.horizontalAlignmentMode = .center
        turnIndicator?.position = CGPoint(x: 0, y: 18)
        turnIndicator?.zPosition = 2
        if let turnIndicator = turnIndicator { panel.addChild(turnIndicator) }

        turnHintLabel = SKLabelNode(text: "")
        turnHintLabel?.fontName = GameTheme.bodyFont
        turnHintLabel?.fontSize = L.hudHintSize
        turnHintLabel?.fontColor = UIColor.white.withAlphaComponent(0.75)
        turnHintLabel?.verticalAlignmentMode = .center
        turnHintLabel?.horizontalAlignmentMode = .center
        turnHintLabel?.position = CGPoint(x: 0, y: 2)
        turnHintLabel?.zPosition = 2
        if let turnHintLabel = turnHintLabel { panel.addChild(turnHintLabel) }

        rankIndicator = SKLabelNode(text: "Claim: Ace")
        rankIndicator?.fontName = GameTheme.bodyFont
        rankIndicator?.fontSize = L.hudClaimSize
        rankIndicator?.fontColor = GameTheme.gold
        rankIndicator?.verticalAlignmentMode = .center
        rankIndicator?.horizontalAlignmentMode = .center
        rankIndicator?.position = CGPoint(x: 0, y: -20)
        rankIndicator?.zPosition = 2
        if let rankIndicator = rankIndicator { panel.addChild(rankIndicator) }
    }

    private func setupActionBar() {
        actionBar?.removeFromParent()
        let bar = GameTheme.makeActionBar(width: L.actionBarWidth, height: L.actionBarHeight)
        bar.name = "actionBar"
        bar.isUserInteractionEnabled = false
        bar.zPosition = controlsZ - 5
        addChild(bar)
        actionBar = bar
    }

    private func setupDoubtButton() {
        setupActionBar()
        doubtButton = button(name: "Doubt", color: GameTheme.buttonRed, label: "Doubt", style: .regular)
        guard let doubtButton = doubtButton else { return }
        doubtButton.zPosition = controlsZ
        addChild(doubtButton)
    }

    private func setupPlayButton() {
        if playButton == nil {
            playButton = button(name: "Play", color: GameTheme.buttonGreen, label: "Play", style: .regular)
            playButton?.zPosition = controlsZ
            addChild(playButton!)
        }
        layoutActionControls()
    }

    private func positionDoubtButton() { layoutActionControls() }
    private func positionPlayButton() { layoutActionControls() }

    private func layoutActionControls() {
        let barY = L.actionBarCenterY
        let spread = L.actionButtonSpread
        let cx = size.width / 2

        if let doubtButton = doubtButton {
            applyButtonStyle(.regular, to: doubtButton)
        }
        if let playButton = playButton {
            applyButtonStyle(.regular, to: playButton)
        }

        if let bar = actionBar {
            bar.path = CGPath(
                roundedRect: CGRect(
                    x: -L.actionBarWidth / 2,
                    y: -L.actionBarHeight / 2,
                    width: L.actionBarWidth,
                    height: L.actionBarHeight
                ),
                cornerWidth: 14,
                cornerHeight: 14,
                transform: nil
            )
            bar.position = CGPoint(x: cx, y: barY)
            bar.isHidden = isWatchAI
            bar.zPosition = controlsZ - 5
        }

        doubtButton?.position = CGPoint(x: cx - spread, y: barY)
        playButton?.position = CGPoint(x: cx + spread, y: barY)
        doubtButton?.zPosition = controlsZ
        playButton?.zPosition = controlsZ

        let hide = isWatchAI
        doubtButton?.isHidden = hide
        playButton?.isHidden = hide
    }

    private func actionButton(at location: CGPoint) -> SKSpriteNode? {
        for candidate in [playButton, doubtButton] {
            guard let btn = candidate, !btn.isHidden, btn.alpha > 0.2 else { continue }
            if btn.calculateAccumulatedFrame().contains(location) { return btn }
        }
        return nil
    }
    
    private func spacingFor(count: Int, span: CGFloat, cardExtent: CGFloat) -> CGFloat {
        guard count > 1 else { return 0 }
        let needed = L.handPreferredGap * CGFloat(count - 1) + cardExtent
        if needed <= span { return L.handPreferredGap }
        return max(L.handMinGap, (span - cardExtent) / CGFloat(count - 1))
    }
    
    // MARK: - Game Start
    private func startGame() {
        currentRankIndex = 0
        updateRankIndicator()
        updateSeatLabels()
        GameAudio.shared.deal()
        
        if isWatchAI {
            showToast("AI only — sit back and watch.")
        } else {
            let aiSeats = 4 - Pref.shared.humanCount
            showToast("\(Pref.shared.humanCount) human(s), \(aiSeats) AI — claim Ace, play 1–\(maxCardsPerPlay) cards.")
        }
        
        beginCurrentTurn()
    }
    
    private func beginCurrentTurn() {
        guard gameState != .gameOver else { return }
        let current = players[currentPlayerIndex]
        if current.isHuman && !isWatchAI {
            gameState = .waitingForHuman
            updateTurnIndicator()
            refreshAllHands()
            GameAudio.shared.turn()
            GameAudio.shared.hapticLight()
        } else {
            gameState = .waitingForAI
            updateTurnIndicator()
            refreshAllHands()
            scheduleAITurn()
        }
    }
    
    private func scheduleAITurn() {
        let delay: TimeInterval = isWatchAI ? 0.9 : 1.0
        run(SKAction.wait(forDuration: delay)) { [weak self] in
            self?.aiPlayTurn()
        }
    }
    
    // MARK: - Hand Layout
    private func refreshAllHands() {
        for (index, player) in players.enumerated() {
            let isCurrent = index == currentPlayerIndex
            let faceUp = !isWatchAI && player.isHuman && isCurrent
            let interactive = faceUp && gameState == .waitingForHuman
            layoutHand(player, at: seatPosition(for: index), isFaceUp: faceUp, isInteractive: interactive)
        }
        layoutActionControls()
        updateSeatHighlights()
    }
    
    private func layoutAllHands() {
        refreshAllHands()
    }
    
    private func layoutHand(for player: Player) {
        guard let index = players.firstIndex(where: { $0 === player }) else { return }
        let isCurrent = index == currentPlayerIndex
        let faceUp = !isWatchAI && player.isHuman && isCurrent
        let interactive = faceUp && gameState == .waitingForHuman
        layoutHand(player, at: seatPosition(for: index), isFaceUp: faceUp, isInteractive: interactive)
    }
    
    private func seatPosition(for index: Int) -> HandPosition {
        switch index {
        case 0: return .bottom
        case 1: return .left
        case 2: return .top
        case 3: return .right
        default: return .bottom
        }
    }
    
    private func setupSeatLabels() {
        let labelOffset = max(10, L.cardHeight * 0.06)
        let sideLabelX = max(L.edgeSide * 0.35, 20)
        let configs: [(CGPoint, SKLabelVerticalAlignmentMode)] = [
            (CGPoint(x: size.width / 2, y: L.edgeBottom + L.cardHeight + labelOffset), .bottom),
            (CGPoint(x: sideLabelX, y: size.height / 2), .center),
            (CGPoint(x: size.width / 2, y: size.height - L.edgeTop - L.cardHeight - labelOffset), .top),
            (CGPoint(x: size.width - sideLabelX, y: size.height / 2), .center)
        ]
        seatLabelNodes = configs.map { pos, align in
            let label = SKLabelNode(text: "")
            label.fontName = GameTheme.bodyFont
            label.fontSize = L.seatLabelSize
            label.fontColor = UIColor.white.withAlphaComponent(0.92)
            label.fontName = GameTheme.titleFont
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = align
            label.position = pos
            label.zPosition = 998
            addChild(label)
            return label
        }
    }
    
    private func setupSeatHighlights() {
        seatHighlightNodes = (0..<4).map { index in
            let ring = SKShapeNode(circleOfRadius: max(22, L.cardWidth * 0.2))
            ring.strokeColor = GameTheme.gold
            ring.lineWidth = 3
            ring.fillColor = .clear
            ring.alpha = 0
            ring.zPosition = 5
            ring.position = seatLabelNodes[index].position
            addChild(ring)
            return ring
        }
    }
    
    private func setupToast() {
        let panelW = min(size.width - 48, 360)
        let panel = GameTheme.makeHUDPanel(width: panelW, height: 48)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.44)
        panel.zPosition = 1500
        panel.alpha = 0
        panel.name = "ToastPanel"
        addChild(panel)

        toastLabel = SKLabelNode(text: "")
        toastLabel?.fontName = GameTheme.bodyFont
        toastLabel?.fontSize = 15
        toastLabel?.fontColor = .white
        toastLabel?.verticalAlignmentMode = .center
        toastLabel?.horizontalAlignmentMode = .center
        toastLabel?.position = .zero
        toastLabel?.zPosition = 1
        panel.addChild(toastLabel!)
    }

    private func showToast(_ message: String, duration: TimeInterval = 2.8) {
        guard let toastLabel = toastLabel,
              let panel = childNode(withName: "ToastPanel") else { return }
        toastLabel.text = message
        panel.removeAllActions()
        panel.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.18)
        let wait = SKAction.wait(forDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        panel.run(SKAction.sequence([fadeIn, wait, fadeOut]))
    }
    
    private func updateSeatLabels() {
        for (i, player) in players.enumerated() where i < seatLabelNodes.count {
            seatLabelNodes[i].text = player.name ?? "Player"
        }
    }
    
    private func updateSeatHighlights() {
        for (i, ring) in seatHighlightNodes.enumerated() {
            ring.alpha = (i == currentPlayerIndex && gameState != .gameOver) ? 0.85 : 0
        }
    }
    
    private func updateActionButtonsForMode() {
        layoutActionControls()
    }
    
    private enum HandPosition {
        case top, bottom, left, right
    }
    
    private func layoutHand(_ player: Player, at position: HandPosition, isFaceUp: Bool, isInteractive: Bool) {
        let hand = player.playerHand
        let total = hand.count
        guard total > 0 else { return }
        
        let availW = size.width - L.edgeSide * 2
        let availH = size.height - L.edgeTop - L.edgeBottom - L.cardHeight * 0.35
        
        let spacing: CGFloat
        let positions: [CGPoint]
        
        switch position {
        case .bottom:
            spacing = spacingFor(count: total, span: availW, cardExtent: L.cardWidth)
            let span = spacing * CGFloat(total - 1)
            let startX = size.width / 2 - span / 2
            let y = L.edgeBottom + L.cardHeight / 2
            positions = (0..<total).map { CGPoint(x: startX + CGFloat($0) * spacing, y: y) }
            
        case .top:
            spacing = spacingFor(count: total, span: availW, cardExtent: L.cardWidth)
            let span = spacing * CGFloat(total - 1)
            let startX = size.width / 2 - span / 2
            let y = size.height - L.edgeTop - L.cardHeight / 2
            positions = (0..<total).map { CGPoint(x: startX + CGFloat($0) * spacing, y: y) }
            
        case .left:
            spacing = spacingFor(count: total, span: availH, cardExtent: L.cardHeight)
            let span = spacing * CGFloat(total - 1)
            let startY = size.height / 2 + span / 2
            let x = L.edgeSide
            positions = (0..<total).map { CGPoint(x: x, y: startY - CGFloat($0) * spacing) }
            
        case .right:
            spacing = spacingFor(count: total, span: availH, cardExtent: L.cardHeight)
            let span = spacing * CGFloat(total - 1)
            let startY = size.height / 2 + span / 2
            let x = size.width - L.edgeSide
            positions = (0..<total).map { CGPoint(x: x, y: startY - CGFloat($0) * spacing) }
        }
        
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            
            card.setScale(1.0)
            card.zRotation = 0
            card.facedUp = isFaceUp
            // Scene handles taps; per-card interaction blocks PlayScene touchesBegan.
            card.isUserInteractionEnabled = false
            card.zPosition = min(CardLevel.board.rawValue + CGFloat(i), controlsZ - 50)
            card.position = positions[i]
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let btn = actionButton(at: location) {
            GameAudio.shared.ui()
            switch btn.name {
            case "Playbtn": handleHumanPlay()
            case "Doubtbtn": handleHumanDoubt()
            default: break
            }
            return
        }

        let nodesAtPoint = nodes(at: location)
        for node in nodesAtPoint {
            if isButton(node, named: "Back") {
                GameAudio.shared.ui()
                goToMainMenu()
                return
            }
            if isButton(node, named: "Menu") {
                GameAudio.shared.ui()
                goToMainMenu()
                return
            }
        }

        for node in nodesAtPoint {
            if handleCardSelection(node) { return }
        }
    }
    
    private func isButton(_ node: SKNode, named name: String) -> Bool {
        var current: SKNode? = node
        let target = "\(name)btn"
        while let currentNode = current {
            if currentNode.name == target { return true }
            current = currentNode.parent
        }
        return false
    }
    
    private func cardFromNode(_ node: SKNode) -> Card? {
        var current: SKNode? = node
        while let c = current {
            if let card = c as? Card { return card }
            current = c.parent
        }
        return nil
    }
    
    private func canSelectCard(_ card: Card) -> Bool {
        guard !isWatchAI, gameState == .waitingForHuman else { return false }
        guard let current = players[safe: currentPlayerIndex], current.isHuman else { return false }
        return current.playerHand.contains { $0 === card }
    }
    
    private func handleCardSelection(_ node: SKNode) -> Bool {
        guard let card = cardFromNode(node), canSelectCard(card) else { return false }
        toggleCardSelection(card)
        GameAudio.shared.select()
        GameAudio.shared.hapticLight()
        return true
    }
    
    private func returnCardToHand(_ card: Card) {
        guard let owner = players.first(where: { $0.playerHand.contains(where: { $0 === card }) }) else { return }
        layoutHand(for: owner)
    }
    
    private func toggleCardSelection(_ card: Card) {
        if selectedCards.contains(where: { $0 === card }) {
            selectedCards.removeAll { $0 === card }
            card.setSelected(false)
        } else if selectedCards.count >= maxCardsPerPlay {
            return
        } else {
            selectedCards.append(card)
            card.setSelected(true)
        }
        
        updatePlayButtonVisibility()
    }
    
    private func updatePlayButtonVisibility() {
        guard !isWatchAI else { return }
        let enabled = !selectedCards.isEmpty
        playButton?.alpha = enabled ? 1.0 : 0.4
        let count = selectedCards.count
        playButton?.setButtonTitle(count > 0 ? "Play (\(count))" : "Play")
    }
    
    // MARK: - Game Logic
    private func handleHumanDoubt() {
        do {
            guard !isWatchAI, gameState == .waitingForHuman else {
                throw GameError.invalidGameState
            }
            guard let current = players[safe: currentPlayerIndex], current.isHuman else {
                throw GameError.noHumanPlayerFound
            }
            guard canCallDoubt(for: current) else { return }
            
            try resolveDoubt(calledBy: current)
            nextTurn()
        } catch {
            print("Error handling human doubt: \(error.localizedDescription)")
        }
    }
    
    private func handleHumanPlay() {
        do {
            guard !isWatchAI, gameState == .waitingForHuman else {
                throw GameError.invalidGameState
            }
            guard !selectedCards.isEmpty else { return }
            guard selectedCards.count <= maxCardsPerPlay else {
                showToast("Play at most \(maxCardsPerPlay) cards.")
                return
            }
            guard let current = players[safe: currentPlayerIndex], current.isHuman else {
                throw GameError.noHumanPlayerFound
            }
            
            GameAudio.shared.playCards()
            let played = selectedCards
            for card in played {
                try moveCard(card, from: current, to: discardPile)
                card.facedUp = false
            }
            
            lastPlayedCards = played
            lastPlayedValue = currentRank
            lastPlayerName = current.name ?? ""
            advanceRank()
            
            selectedCards.removeAll()
            updatePlayButtonVisibility()
            layoutHand(for: current)
            
            if current.playerHand.isEmpty {
                gameOver(winner: current.name ?? "Player")
                return
            }
            nextTurn()
        } catch {
            print("Error handling human play: \(error.localizedDescription)")
        }
    }
    
    private func canCallDoubt(for player: Player?) -> Bool {
        guard let player = player,
              !lastPlayedCards.isEmpty,
              lastPlayerName != player.name else {
            return false
        }
        return true
    }
    
    private func cardMatchesClaim(_ card: Card, claim: Value) -> Bool {
        if card.value == claim { return true }
        if isWacky && card.value == .Joker { return true }
        return false
    }
    
    private func resolveDoubt(calledBy doubter: Player) throws {
        guard let claim = lastPlayedValue,
              let cheater = players.first(where: { $0.name == lastPlayerName }),
              !lastPlayedCards.isEmpty else {
            throw GameError.invalidGameState
        }
        
        let lied = lastPlayedCards.contains { !cardMatchesClaim($0, claim: claim) }
        let loser = lied ? cheater : doubter
        
        GameAudio.shared.doubt()
        if lied {
            showToast("\(doubter.name ?? "Player") caught \(cheater.name ?? "AI") bluffing!")
            GameAudio.shared.doubtWin()
        } else {
            showToast("\(doubter.name ?? "Player") doubted incorrectly!")
            GameAudio.shared.doubtLose()
        }
        
        redistributeDiscardPile(to: loser)
        lastPlayedCards.removeAll()
        layoutAllHands()
        updateRankIndicator()
        updatePileCountLabel()
    }
    
    private func cardsOnDiscardPile() -> [Card] {
        discardPile.children.compactMap { $0 as? Card }
    }
    
    private func redistributeDiscardPile(to player: Player) {
        for card in cardsOnDiscardPile() {
            card.removeFromParent()
            player.addCard(card)
        }
    }
    
    private func advanceRank() {
        currentRankIndex = (currentRankIndex + 1) % 13
        updateRankIndicator()
    }
    
    private func updateRankIndicator() {
        rankIndicator?.text = "Claim: \(currentRank.description)"
    }
    
    // MARK: - Card Movement
    private func moveCardToDiscard(_ card: Card) {
        do {
            guard let owner = players.first(where: { $0.playerHand.contains(where: { $0 === card }) }) else {
                throw GameError.cardNotFound
            }
            
            guard gameState == .waitingForHuman else {
                throw GameError.invalidGameState
            }
            
            try moveCard(card, from: owner, to: discardPile)
            updateGameState(after: card, playedBy: owner)
            
            if owner.isHuman && owner.playerHand.isEmpty {
                gameOver(winner: "Human")
                return
            }
            
            nextTurn()
            
        } catch {
            print("Error moving card to discard: \(error.localizedDescription)")
        }
    }
    
    private func aiMoveCardToDiscard(_ card: Card) {
        do {
            guard let owner = players.first(where: { $0.playerHand.contains(where: { $0 === card }) }) else {
                throw GameError.cardNotFound
            }
            
            try moveCard(card, from: owner, to: discardPile)
            card.facedUp = false
            layoutHand(for: owner)
            
        } catch {
            print("Error moving AI card to discard: \(error.localizedDescription)")
        }
    }
    
    private func moveCard(_ card: Card, from player: Player, to destination: SKNode) throws {
        guard player.playerHand.contains(where: { $0 === card }) else {
            throw GameError.cardNotFound
        }
        
        player.playerHand.removeAll { $0 === card }
        card.removeFromParent()
        card.setSelected(false)
        destination.addChild(card)
        card.position = CGPoint.zero
        card.zPosition = CardLevel.board.rawValue + 5
        updatePileCountLabel()
    }
    
    private func updateGameState(after card: Card, playedBy player: Player) {
        lastPlayedCards.append(card)
        lastPlayedValue = card.value
        lastPlayerName = player.name ?? ""
        
        layoutHand(for: player)
    }
    
    // MARK: - Turn Management
    private func nextTurn() {
        do {
            try advanceToNextPlayer()
            try checkGameEndConditions()
            beginCurrentTurn()
        } catch GameError.gameOver {
            // handled in checkGameEndConditions
        } catch {
            print("Error advancing to next turn: \(error.localizedDescription)")
        }
    }
    
    private func advanceToNextPlayer() throws {
        guard !players.isEmpty else {
            throw GameError.noPlayersFound
        }
        
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        // Skip players with no cards
        while players[currentPlayerIndex].playerHand.isEmpty {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        }
    }
    
    private func checkGameEndConditions() throws {
        let playersWithCards = players.filter { !$0.playerHand.isEmpty }
        
        if playersWithCards.count <= 1 {
            if let winner = playersWithCards.first {
                gameOver(winner: winner.name ?? "Unknown")
            }
            throw GameError.gameOver
        }
    }
    
    private func updateGameState() {
        clearCardSelection()
        beginCurrentTurn()
    }
    
    private func clearCardSelection() {
        for card in selectedCards {
            card.setSelected(false)
        }
        selectedCards.removeAll()
        
        // Keep button visible but greyed out if it's human's turn
        if let currentPlayer = players[safe: currentPlayerIndex], currentPlayer.isHuman {
            updatePlayButtonVisibility()
        }
    }
    
    private func updateTurnIndicator() {
        guard let currentPlayer = players[safe: currentPlayerIndex] else { return }
        turnIndicator?.text = "\(currentPlayer.name ?? "Player")'s turn"

        if currentPlayer.isHuman && !isWatchAI && gameState == .waitingForHuman {
            turnHintLabel?.text = "Tap cards, then Play"
            turnHintLabel?.isHidden = false
        } else {
            turnHintLabel?.text = ""
            turnHintLabel?.isHidden = true
        }

        updateRankIndicator()
        updateSeatLabels()
        updateSeatHighlights()

        guard !isWatchAI else { return }
        if currentPlayer.isHuman && gameState == .waitingForHuman {
            updatePlayButtonVisibility()
            doubtButton?.alpha = canCallDoubt(for: currentPlayer) ? 1.0 : 0.4
        } else {
            playButton?.alpha = 0.4
            doubtButton?.alpha = 0.4
        }
    }
    
    // MARK: - AI Logic
    private func aiPlayTurn() {
        do {
            guard gameState == .waitingForAI else {
                throw GameError.invalidGameState
            }
            
            guard currentPlayerIndex < players.count else {
                throw GameError.invalidPlayerIndex
            }
            
            let player = players[currentPlayerIndex]
            guard !player.isHuman else { return }
            guard !player.playerHand.isEmpty else { return }
            
            try executeAITurn(for: player)
            
        } catch {
            print("Error in AI turn: \(error.localizedDescription)")
            nextTurn()
        }
    }
    
    private func executeAITurn(for player: Player) throws {
        if canCallDoubt(for: player),
           let claim = lastPlayedValue,
           player.shouldCallDoubt(
            lastValue: claim,
            numCardsPlayed: lastPlayedCards.count,
            lastPlayerCount: players.first(where: { $0.name == lastPlayerName })?.cardCount ?? 0
           ) {
            try resolveDoubt(calledBy: player)
        } else {
            try handleAICardPlay(for: player, value: currentRank)
        }
        
        if player.playerHand.isEmpty {
            gameOver(winner: player.name ?? "AI")
            return
        }
        
        nextTurn()
    }
    
    private func handleAICardPlay(for player: Player, value: Value) throws {
        let cardsToPlay = player.playHandWithBluffing(currValue: value, maxCards: maxCardsPerPlay)
        guard !cardsToPlay.isEmpty else {
            if let fallback = player.playerHand.first {
                try moveCard(fallback, from: player, to: discardPile)
                lastPlayedCards = [fallback]
                lastPlayedValue = value
                lastPlayerName = player.name ?? ""
                advanceRank()
                layoutHand(for: player)
            }
            return
        }
        
        for card in cardsToPlay {
            aiMoveCardToDiscard(card)
        }
        
        lastPlayedCards = cardsToPlay
        lastPlayedValue = value
        lastPlayerName = player.name ?? ""
        advanceRank()
        
        let bluffed = cardsToPlay.contains { !cardMatchesClaim($0, claim: value) }
        if bluffed {
            print("\(player.name ?? "AI") bluffed — played \(cardsToPlay.count) card(s)")
        } else {
            print("\(player.name ?? "AI") played \(cardsToPlay.count) card(s)")
        }
    }
    
    // MARK: - Game End
    private func gameOver(winner: String) {
        gameState = .gameOver
        GameAudio.shared.win()
        GameAudio.shared.hapticMedium()
        updateSeatHighlights()
        showGameOverMessage(winner: winner)
    }
    
    private func showGameOverMessage(winner: String) {
        gameOverContainer?.removeFromParent()
        let container = SKNode()
        container.zPosition = 1999
        gameOverContainer = container
        
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.45)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        container.addChild(overlay)
        
        let panel = GameTheme.makeHUDPanel(width: min(size.width - 48, 320), height: 100)
        panel.position = CGPoint(x: size.width/2, y: size.height/2 + 20)
        container.addChild(panel)
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontName = GameTheme.titleFont
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 38)
        container.addChild(gameOverLabel)
        
        let winnerLabel = SKLabelNode(text: "\(winner) wins!")
        winnerLabel.fontName = GameTheme.bodyFont
        winnerLabel.fontSize = 22
        winnerLabel.fontColor = GameTheme.gold
        winnerLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 4)
        container.addChild(winnerLabel)
        
        let menuBtn = button(name: "Menu", color: GameTheme.buttonGray, label: "Main Menu", style: .menu)
        menuBtn.position = CGPoint(x: size.width/2, y: size.height/2 - 78)
        menuBtn.zPosition = 2002
        container.addChild(menuBtn)
        
        addChild(container)
    }
    
    // MARK: - Layout (rotation / size class)
    func layoutForCurrentSize() {
        GameLayout.configure(for: size)

        children.filter { $0.zPosition <= -8 }.forEach { $0.removeFromParent() }
        GameTheme.addBackground(to: self, size: size)
        GameTheme.addTableFelt(to: self, size: size)

        if let back = childNode(withName: "Backbtn") {
            let m = L.margins
            back.position = CGPoint(
                x: m.horizontal + back.frame.width / 2,
                y: size.height - m.top - back.frame.height / 2
            )
        }

        layoutDiscardPileGeometry()
        layoutHUDGeometry()
        layoutSeatUILabelPositions()
        layoutActionControls()
        updateTurnIndicator()

        for player in players {
            for card in player.playerHand {
                card.applyLayoutMetrics()
            }
        }
        for card in cardsOnDiscardPile() {
            card.applyLayoutMetrics()
        }
        layoutAllHands()
    }

    private func layoutDiscardPileGeometry() {
        guard let discardPile = discardPile else { return }
        let cardSize = L.cardSize
        let corner = max(12, L.cardCornerRadius)
        let rect = CGRect(x: -cardSize.width / 2, y: -cardSize.height / 2, width: cardSize.width, height: cardSize.height)
        discardPile.position = CGPoint(x: size.width / 2, y: size.height / 2)
        (discardPile.childNode(withName: "discardShadow") as? SKShapeNode)?.path =
            CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
        (discardPile.childNode(withName: "discardFill") as? SKShapeNode)?.path =
            CGPath(roundedRect: rect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    }

    private func layoutHUDGeometry() {
        let m = L.margins
        let panelY = size.height - m.top - L.cardHeight * 0.12 - L.hudPanelHeight / 2 - 6
        hudPanel?.path = CGPath(roundedRect: CGRect(x: -L.hudPanelWidth/2, y: -L.hudPanelHeight/2, width: L.hudPanelWidth, height: L.hudPanelHeight), cornerWidth: 14, cornerHeight: 14, transform: nil)
        hudPanel?.position = CGPoint(x: size.width / 2, y: panelY)
        turnIndicator?.fontSize = L.hudTurnSize
        turnHintLabel?.fontSize = L.hudHintSize
        rankIndicator?.fontSize = L.hudClaimSize

        if let panel = childNode(withName: "ToastPanel") as? SKShapeNode {
            let w = min(size.width - 48, 360)
            panel.path = CGPath(roundedRect: CGRect(x: -w/2, y: -24, width: w, height: 48), cornerWidth: 14, cornerHeight: 14, transform: nil)
            panel.position = CGPoint(x: size.width / 2, y: size.height * 0.44)
        }
    }

    private func layoutSeatUILabelPositions() {
        guard seatLabelNodes.count == 4 else { return }
        let labelOffset = max(10, L.cardHeight * 0.06)
        let sideX = max(L.edgeSide * 0.35, 20)
        let positions: [CGPoint] = [
            CGPoint(x: size.width / 2, y: L.edgeBottom + L.cardHeight + labelOffset),
            CGPoint(x: sideX, y: size.height / 2),
            CGPoint(x: size.width / 2, y: size.height - L.edgeTop - L.cardHeight - labelOffset),
            CGPoint(x: size.width - sideX, y: size.height / 2)
        ]
        for (i, label) in seatLabelNodes.enumerated() {
            label.position = positions[i]
            label.fontSize = L.seatLabelSize
            if i < seatHighlightNodes.count {
                seatHighlightNodes[i].position = positions[i]
            }
        }
    }

    // MARK: - Navigation
    private func goToMainMenu() {
        guard let view = self.view else { return }
        removeAllActions()
        let mainMenu = MainMenu(size: view.bounds.size)
        mainMenu.scaleMode = .aspectFill
        view.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 0.5))
    }
}

// MARK: - Extensions
private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        hypot(self.x - point.x, self.y - point.y)
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
