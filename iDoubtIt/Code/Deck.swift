//
//  Deck.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

class Deck {
    
    var gameDeck = [Card]()
    
    init(wacky: Bool) {
        var card :Card
        let facedUp = false
        if !wacky {
            for s in Suit.allValues {
                for value in Value.allValues {
                    if (s != .NoSuit && value != .Joker) {
                        card = Card(suit: s, value: value, faceUp: facedUp)
                        gameDeck.append(card)
                    }
                }
            }
        }
        else {
            for s in Suit.allValues {
                for value in Value.allValues {
                    if (s != .NoSuit && value != .Joker) {
                        card = Card(suit: s, value: value, faceUp: facedUp)
                        gameDeck.append(card)
                    } else if (s == .NoSuit && value != .Joker) {
                        card = Card(suit: s, value: .Joker, faceUp: facedUp)
                        gameDeck.append(card)
                    }
                }
            }
        }
    }
    
    func randShuffle() {
        
        var shuffeled = [Card]()
        let originalDeckSize = gameDeck.count

        while shuffeled.count < originalDeckSize {
            let r = Int(arc4random_uniform(UInt32(gameDeck.count)))
            shuffeled.append(gameDeck[r])
            gameDeck.remove(at: r)
        }
        gameDeck.removeAll()
        gameDeck = shuffeled
    }
    
    func naturalShuffle() {
        let halfd = gameDeck.count / 2
        var halfDeck = [Card]()
        var shuffeled = [Card]()
        for _ in 0..<halfd {
            halfDeck.append(gameDeck[0])
            gameDeck.remove(at: 0)
        }
        for _ in 0..<halfd {
            shuffeled.append(halfDeck[0])
            halfDeck.remove(at: 0)
            shuffeled.append(gameDeck[0])
            gameDeck.remove(at: 0)
        }
        gameDeck.removeAll()
        gameDeck = shuffeled
    }

}
