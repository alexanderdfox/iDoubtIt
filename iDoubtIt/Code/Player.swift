//
//  Player.swift
//  iDoubtIt
//
//  Updated 2025
//

import Foundation
import SpriteKit

// MARK: - Difficulty levels for AI players
enum Difficulty: Int {
    case easy = 60
    case medium = 35
    case hard = 15
    
    static let allValues = [easy, medium, hard]
}

// MARK: - Probabilities for AI bluffing when no cards match
struct NoCardsBluff {
    let easy: (Int, Int) = (60, 30)
    let medium: (Int, Int) = (60, 10)
    let hard: (Int, Int) = (20, 20)
}

// MARK: - Probabilities for AI calling doubt
struct DetermineBluff {
    let easy: (Int, Int, Int) = (82, 67, 25)
    let medium: (Int, Int, Int) = (67, 45, 10)
    let hard: (Int, Int, Int) = (50, 25, 4)
}

// MARK: - Player class
class Player: SKSpriteNode {
    
    // MARK: - Properties
    var playerHand = [Card]()
    var playThisMany: Float
    var isHuman: Bool
    var difficulty: Int
    var isWacky: Bool
    
    // MARK: - Required initializer
    required init?(coder aDecoder: NSCoder) {
        // Initialize all stored properties first
        self.isHuman = true
        self.isWacky = false
        self.playThisMany = Float(NoCardsBluff().medium.0)
        self.difficulty = Difficulty.medium.rawValue
        
        super.init(coder: aDecoder)
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.zPosition = 10
    }

    // MARK: - Designated initializer
    init(human: Bool, playerName: String, level: Difficulty? = nil) {
        
        self.isHuman = human
        self.isWacky = false
        
        // Compute AI defaults
        let finalPlayThisMany: Float
        let finalDifficulty: Int
        
        if !human, let level = level {
            switch level {
            case .easy:
                finalPlayThisMany = Float(NoCardsBluff().easy.0)
                finalDifficulty = level.rawValue
            case .medium:
                finalPlayThisMany = Float(NoCardsBluff().medium.0)
                finalDifficulty = level.rawValue
            case .hard:
                finalPlayThisMany = Float(NoCardsBluff().hard.0)
                finalDifficulty = level.rawValue
            }
        } else {
            finalPlayThisMany = Float(NoCardsBluff().medium.0)
            finalDifficulty = Difficulty.medium.rawValue
        }
        
        self.playThisMany = finalPlayThisMany
        self.difficulty = finalDifficulty
        
        // Call SKSpriteNode initializer
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
        for card in cards { addCard(card) }
    }
    
    func hasCards() -> Bool {
        return !playerHand.isEmpty
    }
    
    func emptyHand() {
        guard !playerHand.isEmpty else { return }
        playerHand.removeAll()
    }
    
    // MARK: - Card Selection Helpers
    func findCardsInHand(value: Value) -> IndexSet {
        var indices = IndexSet()
        for (index, card) in playerHand.enumerated() {
            if card.value == value || isWacky {
                indices.insert(index)
            }
        }
        return indices
    }
    
    func findRandomCards(thisMany: Int, alreadySelected: IndexSet) -> IndexSet {
        var selected = IndexSet()
        let maxCards = isWacky ? 6 : 4
        let howMany = min(thisMany, maxCards - alreadySelected.count)
        guard howMany > 0 else { return selected }
        
        while selected.count < howMany {
            let randomIndex = Int.random(in: 0..<playerHand.count)
            if !alreadySelected.contains(randomIndex) && !selected.contains(randomIndex) {
                selected.insert(randomIndex)
            }
        }
        return selected
    }
    
    // MARK: - Gameplay
    func playHand(currValue: Value) -> [Card] {
        let matching = findCardsInHand(value: currValue)
        let randomCards = findRandomCards(thisMany: 4, alreadySelected: matching)
        let toPlayIndices = matching.union(randomCards).sorted(by: >)
        
        var playedCards = [Card]()
        for index in toPlayIndices {
            playedCards.append(playerHand[index])
        }
        // Remove played cards safely
        for index in toPlayIndices.sorted(by: >) {
            playerHand.remove(at: index)
        }
        
        return playedCards
    }
    
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
}
