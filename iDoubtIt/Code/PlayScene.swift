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
    private var turnIndicator: SKLabelNode?
    private var selectedCards: [Card] = []
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        startGame()
    }
    
    // MARK: - Setup Methods
    private func setupScene() {
        self.isUserInteractionEnabled = true
        setupBackground()
        setupDiscardPile()
        setupDeckAndPlayers()
        setupBackButton()
        setupDoubtButton()
        setupPlayButton()
        setupTurnIndicator()
    }
    
    private func setupBackground() {
        let bg = SKSpriteNode(color: UIColor.systemBlue, size: self.size)
        bg.anchorPoint = .zero
        bg.position = .zero
        bg.zPosition = -10
        addChild(bg)
    }
    
    private func setupBackButton() {
        let backButton = button(name: "Back", color: .darkGray, label: "Back")
        backButton.position = CGPoint(x: backButton.size.width/2 + 20,
                                      y: size.height - backButton.size.height/2 - 20)
        backButton.zPosition = 999
        addChild(backButton)
    }
    
    private func setupDiscardPile() {
        // Create discard pile with card dimensions
        let cardSize = CGSize(width: 160, height: 220)
        discardPile = SKSpriteNode(color: .yellow, size: cardSize)
        discardPile.position = CGPoint(x: size.width/2, y: size.height/2)
        discardPile.alpha = 0.85
        discardPile.zPosition = CardLevel.board.rawValue + 5
        discardPile.name = "DiscardPile"
        
        // Add a border to make it look like a card
        let border = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        border.strokeColor = .black
        border.lineWidth = 2
        border.zPosition = 1
        discardPile.addChild(border)
        
        // Add label
        let label = SKLabelNode(text: "Discard")
        label.fontSize = 16
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2
        discardPile.addChild(label)
        
        addChild(discardPile)
    }
    
    private func setupDeckAndPlayers() {
        do {
            let deck = try createAndShuffleDeck()
            try createPlayers()
            try dealCards(from: deck)
            layoutAllHands()
        } catch {
            print("Error setting up game: \(error.localizedDescription)")
            // Fallback to basic setup
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
        let human = Player(human: true, playerName: "Human", level: .easy)
        let ai1 = Player(human: false, playerName: "AI 1", level: .easy)
        let ai2 = Player(human: false, playerName: "AI 2", level: .easy)
        let ai3 = Player(human: false, playerName: "AI 3", level: .easy)
        
        players = [human, ai1, ai2, ai3]
        
        for player in players {
            addChild(player)
        }
    }
    
    private func createBasicPlayers() {
        let human = Player(human: true, playerName: "Human", level: .easy)
        let ai1 = Player(human: false, playerName: "AI 1", level: .easy)
        let ai2 = Player(human: false, playerName: "AI 2", level: .easy)
        let ai3 = Player(human: false, playerName: "AI 3", level: .easy)
        
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
        turnIndicator = SKLabelNode(text: "Human's Turn")
        turnIndicator?.fontSize = 24
        turnIndicator?.fontColor = .white
        turnIndicator?.position = CGPoint(x: size.width/2, y: size.height - 60)
        turnIndicator?.zPosition = 1000
        
        if let turnIndicator = turnIndicator {
            addChild(turnIndicator)
        }
    }
    
    private func setupDoubtButton() {
        doubtButton = button(name: "Doubt", color: .red, label: "Doubt")
        guard let doubtButton = doubtButton else { return }
        
        doubtButton.zPosition = 1000
        doubtButton.name = "Doubt"
        addChild(doubtButton)
        
        positionDoubtButton()
    }
    
    private func setupPlayButton() {
        playButton = button(name: "Play", color: .green, label: "Play")
        guard let playButton = playButton else { return }
        
        playButton.zPosition = 1000
        playButton.name = "Play"
        playButton.alpha = 1.0 // Always visible
        addChild(playButton)
        
        positionPlayButton()
    }
    
    private func positionDoubtButton() {
        guard let doubtButton = doubtButton,
              let human = players.first(where: { $0.isHuman }) else { return }
        
        let hand = human.playerHand
        if !hand.isEmpty {
            let spacing: CGFloat = 50
            let totalWidth = spacing * CGFloat(hand.count - 1)
            let startX = size.width/2 - totalWidth/2
            let centerX = startX + totalWidth / 2
            let handY: CGFloat = 120
            let spacingAbove: CGFloat = 170
            
            // Position doubt button to the left of center
            let buttonSpacing: CGFloat = 80 // Space between buttons
            doubtButton.position = CGPoint(x: centerX - buttonSpacing/2, y: handY + spacingAbove)
        } else {
            doubtButton.position = CGPoint(x: size.width/2 - 40, y: 200)
        }
    }
    
    private func positionPlayButton() {
        guard let playButton = playButton,
              let human = players.first(where: { $0.isHuman }) else { return }
        
        let hand = human.playerHand
        if !hand.isEmpty {
            let spacing: CGFloat = 50
            let totalWidth = spacing * CGFloat(hand.count - 1)
            let startX = size.width/2 - totalWidth/2
            let centerX = startX + totalWidth / 2
            let handY: CGFloat = 120
            let spacingAbove: CGFloat = 170 // Same height as doubt button
            
            // Position play button to the right of center
            let buttonSpacing: CGFloat = 80 // Space between buttons
            playButton.position = CGPoint(x: centerX + buttonSpacing/2, y: handY + spacingAbove)
        } else {
            playButton.position = CGPoint(x: size.width/2 + 40, y: 200)
        }
    }
    
    // MARK: - Game Start
    private func startGame() {
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
        let spacing: CGFloat = 50
        
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            
            card.setScale(1.0)
            card.facedUp = isFaceUp
            card.isUserInteractionEnabled = isInteractive
            card.zPosition = CardLevel.board.rawValue
            
            let cardPosition = calculateCardPosition(for: position, index: i, totalCards: hand.count, spacing: spacing)
            card.position = cardPosition.position
            card.zRotation = cardPosition.rotation
        }
    }
    
    private func calculateCardPosition(for position: HandPosition, index: Int, totalCards: Int, spacing: CGFloat) -> (position: CGPoint, rotation: CGFloat) {
        let totalWidth = spacing * CGFloat(totalCards - 1)
        let totalHeight = spacing * CGFloat(totalCards - 1)
        
        switch position {
        case .bottom:
            let startX = size.width/2 - totalWidth/2
            let x = startX + CGFloat(index) * spacing
            let y: CGFloat = 120
            return (CGPoint(x: x, y: y), 0)
            
        case .top:
            let startX = size.width/2 - totalWidth/2
            let x = startX + CGFloat(index) * spacing
            let y = size.height - 120
            return (CGPoint(x: x, y: y), .pi)
            
        case .left:
            let startY = size.height/2 + totalHeight/2
            let x: CGFloat = 120
            let y = startY - CGFloat(index) * spacing
            return (CGPoint(x: x, y: y), .pi/2)
            
        case .right:
            let startY = size.height/2 + totalHeight/2
            let x = size.width - 120
            let y = startY - CGFloat(index) * spacing
            return (CGPoint(x: x, y: y), -.pi/2)
        }
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        let now = CACurrentMediaTime()
        
        for node in nodesAtPoint {
            if handleBackButton(node) { return }
            if handleDoubtButton(node) { return }
            if handlePlayButton(node) { return }
            if handleCardSelection(node, at: now) { return }
        }
    }
    
    private func handleBackButton(_ node: SKNode) -> Bool {
        if node.name == "Backbtn" || node.name == "Backlabel" {
            goToMainMenu()
            return true
        }
        return false
    }
    
    private func handleDoubtButton(_ node: SKNode) -> Bool {
        if node.name == "Doubt" {
            handleHumanDoubt()
            return true
        }
        return false
    }
    
    private func handlePlayButton(_ node: SKNode) -> Bool {
        if node.name == "Play" {
            handleHumanPlay()
            return true
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
            if !selectedCards.contains(card) {
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
        guard let owner = players.first(where: { $0.playerHand.contains(card) }) else { return }
        layoutHand(for: owner)
    }
    
    private func toggleCardSelection(_ card: Card) {
        if selectedCards.contains(card) {
            // Deselect card
            selectedCards.removeAll { $0 == card }
            card.setScale(1.0)
            card.zPosition = CardLevel.board.rawValue
        } else {
            // Select card
            selectedCards.append(card)
            card.setScale(1.1)
            card.zPosition = CardLevel.moving.rawValue
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
            
            guard let lastCard = discardPile.children.last as? Card else {
                throw GameError.noCardsInDiscardPile
            }
            
            guard let human = players.first(where: { $0.isHuman }) else {
                throw GameError.noHumanPlayerFound
            }
            
            try resolveDoubt(calledBy: human, lastCard: lastCard)
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
            
            guard let human = players.first(where: { $0.isHuman }) else {
                throw GameError.noHumanPlayerFound
            }
            
            // Play all selected cards
            for card in selectedCards {
                try moveCard(card, from: human, to: discardPile)
                card.facedUp = true
            }
            
            // Update game state
            lastPlayedCards.append(contentsOf: selectedCards)
            lastPlayedValue = selectedCards.first?.value
            lastPlayerName = human.name ?? ""
            
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
    
    private func resolveDoubt(calledBy player: Player, lastCard: Card) throws {
        guard let lastValue = lastPlayedValue,
              let lastPlayer = players.first(where: { $0.name == lastPlayerName }) else {
            throw GameError.invalidGameState
        }
        
        let actualCards = lastPlayer.playerHand.filter { $0.value == lastValue }
        let totalCards = actualCards.count + lastPlayedCards.count
        
        if totalCards > 4 {
            // Doubt successful - last player gets all cards
            print("\(player.name ?? "Player") called doubt successfully! \(lastPlayer.name ?? "Unknown") gets all cards")
            redistributeCards(from: lastPlayedCards, to: lastPlayer)
        } else {
            // Doubt failed - calling player gets all cards
            print("\(player.name ?? "Player") called doubt incorrectly! \(player.name ?? "Player") gets all cards")
            redistributeCards(from: lastPlayedCards, to: player)
        }
        
        lastPlayedCards.removeAll()
        layoutAllHands()
    }
    
    private func redistributeCards(from cards: [Card], to player: Player) {
        for card in cards {
            card.removeFromParent()
            player.addCard(card)
        }
    }
    
    // MARK: - Card Movement
    private func moveCardToDiscard(_ card: Card) {
        do {
            guard let owner = players.first(where: { $0.playerHand.contains(card) }) else {
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
            guard let owner = players.first(where: { $0.playerHand.contains(card) }) else {
                throw GameError.cardNotFound
            }
            
            try moveCard(card, from: owner, to: discardPile)
            card.facedUp = true
            layoutHand(for: owner)
            
        } catch {
            print("Error moving AI card to discard: \(error.localizedDescription)")
        }
    }
    
    private func moveCard(_ card: Card, from player: Player, to destination: SKNode) throws {
        guard player.playerHand.contains(card) else {
            throw GameError.cardNotFound
        }
        
        player.playerHand.removeAll(where: { $0 == card })
        card.removeFromParent()
        destination.addChild(card)
        card.position = CGPoint.zero
        card.zPosition = CardLevel.board.rawValue + 5
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
            card.setScale(1.0)
            card.zPosition = CardLevel.board.rawValue
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
        
        // Update play button state based on turn
        if currentPlayer.isHuman {
            updatePlayButtonVisibility()
        } else {
            playButton?.alpha = 0.3 // Greyed out during AI turns
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
        let valueToPlay = lastPlayedValue ?? player.playerHand.randomElement()?.value ?? .Ace
        
        let shouldCallDoubt = player.shouldCallDoubt(
            lastValue: valueToPlay,
            numCardsPlayed: lastPlayedCards.count,
            lastPlayerCount: player.playerHand.count
        )
        
        if shouldCallDoubt {
            try handleAIDoubt(calledBy: player)
        } else {
            try handleAICardPlay(for: player, value: valueToPlay)
        }
        
        if player.playerHand.isEmpty {
            gameOver(winner: player.name ?? "AI")
            return
        }
        
        nextTurn()
    }
    
    private func handleAIDoubt(calledBy player: Player) throws {
        print("\(player.name ?? "AI") calls doubt!")
        
        guard let lastValue = lastPlayedValue,
              let lastPlayer = players.first(where: { $0.name == lastPlayerName }) else {
            throw GameError.invalidGameState
        }
        
        let actualCards = lastPlayer.playerHand.filter { $0.value == lastValue }
        let totalCards = actualCards.count + lastPlayedCards.count
        
        if totalCards > 4 {
            print("\(player.name ?? "AI") called doubt successfully! \(lastPlayer.name ?? "Unknown") gets all cards")
            redistributeCards(from: lastPlayedCards, to: lastPlayer)
        } else {
            print("\(player.name ?? "AI") called doubt incorrectly! \(player.name ?? "AI") gets all cards")
            redistributeCards(from: lastPlayedCards, to: player)
        }
        
        lastPlayedCards.removeAll()
        layoutAllHands()
    }
    
    private func handleAICardPlay(for player: Player, value: Value) throws {
        let cardsToPlay = player.playHand(currValue: value)
        
        for card in cardsToPlay {
            aiMoveCardToDiscard(card)
        }
        
        lastPlayedCards.append(contentsOf: cardsToPlay)
        lastPlayedValue = value
        lastPlayerName = player.name ?? ""
        
        let matchingCards = player.findCardsInHand(value: value).count
        if matchingCards == 0 && !cardsToPlay.isEmpty {
            print("\(player.name ?? "AI") bluffed and played \(cardsToPlay.count) cards")
        } else {
            print("\(player.name ?? "AI") played \(cardsToPlay.count) cards")
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
        let gameOverLabel = SKLabelNode(text: "Game Over! \(winner) wins!")
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOverLabel.zPosition = 1000
        addChild(gameOverLabel)
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
