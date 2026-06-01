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
class PlayScene: SKScene {
    
    // MARK: - Properties
    var discardPile: SKSpriteNode!
    var players: [Player] = []
    var pickedCard: Card?
    var isWacky: Bool = false
    
    // MARK: - Private Properties
    private var lastTapTime: TimeInterval = 0
    private let doubleTapThreshold: TimeInterval = 0.35
    private var doubtButton: SKSpriteNode?
    private var playButton: SKSpriteNode?
    
    // MARK: - Game State Management
    private var currentPlayerIndex: Int = 0
    private var gameState: GameState = .waitingForHuman
    private var lastPlayedCards: [Card] = []
    private var lastPlayedValue: Value?
    private var lastPlayerName: String = ""
    private var currentRank: Value = .Ace
    private var turnIndicator: SKLabelNode?
    private var rankIndicator: SKLabelNode?
    private var pileCountLabel: SKLabelNode?
    private var selectedCards: [Card] = []
    private var maxCardsPerPlay: Int { isWacky ? 6 : 4 }
    
    // Layout (matches Card 160×220; keeps hands on screen, cards upright)
    private let layoutCardW: CGFloat = 160
    private let layoutCardH: CGFloat = 220
    private let layoutMinSpacing: CGFloat = 22
    private let layoutPreferredSpacing: CGFloat = 42
    private let layoutEdgeX: CGFloat = 88
    private let layoutEdgeBottom: CGFloat = 108
    private let layoutEdgeTop: CGFloat = 108
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
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
    }
    
    private func setupBackground() {
        GameTheme.addBackground(to: self, size: size)
        GameTheme.addTableFelt(to: self, size: size)
    }
    
    private func setupBackButton() {
        let backButton = button(name: "Back", color: GameTheme.buttonGray, label: "Back")
        backButton.position = CGPoint(x: backButton.size.width/2 + 20,
                                      y: size.height - backButton.size.height/2 - 20)
        backButton.zPosition = 999
        addChild(backButton)
    }
    
    private func setupDiscardPile() {
        let cardSize = CGSize(width: 160, height: 220)
        discardPile = SKSpriteNode(color: .clear, size: cardSize)
        discardPile.position = CGPoint(x: size.width/2, y: size.height/2)
        discardPile.zPosition = CardLevel.board.rawValue + 5
        discardPile.name = "DiscardPile"
        
        let shadow = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: -5)
        shadow.zPosition = 0
        discardPile.addChild(shadow)
        
        let fill = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        fill.fillColor = GameTheme.discardFill
        fill.strokeColor = .black
        fill.lineWidth = 2
        fill.zPosition = 1
        discardPile.addChild(fill)
        
        let label = SKLabelNode(text: "Discard")
        label.fontName = GameTheme.bodyFont
        label.fontSize = 18
        label.fontColor = UIColor(white: 0.1, alpha: 0.85)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 12)
        label.zPosition = 2
        discardPile.addChild(label)
        
        pileCountLabel = SKLabelNode(text: "")
        pileCountLabel?.fontName = GameTheme.titleFont
        pileCountLabel?.fontSize = 28
        pileCountLabel?.fontColor = UIColor(white: 0.1, alpha: 0.9)
        pileCountLabel?.verticalAlignmentMode = .center
        pileCountLabel?.horizontalAlignmentMode = .center
        pileCountLabel?.position = CGPoint(x: 0, y: -18)
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
        let level = Difficulty(rawValue: Pref.shared.difficulty) ?? .easy
        let human = Player(human: true, playerName: "Human", level: level, wacky: isWacky)
        let ai1 = Player(human: false, playerName: "AI 1", level: level, wacky: isWacky)
        let ai2 = Player(human: false, playerName: "AI 2", level: level, wacky: isWacky)
        let ai3 = Player(human: false, playerName: "AI 3", level: level, wacky: isWacky)
        
        players = [human, ai1, ai2, ai3]
        
        for player in players {
            addChild(player)
        }
    }
    
    private func createBasicPlayers() {
        let level = Difficulty(rawValue: Pref.shared.difficulty) ?? .easy
        let human = Player(human: true, playerName: "Human", level: level, wacky: isWacky)
        let ai1 = Player(human: false, playerName: "AI 1", level: level, wacky: isWacky)
        let ai2 = Player(human: false, playerName: "AI 2", level: level, wacky: isWacky)
        let ai3 = Player(human: false, playerName: "AI 3", level: level, wacky: isWacky)
        
        players = [human, ai1, ai2, ai3]
        
        for player in players {
            addChild(player)
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
        let hudY = size.height - layoutEdgeTop - layoutCardH - 36
        let panel = GameTheme.makeHUDPanel(width: min(size.width - 40, 280), height: 72)
        panel.position = CGPoint(x: size.width/2, y: hudY + 14)
        panel.zPosition = 999
        addChild(panel)
        
        turnIndicator = SKLabelNode(text: "Human's Turn")
        turnIndicator?.fontName = GameTheme.titleFont
        turnIndicator?.fontSize = 22
        turnIndicator?.fontColor = .white
        turnIndicator?.position = CGPoint(x: size.width/2, y: hudY + 28)
        turnIndicator?.zPosition = 1000
        
        rankIndicator = SKLabelNode(text: "Claim: Ace")
        rankIndicator?.fontName = GameTheme.bodyFont
        rankIndicator?.fontSize = 17
        rankIndicator?.fontColor = GameTheme.gold
        rankIndicator?.position = CGPoint(x: size.width/2, y: hudY)
        rankIndicator?.zPosition = 1000
        
        if let turnIndicator = turnIndicator { addChild(turnIndicator) }
        if let rankIndicator = rankIndicator { addChild(rankIndicator) }
    }
    
    private func setupDoubtButton() {
        doubtButton = button(name: "Doubt", color: GameTheme.buttonRed, label: "Doubt")
        guard let doubtButton = doubtButton else { return }
        
        doubtButton.zPosition = 1000
        doubtButton.name = "Doubt"
        addChild(doubtButton)
        
        positionDoubtButton()
    }
    
    private func setupPlayButton() {
        playButton = button(name: "Play", color: GameTheme.buttonGreen, label: "Play")
        guard let playButton = playButton else { return }
        
        playButton.zPosition = 1000
        playButton.name = "Play"
        playButton.alpha = 1.0 // Always visible
        addChild(playButton)
        
        positionPlayButton()
    }
    
    private func positionDoubtButton() {
        positionActionButtons()
    }
    
    private func positionPlayButton() {
        positionActionButtons()
    }
    
    private func positionActionButtons() {
        let handCenterY = layoutEdgeBottom + layoutCardH / 2
        let buttonY = min(handCenterY + layoutCardH / 2 + 56, size.height * 0.38)
        let spread: CGFloat = min(100, size.width * 0.12)
        doubtButton?.position = CGPoint(x: size.width / 2 - spread, y: buttonY)
        playButton?.position = CGPoint(x: size.width / 2 + spread, y: buttonY)
    }
    
    private func spacingFor(count: Int, span: CGFloat, cardExtent: CGFloat) -> CGFloat {
        guard count > 1 else { return 0 }
        let needed = layoutPreferredSpacing * CGFloat(count - 1) + cardExtent
        if needed <= span { return layoutPreferredSpacing }
        return max(layoutMinSpacing, (span - cardExtent) / CGFloat(count - 1))
    }
    
    // MARK: - Game Start
    private func startGame() {
        updateRankIndicator()
        if let firstPlayer = players.first, firstPlayer.isHuman {
            gameState = .waitingForHuman
            updateTurnIndicator()
        } else {
            gameState = .waitingForAI
            updateTurnIndicator()
            scheduleAITurn()
        }
    }
    
    private func scheduleAITurn() {
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
            self?.aiPlayTurn()
        }
    }
    
    // MARK: - Hand Layout
    private func layoutAllHands() {
        for player in players {
            layoutHand(for: player)
        }
        positionActionButtons()
    }
    
    private func layoutHand(for player: Player) {
        switch player.name {
        case "Human": layoutHandBottom(player)
        case "AI 1": layoutHandLeft(player)
        case "AI 2": layoutHandTop(player)
        case "AI 3": layoutHandRight(player)
        default: break
        }
    }
    
    private func layoutHandBottom(_ player: Player) {
        layoutHand(player, at: .bottom, isFaceUp: true, isInteractive: true)
    }
    
    private func layoutHandTop(_ player: Player) {
        layoutHand(player, at: .top, isFaceUp: false, isInteractive: false)
    }
    
    private func layoutHandLeft(_ player: Player) {
        layoutHand(player, at: .left, isFaceUp: false, isInteractive: false)
    }
    
    private func layoutHandRight(_ player: Player) {
        layoutHand(player, at: .right, isFaceUp: false, isInteractive: false)
    }
    
    private enum HandPosition {
        case top, bottom, left, right
    }
    
    private func layoutHand(_ player: Player, at position: HandPosition, isFaceUp: Bool, isInteractive: Bool) {
        let hand = player.playerHand
        let total = hand.count
        guard total > 0 else { return }
        
        let availW = size.width - layoutEdgeX * 2
        let availH = size.height - layoutEdgeTop - layoutEdgeBottom - 80
        
        let spacing: CGFloat
        let positions: [CGPoint]
        
        switch position {
        case .bottom:
            spacing = spacingFor(count: total, span: availW, cardExtent: layoutCardW)
            let span = spacing * CGFloat(total - 1)
            let startX = size.width / 2 - span / 2
            let y = layoutEdgeBottom + layoutCardH / 2
            positions = (0..<total).map { CGPoint(x: startX + CGFloat($0) * spacing, y: y) }
            
        case .top:
            spacing = spacingFor(count: total, span: availW, cardExtent: layoutCardW)
            let span = spacing * CGFloat(total - 1)
            let startX = size.width / 2 - span / 2
            let y = size.height - layoutEdgeTop - layoutCardH / 2
            positions = (0..<total).map { CGPoint(x: startX + CGFloat($0) * spacing, y: y) }
            
        case .left:
            spacing = spacingFor(count: total, span: availH, cardExtent: layoutCardH)
            let span = spacing * CGFloat(total - 1)
            let startY = size.height / 2 + span / 2
            let x = layoutEdgeX
            positions = (0..<total).map { CGPoint(x: x, y: startY - CGFloat($0) * spacing) }
            
        case .right:
            spacing = spacingFor(count: total, span: availH, cardExtent: layoutCardH)
            let span = spacing * CGFloat(total - 1)
            let startY = size.height / 2 + span / 2
            let x = size.width - layoutEdgeX
            positions = (0..<total).map { CGPoint(x: x, y: startY - CGFloat($0) * spacing) }
        }
        
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            
            card.setScale(1.0)
            card.zRotation = 0
            card.facedUp = isFaceUp
            card.isUserInteractionEnabled = isInteractive
            card.zPosition = CardLevel.board.rawValue + CGFloat(i)
            card.position = positions[i]
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        let now = CACurrentMediaTime()
        
        for node in nodesAtPoint {
            if isButton(node, named: "Back") {
                goToMainMenu()
                return
            }
            if isButton(node, named: "Doubt") {
                handleHumanDoubt()
                return
            }
            if isButton(node, named: "Play") {
                handleHumanPlay()
                return
            }
            if handleCardSelection(node, at: now) { return }
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
    
    private func handleCardSelection(_ node: SKNode, at time: TimeInterval) -> Bool {
        guard let card = node as? Card, card.isUserInteractionEnabled else { return false }
        guard gameState == .waitingForHuman else { return false }
        
        if time - lastTapTime < doubleTapThreshold {
            // Double tap toggles card selection
            toggleCardSelection(card)
            lastTapTime = 0
            return true
        } else {
            // Single tap for dragging
            pickedCard = card
            card.zPosition = CardLevel.moving.rawValue
            lastTapTime = time
            return true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = pickedCard,
              let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        card.position = CGPoint(x: location.x - card.touchOffset.x, y: location.y - card.touchOffset.y)
        
        // Visual feedback when card is near discard pile
        let distanceToDiscard = card.position.distance(to: discardPile.position)
        if distanceToDiscard < 100 {
            // Highlight discard pile when card is close
            discardPile.alpha = 1.0
            discardPile.setScale(1.1)
        } else {
            // Return discard pile to normal state
            discardPile.alpha = 0.85
            discardPile.setScale(1.0)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = pickedCard else { return }
        
        // Check if card was dropped on discard pile
        if card.position.distance(to: discardPile.position) < 100 {
            // Card was dropped on discard pile - add it to selected cards
            if !selectedCards.contains(where: { $0 === card }) {
                toggleCardSelection(card)
            }
        }
        
        // Return card to hand
        returnCardToHand(card)
        pickedCard = nil
        
        // Reset discard pile visual state
        resetDiscardPileVisual()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = pickedCard else { return }
        
        // Return card to hand and reset visual state
        returnCardToHand(card)
        pickedCard = nil
        resetDiscardPileVisual()
    }
    
    private func resetDiscardPileVisual() {
        discardPile.alpha = 0.85
        discardPile.setScale(1.0)
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
        if selectedCards.isEmpty {
            playButton?.alpha = 0.3 // Greyed out when no cards selected
        } else {
            playButton?.alpha = 1.0 // Fully visible when cards are selected
        }
    }
    
    // MARK: - Game Logic
    private func handleHumanDoubt() {
        do {
            guard gameState == .waitingForHuman else {
                throw GameError.invalidGameState
            }
            
            guard canCallDoubt(for: players.first(where: { $0.isHuman })) else {
                return
            }
            
            guard let human = players.first(where: { $0.isHuman }) else {
                throw GameError.noHumanPlayerFound
            }
            
            try resolveDoubt(calledBy: human)
            nextTurn()
            
        } catch {
            print("Error handling human doubt: \(error.localizedDescription)")
        }
    }
    
    private func handleHumanPlay() {
        do {
            guard gameState == .waitingForHuman else {
                throw GameError.invalidGameState
            }
            
            guard !selectedCards.isEmpty else {
                print("No cards selected to play")
                return
            }
            
            guard selectedCards.count <= maxCardsPerPlay else {
                print("You can play at most \(maxCardsPerPlay) cards at once")
                return
            }
            
            guard let human = players.first(where: { $0.isHuman }) else {
                throw GameError.noHumanPlayerFound
            }
            
            let played = selectedCards
            for card in played {
                try moveCard(card, from: human, to: discardPile)
                card.facedUp = false
            }
            
            lastPlayedCards = played
            lastPlayedValue = currentRank
            lastPlayerName = human.name ?? ""
            advanceRank()
            
            // Clear selection
            selectedCards.removeAll()
            updatePlayButtonVisibility()
            
            // Layout the updated hand
            layoutHand(for: human)
            
            // Check if human has no cards left
            if human.playerHand.isEmpty {
                gameOver(winner: "Human")
                return
            }
            
            // Move to next turn
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
        
        if lied {
            print("\(doubter.name ?? "Player") caught \(cheater.name ?? "Unknown") bluffing!")
        } else {
            print("\(doubter.name ?? "Player") doubted incorrectly!")
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
        let nextRaw = currentRank.rawValue + 1
        if let next = Value(rawValue: nextRaw) {
            currentRank = next
        } else {
            currentRank = .Ace
        }
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
            updateGameState()
            updateTurnIndicator()
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
        let currentPlayer = players[currentPlayerIndex]
        
        if currentPlayer.isHuman {
            gameState = .waitingForHuman
            print("Human's turn")
            // Clear any previous card selection
            clearCardSelection()
        } else {
            gameState = .waitingForAI
            print("\(currentPlayer.name ?? "AI")'s turn")
            scheduleAITurn()
        }
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
        turnIndicator?.text = "\(currentPlayer.name ?? "Player")'s Turn"
        updateRankIndicator()
        
        if currentPlayer.isHuman {
            updatePlayButtonVisibility()
            doubtButton?.alpha = canCallDoubt(for: currentPlayer) ? 1.0 : 0.35
        } else {
            playButton?.alpha = 0.3
            doubtButton?.alpha = 0.35
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
        print("Game Over! \(winner) wins!")
        
        showGameOverMessage(winner: winner)
        
        run(SKAction.wait(forDuration: 3.0)) { [weak self] in
            self?.goToMainMenu()
        }
    }
    
    private func showGameOverMessage(winner: String) {
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.45)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = 1999
        addChild(overlay)
        
        let panel = GameTheme.makeHUDPanel(width: min(size.width - 48, 320), height: 100)
        panel.position = CGPoint(x: size.width/2, y: size.height/2)
        panel.zPosition = 2000
        addChild(panel)
        
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontName = GameTheme.titleFont
        gameOverLabel.fontSize = 32
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 18)
        gameOverLabel.zPosition = 2001
        addChild(gameOverLabel)
        
        let winnerLabel = SKLabelNode(text: "\(winner) wins!")
        winnerLabel.fontName = GameTheme.bodyFont
        winnerLabel.fontSize = 22
        winnerLabel.fontColor = GameTheme.gold
        winnerLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 18)
        winnerLabel.zPosition = 2001
        addChild(winnerLabel)
    }
    
    // MARK: - Navigation
    private func goToMainMenu() {
        guard let view = self.view else { return }
        
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
