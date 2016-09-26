//
//  SettingsMenu.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import SpriteKit

class Deck : NSObject {
    
    var gameDeck = NSMutableArray()
    
    init(wacky: Bool) {
        var card :Card
        if !wacky {
            for suit in CardType.allValues {
                for value in Value.allValues {
                    if (suit != .NoSuit && value != .Joker) {
                        card = Card(cardType: suit, value: value)
                        card.position = CGPoint(x: screenWidth/2,y: screenHeight/2)
                        gameDeck.add(card)
                    }
                }
            }
        }
        else {
            for suit in CardType.allValues {
                for value in Value.allValues {
                    if (suit != .NoSuit && value != .Joker) {
                        card = Card(cardType: suit, value: value)
                        card.position = CGPoint(x: screenWidth/2,y: screenHeight/2)
                        gameDeck.add(card)
                    } else if (suit == .NoSuit && value != .Joker) {
                        card = Card(cardType: suit, value: .Joker)
                        card.position = CGPoint(x: screenWidth/2,y: screenHeight/2)
                        gameDeck.add(card)
                    }
                }
            }
        }
        super.init()
    }
    
    func randShuffle() {
        
        let shuffeled = NSMutableArray()
        let originalDeckSize = gameDeck.count

        while shuffeled.count < originalDeckSize {
            let r = Int(arc4random() % UInt32(gameDeck.count))
            shuffeled.add(gameDeck[r])
            gameDeck.removeObject(at: r)
        }
        gameDeck = shuffeled
    }
    
}
