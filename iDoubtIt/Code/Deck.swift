//
//  Deck.swift
//  iDoubtIt
//
//  Updated 2025 — Clean, well-structured code with proper error handling
//

import Foundation
import SpriteKit

// MARK: - Deck Errors
enum DeckError: Error, LocalizedError {
    case deckEmpty
    case invalidCardIndex
    case shuffleFailed
    
    var errorDescription: String? {
        switch self {
        case .deckEmpty:
            return "Deck is empty"
        case .invalidCardIndex:
            return "Invalid card index"
        case .shuffleFailed:
            return "Failed to shuffle deck"
        }
    }
}

// MARK: - Deck Class
/// Represents a deck of playing cards with comprehensive error handling
class Deck {
    
    // MARK: - Properties
    private(set) var gameDeck: [Card] = []
    private let isWacky: Bool
    
    // MARK: - Computed Properties
    var cardCount: Int {
        return gameDeck.count
    }
    
    var isEmpty: Bool {
        return gameDeck.isEmpty
    }
    
    var isNotEmpty: Bool {
        return !gameDeck.isEmpty
    }
    
    // MARK: - Initializer
    /// Initializes a deck with standard cards, optionally including "wacky" Jokers
    /// - Parameter wacky: If true, adds Jokers to the deck
    init(wacky: Bool = false) {
        self.isWacky = wacky
        createDeck()
    }
    
    // MARK: - Deck Creation
    private func createDeck() {
        gameDeck.removeAll()
        
        for suit in Suit.allCases {
            for value in Value.allCases {
                if shouldIncludeCard(suit: suit, value: value) {
                    let card = Card(suit: suit, value: value, faceUp: false)
                    gameDeck.append(card)
                }
            }
        }
    }
    
    private func shouldIncludeCard(suit: Suit, value: Value) -> Bool {
        // Standard cards: exclude Jokers and NoSuit
        if suit != .NoSuit && value != .Joker {
            return true
        }
        
        // Wacky cards: Jokers with NoSuit
        if isWacky && suit == .NoSuit && value != .Joker {
            return true
        }
        
        return false
    }
    
    // MARK: - Shuffling Methods
    /// Random shuffle using Swift's built-in `shuffle()`
    func randShuffle() throws {
        guard !gameDeck.isEmpty else {
            throw DeckError.deckEmpty
        }
        
        gameDeck.shuffle()
    }
    
    /// Natural (riffle) shuffle that simulates real-life shuffling
    func naturalShuffle() throws {
        guard gameDeck.count > 1 else {
            throw DeckError.shuffleFailed
        }
        
        let halfIndex = gameDeck.count / 2
        let firstHalf = Array(gameDeck[..<halfIndex])
        let secondHalf = Array(gameDeck[halfIndex...])
        
        var shuffledDeck: [Card] = []
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
    
    /// Performs multiple shuffle operations for better randomization
    func thoroughShuffle() throws {
        try naturalShuffle()
        try randShuffle()
        try naturalShuffle()
    }
    
    // MARK: - Card Operations
    /// Draws the top card from the deck
    /// - Returns: The top `Card` or throws error if deck is empty
    /// - Throws: `DeckError.deckEmpty` if deck is empty
    func drawCard() throws -> Card {
        guard !gameDeck.isEmpty else {
            throw DeckError.deckEmpty
        }
        
        return gameDeck.removeFirst()
    }
    
    /// Draws multiple cards from the deck
    /// - Parameter count: Number of cards to draw
    /// - Returns: Array of drawn cards
    /// - Throws: `DeckError.deckEmpty` if deck doesn't have enough cards
    func drawCards(_ count: Int) throws -> [Card] {
        guard count > 0 else { return [] }
        guard gameDeck.count >= count else {
            throw DeckError.deckEmpty
        }
        
        var drawnCards: [Card] = []
        for _ in 0..<count {
            if let card = try? drawCard() {
                drawnCards.append(card)
            }
        }
        
        return drawnCards
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
    
    /// Adds a card to the top of the deck
    /// - Parameter card: The `Card` to add
    func addCardToTop(_ card: Card) {
        gameDeck.insert(card, at: 0)
    }
    
    // MARK: - Deck Information
    /// Gets a card at a specific index without removing it
    /// - Parameter index: Index of the card to peek at
    /// - Returns: The card at the specified index
    /// - Throws: `DeckError.invalidCardIndex` if index is out of bounds
    func peekCard(at index: Int) throws -> Card {
        guard index >= 0 && index < gameDeck.count else {
            throw DeckError.invalidCardIndex
        }
        
        return gameDeck[index]
    }
    
    /// Gets the top card without removing it
    /// - Returns: The top card or nil if deck is empty
    func peekTopCard() -> Card? {
        return gameDeck.first
    }
    
    /// Gets the bottom card without removing it
    /// - Returns: The bottom card or nil if deck is empty
    func peekBottomCard() -> Card? {
        return gameDeck.last
    }
    
    /// Gets all cards of a specific suit
    /// - Parameter suit: The suit to filter by
    /// - Returns: Array of cards with the specified suit
    func getCards(of suit: Suit) -> [Card] {
        return gameDeck.filter { $0.suit == suit }
    }
    
    /// Gets all cards of a specific value
    /// - Parameter value: The value to filter by
    /// - Returns: Array of cards with the specified value
    func getCards(of value: Value) -> [Card] {
        return gameDeck.filter { $0.value == value }
    }
    
    /// Gets all face cards (Jack, Queen, King)
    /// - Returns: Array of face cards
    func getFaceCards() -> [Card] {
        return gameDeck.filter { $0.value.isFaceCard }
    }
    
    /// Gets all number cards (Ace through Ten)
    /// - Returns: Array of number cards
    func getNumberCards() -> [Card] {
        return gameDeck.filter { !$0.value.isFaceCard && $0.value != .Joker }
    }
    
    // MARK: - Deck Management
    /// Resets the deck to its original state
    func reset() {
        createDeck()
    }
    
    /// Removes all cards from the deck
    func clear() {
        gameDeck.removeAll()
    }
    
    /// Sorts the deck by suit and value
    func sort() {
        gameDeck.sort { card1, card2 in
            if card1.suit == card2.suit {
                return card1.value.rawValue < card2.value.rawValue
            } else {
                return card1.suit.rawValue < card2.suit.rawValue
            }
        }
    }
    
    /// Sorts the deck by value and suit
    func sortByValue() {
        gameDeck.sort { card1, card2 in
            if card1.value == card2.value {
                return card1.suit.rawValue < card2.suit.rawValue
            } else {
                return card1.value.rawValue < card2.value.rawValue
            }
        }
    }
    
    /// Reverses the order of cards in the deck
    func reverse() {
        gameDeck.reverse()
    }
    
    // MARK: - Debug Information
    /// Prints information about the deck
    func printDeckInfo() {
        print("Deck contains \(cardCount) cards")
        print("Is wacky: \(isWacky)")
        print("Is empty: \(isEmpty)")
        
        if !isEmpty {
            print("Top card: \(gameDeck.first?.cardName ?? "Unknown")")
            print("Bottom card: \(gameDeck.last?.cardName ?? "Unknown")")
        }
    }
    
    /// Prints all cards in the deck
    func printAllCards() {
        print("All cards in deck:")
        for (index, card) in gameDeck.enumerated() {
            print("  \(index + 1): \(card.cardName)")
        }
    }
}

// MARK: - Extensions
extension Deck: CustomStringConvertible {
    var description: String {
        return "Deck(\(cardCount) cards, wacky: \(isWacky))"
    }
}
