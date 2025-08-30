//
//  Player.swift
//  iDoubtIt
//
//  Updated 2025 — Clean, well-structured code with proper error handling
//

import Foundation
import SpriteKit

// MARK: - Difficulty Levels
enum Difficulty: Int, CaseIterable {
    case easy = 60
    case medium = 35
    case hard = 15
    
    var description: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

// MARK: - AI Behavior Configuration
struct AIBehavior {
    let difficulty: Difficulty
    let bluffProbability: Int
    let doubtAggressiveness: Int
    let strategicThinking: Int
    
    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        
        switch difficulty {
        case .easy:
            self.bluffProbability = 80
            self.doubtAggressiveness = 40
            self.strategicThinking = 20
        case .medium:
            self.bluffProbability = 60
            self.doubtAggressiveness = 60
            self.strategicThinking = 50
        case .hard:
            self.bluffProbability = 30
            self.doubtAggressiveness = 80
            self.strategicThinking = 90
        }
    }
}

// MARK: - Player Class
class Player: SKSpriteNode {
    
    // MARK: - Properties
    var playerHand: [Card] = []
    var isHuman: Bool
    var difficulty: Difficulty
    var isWacky: Bool
    var aiBehavior: AIBehavior
    
    // MARK: - Computed Properties
    var hasCards: Bool {
        return !playerHand.isEmpty
    }
    
    var cardCount: Int {
        return playerHand.count
    }
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        self.isHuman = true
        self.isWacky = false
        self.difficulty = .medium
        self.aiBehavior = AIBehavior(difficulty: .medium)
        
        super.init(coder: aDecoder)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 10
    }
    
    init(human: Bool, playerName: String, level: Difficulty = .medium) {
        self.isHuman = human
        self.isWacky = false
        self.difficulty = level
        self.aiBehavior = AIBehavior(difficulty: level)
        
        let size = CGSize(width: 50, height: 190)
        super.init(texture: nil, color: .clear, size: size)
        
        self.name = playerName
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 10
    }
    
    // MARK: - Card Management
    func addCard(_ card: Card) {
        playerHand.append(card)
        addChild(card)
    }
    
    func addCards(_ cards: [Card]) {
        for card in cards {
            addCard(card)
        }
    }
    
    func removeCard(_ card: Card) -> Bool {
        guard let index = playerHand.firstIndex(of: card) else {
            return false
        }
        
        playerHand.remove(at: index)
        card.removeFromParent()
        return true
    }
    
    func removeCards(_ cards: [Card]) {
        for card in cards {
            _ = removeCard(card)
        }
    }
    
    func emptyHand() {
        playerHand.removeAll()
    }
    
    // MARK: - Card Analysis
    func findCardsInHand(value: Value) -> IndexSet {
        var indices = IndexSet()
        
        for (index, card) in playerHand.enumerated() {
            if card.value == value || (isWacky && card.value == .Joker) {
                indices.insert(index)
            }
        }
        
        return indices
    }
    
    func findCardsInHand(suit: Suit) -> IndexSet {
        var indices = IndexSet()
        
        for (index, card) in playerHand.enumerated() {
            if card.suit == suit {
                indices.insert(index)
            }
        }
        
        return indices
    }
    
    func getCardCount(for value: Value) -> Int {
        return findCardsInHand(value: value).count
    }
    
    func getCardCount(for suit: Suit) -> Int {
        return findCardsInHand(suit: suit).count
    }
    
    func hasMatchingCards(for value: Value) -> Bool {
        return !findCardsInHand(value: value).isEmpty
    }
    
    // MARK: - Strategic Card Selection
    func findRandomCards(count: Int, excluding: IndexSet = IndexSet()) -> IndexSet {
        var selected = IndexSet()
        let maxCards = isWacky ? 6 : 4
        let availableCount = maxCards - excluding.count
        let targetCount = min(count, availableCount, playerHand.count)
        
        guard targetCount > 0 else { return selected }
        
        var attempts = 0
        let maxAttempts = targetCount * 3
        
        while selected.count < targetCount && attempts < maxAttempts {
            let randomIndex = Int.random(in: 0..<playerHand.count)
            
            if !excluding.contains(randomIndex) && !selected.contains(randomIndex) {
                selected.insert(randomIndex)
            }
            
            attempts += 1
        }
        
        return selected
    }
    
    func findStrategicCards(for value: Value, maxCount: Int = 4) -> IndexSet {
        let matchingCards = findCardsInHand(value: value)
        let matchingCount = matchingCards.count
        
        if matchingCount >= maxCount {
            // We have enough matching cards, no need to bluff
            return matchingCards
        }
        
        let remainingSlots = maxCount - matchingCount
        let randomCards = findRandomCards(count: remainingSlots, excluding: matchingCards)
        
        return matchingCards.union(randomCards)
    }
    
    // MARK: - Gameplay Actions
    func playHand(currValue: Value) -> [Card] {
        let cardsToPlay = findStrategicCards(for: currValue)
        var playedCards: [Card] = []
        
        // Sort indices in descending order to avoid index shifting issues
        for index in cardsToPlay.sorted(by: >) {
            if index < playerHand.count {
                playedCards.append(playerHand[index])
            }
        }
        
        // Remove played cards from hand
        removeCards(playedCards)
        
        return playedCards
    }
    
    func playHandWithBluffing(currValue: Value, maxCards: Int = 4) -> [Card] {
        let matchingCards = findCardsInHand(value: currValue)
        var cardsToPlay: [Card] = []
        
        // Always play matching cards if available
        if !matchingCards.isEmpty {
            for index in matchingCards.sorted(by: >) {
                if index < playerHand.count {
                    cardsToPlay.append(playerHand[index])
                }
            }
            removeCards(cardsToPlay)
        }
        
        // Decide whether to bluff
        if shouldBluff(currValue: currValue, matchingCards: matchingCards.count, maxCards: maxCards) {
            let bluffCount = maxCards - cardsToPlay.count
            let bluffCards = findRandomCards(count: bluffCount)
            
            for index in bluffCards.sorted(by: >) {
                if index < playerHand.count {
                    cardsToPlay.append(playerHand[index])
                }
            }
            
            // Remove bluff cards
            for index in bluffCards.sorted(by: >) {
                if index < playerHand.count {
                    playerHand.remove(at: index)
                }
            }
        }
        
        return cardsToPlay
    }
    
    // MARK: - AI Decision Making
    func shouldCallDoubt(lastValue: Value, numCardsPlayed: Int, lastPlayerCount: Int) -> Bool {
        // Always call doubt if total cards exceed 4 (impossible scenario)
        let haveCards = findCardsInHand(value: lastValue)
        let totalCardsInPlay = haveCards.count + numCardsPlayed
        
        if totalCardsInPlay > 4 {
            return true
        }
        
        // Strategic doubt calling based on AI behavior
        let doubtProbability = calculateDoubtProbability(
            lastValue: lastValue,
            numCardsPlayed: numCardsPlayed,
            lastPlayerCount: lastPlayerCount
        )
        
        let randomValue = Int.random(in: 1...100)
        return randomValue <= doubtProbability
    }
    
    private func calculateDoubtProbability(lastValue: Value, numCardsPlayed: Int, lastPlayerCount: Int) -> Int {
        let baseProbability = aiBehavior.doubtAggressiveness
        
        // Adjust based on game state
        var adjustedProbability = baseProbability
        
        // More likely to call doubt if we have many matching cards
        let haveCards = findCardsInHand(value: lastValue)
        if haveCards.count > 2 {
            adjustedProbability += 20
        }
        
        // More likely to call doubt if opponent played many cards
        if numCardsPlayed > 2 {
            adjustedProbability += 15
        }
        
        // More likely to call doubt in wacky mode
        if isWacky {
            adjustedProbability += 25
        }
        
        // Cap probability at 95%
        return min(adjustedProbability, 95)
    }
    
    private func shouldBluff(currValue: Value, matchingCards: Int, maxCards: Int) -> Bool {
        // Don't bluff if we have matching cards
        if matchingCards > 0 {
            return false
        }
        
        // Don't bluff if we're close to winning
        if playerHand.count <= 2 {
            return false
        }
        
        // Calculate bluffing probability based on AI behavior
        let bluffProbability = aiBehavior.bluffProbability
        
        // Adjust based on game state
        var adjustedProbability = bluffProbability
        
        // Less likely to bluff if opponent played many cards
        if maxCards > 3 {
            adjustedProbability -= 20
        }
        
        // More likely to bluff in wacky mode
        if isWacky {
            adjustedProbability += 15
        }
        
        let randomValue = Int.random(in: 1...100)
        return randomValue <= adjustedProbability
    }
    
    // MARK: - Legacy Support
    func callDoubt(lastValue: Value, numCardsPlayed: Int, lastPlayerCount: Int) {
        let haveCards = findCardsInHand(value: lastValue)
        var willCallDoubt = false
        
        if isWacky {
            willCallDoubt = (haveCards.count + numCardsPlayed > 4)
        } else if numCardsPlayed + lastPlayerCount >= 13 {
            willCallDoubt = true
        }
        
        if willCallDoubt {
            print("\(name ?? "Player") called Doubt")
        }
    }
    
    // MARK: - Utility Methods
    func getRandomCard() -> Card? {
        return playerHand.randomElement()
    }
    
    func getCards(at indices: IndexSet) -> [Card] {
        var cards: [Card] = []
        
        for index in indices.sorted() {
            if index < playerHand.count {
                cards.append(playerHand[index])
            }
        }
        
        return cards
    }
    
    func shuffleHand() {
        playerHand.shuffle()
    }
    
    // MARK: - Debug Information
    func printHandInfo() {
        print("\(name ?? "Player") has \(playerHand.count) cards:")
        
        for card in playerHand {
            print("  - \(card.cardName)")
        }
    }
}

//// MARK: - Extensions
//extension Player: Equatable {
//    static func == (lhs: Player, rhs: Player) -> Bool {
//        return lhs.name == rhs.name
//    }
//}
