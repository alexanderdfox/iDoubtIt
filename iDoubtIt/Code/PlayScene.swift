import Foundation
import SpriteKit

enum CardLevel: CGFloat { case board = 20; case moving = 40; case enlarged = 60 }

class PlayScene: SKScene {
    
    var discardPile: SKSpriteNode!
    var players: [Player] = []
    var pickedCard: Card?
    var isWacky: Bool = false
    private var lastTapTime: TimeInterval = 0
    private let doubleTapThreshold: TimeInterval = 0.35
    
    override func didMove(to view: SKView) {
        self.isUserInteractionEnabled = true
        setupBackground()
        setupDiscardPile()
        setupDeckAndPlayers()
        setupBackButton()
        
        // Let AI play first turn if human is not first
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
            self?.aiPlayTurn()
        }
    }

    // MARK: - Setup Methods
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
        discardPile = button(name: "Discard", color: .yellow, label: "Discard")
        discardPile.position = CGPoint(x: size.width/2, y: size.height/2)
        discardPile.alpha = 0.85
        discardPile.zPosition = CardLevel.board.rawValue + 5
        discardPile.setScale(1.5)
        addChild(discardPile)
    }

    private func setupDeckAndPlayers() {
        let deck = Deck(wacky: isWacky)
        deck.naturalShuffle()
        deck.randShuffle()
        deck.naturalShuffle()

        // Players
        let human = Player(human: true, playerName: "Human", level: .easy)
        let ai1 = Player(human: false, playerName: "AI 1", level: .easy)
        let ai2 = Player(human: false, playerName: "AI 2", level: .easy)
        let ai3 = Player(human: false, playerName: "AI 3", level: .easy)
        players = [human, ai1, ai2, ai3]

        // Deal cards evenly
        for (index, card) in deck.gameDeck.enumerated() {
            players[index % players.count].addCard(card)
        }

        // Layout hands
        for player in players { addChild(player) }
        layoutAllHands()
    }

    private func layoutAllHands() {
        for player in players {
            switch player.name {
            case "Human": layoutHandBottom(player)
            case "AI 1": layoutHandLeft(player)
            case "AI 2": layoutHandTop(player)
            case "AI 3": layoutHandRight(player)
            default: break
            }
        }
    }

    // MARK: - Hand Layout Helpers
    private func layoutHandBottom(_ player: Player) {
        let hand = player.playerHand
        let spacing: CGFloat = 50
        let totalWidth = spacing * CGFloat(hand.count - 1)
        let startX = size.width/2 - totalWidth/2
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            card.setScale(1.0)
            card.facedUp = true
            card.isUserInteractionEnabled = true
            card.zPosition = CardLevel.board.rawValue
            card.position = CGPoint(x: startX + CGFloat(i)*spacing, y: 120)
            card.zRotation = 0
        }
    }

    private func layoutHandTop(_ player: Player) {
        let hand = player.playerHand
        let spacing: CGFloat = 50
        let totalWidth = spacing * CGFloat(hand.count - 1)
        let startX = size.width/2 - totalWidth/2
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            card.setScale(1.0)
            card.facedUp = false
            card.isUserInteractionEnabled = false
            card.zPosition = CardLevel.board.rawValue
            card.position = CGPoint(x: startX + CGFloat(i)*spacing, y: size.height - 120)
            card.zRotation = .pi
        }
    }

    private func layoutHandLeft(_ player: Player) {
        let hand = player.playerHand
        let spacing: CGFloat = 50
        let totalHeight = spacing * CGFloat(hand.count - 1)
        let startY = size.height/2 + totalHeight/2
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            card.setScale(1.0)
            card.facedUp = false
            card.isUserInteractionEnabled = false
            card.zPosition = CardLevel.board.rawValue
            card.position = CGPoint(x: 120, y: startY - CGFloat(i)*spacing)
            card.zRotation = .pi/2
        }
    }

    private func layoutHandRight(_ player: Player) {
        let hand = player.playerHand
        let spacing: CGFloat = 50
        let totalHeight = spacing * CGFloat(hand.count - 1)
        let startY = size.height/2 + totalHeight/2
        for (i, card) in hand.enumerated() {
            if card.parent == nil { addChild(card) }
            card.setScale(1.0)
            card.facedUp = false
            card.isUserInteractionEnabled = false
            card.zPosition = CardLevel.board.rawValue
            card.position = CGPoint(x: size.width - 120, y: startY - CGFloat(i)*spacing)
            card.zRotation = -.pi/2
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        let now = CACurrentMediaTime()

        for node in nodesAtPoint {
            if node.name == "Backbtn" || node.name == "Backlabel" {
                goToMainMenu()
                return
            }

            if let card = node as? Card, card.isUserInteractionEnabled {
                // Double-tap check
                if now - lastTapTime < doubleTapThreshold {
                    moveCardToDiscard(card)
                    lastTapTime = 0
                    return
                } else {
                    pickedCard = card
                    card.zPosition = CardLevel.moving.rawValue
                    lastTapTime = now
                    break
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let card = pickedCard else { return }
        let location = touch.location(in: self)
        card.position = CGPoint(x: location.x - card.touchOffset.x, y: location.y - card.touchOffset.y)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = pickedCard else { return }

        // Snap to discard if close
        if card.position.distance(to: discardPile.position) < 100 {
            moveCardToDiscard(card)
        } else {
            // Return to hand
            if let owner = players.first(where: { $0.playerHand.contains(card) }) {
                switch owner.name {
                case "Human": layoutHandBottom(owner)
                case "AI 1": layoutHandLeft(owner)
                case "AI 2": layoutHandTop(owner)
                case "AI 3": layoutHandRight(owner)
                default: break
                }
            }
        }
        pickedCard = nil
    }

    // MARK: - Game Helpers
    private func moveCardToDiscard(_ card: Card) {
        guard let owner = players.first(where: { $0.playerHand.contains(card) }) else { return }

        // Remove from owner's hand
        owner.playerHand.removeAll(where: { $0 == card })

        // Remove from scene and add to discard pile
        card.removeFromParent()
        discardPile.addChild(card)
        card.position = CGPoint.zero
        card.zPosition = CardLevel.board.rawValue + 5

        // Flip card face up if AI played it
        if !owner.isHuman {
            card.facedUp = true
//            card.texture = card.frontTexture // assumes Card has a frontTexture property
        }

        // Relayout the owner's hand
        switch owner.name {
        case "Human": layoutHandBottom(owner)
        case "AI 1": layoutHandLeft(owner)
        case "AI 2": layoutHandTop(owner)
        case "AI 3": layoutHandRight(owner)
        default: break
        }
    }

    // MARK: - AI Turn Loop
    private func aiPlayTurn() {
        // All AI players in order
        let aiPlayers = players.filter { !$0.isHuman }
        playAISequentially(aiPlayers, index: 0)
    }

    // Recursive helper to handle AI turns sequentially with 1s delay
    private func playAISequentially(_ aiPlayers: [Player], index: Int) {
        guard index < aiPlayers.count else { return }

        let player = aiPlayers[index]
        guard !player.playerHand.isEmpty else {
            playAISequentially(aiPlayers, index: index + 1)
            return
        }

        // Determine last discard value
        let lastValue: Value
        if let topCard = discardPile.children.last as? Card {
            lastValue = topCard.value
        } else if let firstCard = player.playerHand.first {
            lastValue = firstCard.value
        } else {
            return
        }

        // AI plays cards
        let cardsToPlay = player.playHand(currValue: lastValue)
        for card in cardsToPlay {
            moveCardToDiscard(card)
        }

        // AI may call doubt
        player.callDoubt(lastValue: lastValue, numCardsPlayed: cardsToPlay.count, lastPlayerCount: player.playerHand.count)

        // Delay 1 second before next AI
        run(SKAction.wait(forDuration: 1.0)) { [weak self] in
            self?.playAISequentially(aiPlayers, index: index + 1)
        }
    }

    private func goToMainMenu() {
        if let view = self.view {
            let mainMenu = MainMenu(size: view.bounds.size)
            mainMenu.scaleMode = .aspectFill
            view.presentScene(mainMenu, transition: SKTransition.fade(withDuration: 0.5))
        }
    }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        hypot(self.x - point.x, self.y - point.y)
    }
}
