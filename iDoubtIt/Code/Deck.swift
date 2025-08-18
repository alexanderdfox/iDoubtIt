//
//  Deck.swift
//  iDoubtIt
//
//  Updated 2025 — Refactored for clarity and maintainability
//

import Foundation
import SpriteKit

// MARK: - Deck Class
/// Represents a deck of playing cards
class Deck {
    
    // MARK: - Properties
    
    /// Array holding all cards in the deck
    private(set) var gameDeck = [Card]()
    
    // MARK: - Initializer
    
    /// Initializes a deck with standard cards, optionally including "wacky" Jokers
    /// - Parameter wacky: If true, adds Jokers to the deck
    init(wacky: Bool = false) {
        let facedUp = false
        
        // Loop through all suits and values
        for suit in Suit.allCases {
            for value in Value.allCases {
                
                // Standard cards: exclude Jokers and NoSuit
                if suit != .NoSuit && value != .Joker {
                    let card = Card(suit: suit, value: value, faceUp: facedUp)
                    gameDeck.append(card)
                }
                
                // Wacky cards: Jokers with NoSuit
                else if wacky && suit == .NoSuit && value != .Joker {
                    let card = Card(suit: suit, value: .Joker, faceUp: facedUp)
                    gameDeck.append(card)
                }
            }
        }
    }
    
    // MARK: - Shuffling Methods
    
    /// Random shuffle using Swift's built-in `shuffle()`
    func randShuffle() {
        gameDeck.shuffle()
    }
    
    /// Natural (riffle) shuffle
    /// Interleaves two halves of the deck to simulate a real-life shuffle
    func naturalShuffle() {
        guard gameDeck.count > 1 else { return }
        
        let halfIndex = gameDeck.count / 2
        let firstHalf = Array(gameDeck[..<halfIndex])
        let secondHalf = Array(gameDeck[halfIndex...])
        
        var shuffledDeck = [Card]()
        var i = 0, j = 0
        
        // Interleave cards from both halves
        while i < firstHalf.count || j < secondHalf.count {
            if i < firstHalf.count {
                shuffledDeck.append(firstHalf[i])
                i += 1
            }
            if j < secondHalf.count {
                shuffledDeck.append(secondHalf[j])
                j += 1
            }
        }
        
        gameDeck = shuffledDeck
    }
    
    // MARK: - Deck Operations
    
    /// Draws the top card from the deck
    /// - Returns: The top `Card` or `nil` if deck is empty
    func drawCard() -> Card? {
        guard !gameDeck.isEmpty else { return nil }
        return gameDeck.removeFirst()
    }
    
    /// Checks if the deck is empty
    /// - Returns: True if no cards are left
    func isEmpty() -> Bool {
        return gameDeck.isEmpty
    }
    
    /// Adds a card to the bottom of the deck
    /// - Parameter card: The `Card` to add
    func addCardToBottom(_ card: Card) {
        gameDeck.append(card)
    }
    
    /// Adds multiple cards to the deck
    /// - Parameter cards: Array of `Card`s to add
    func addCards(_ cards: [Card]) {
        gameDeck.append(contentsOf: cards)
    }
}
