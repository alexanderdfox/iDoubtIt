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
            for suite in CardType.allValues {
                for value in Value.allValues {
                    if (suite != .NOSUITE && value != .Joker) {
                        card = Card(cardType: suite, value: value)
                        card.position = CGPointMake(screenWidth/2,screenHeight/2)
                        gameDeck.addObject(card)
                    }
                }
            }
        }
        else {
            for suite in CardType.allValues {
                for value in Value.allValues {
                    if (suite != .NOSUITE && value != .Joker) {
                        card = Card(cardType: suite, value: value)
                        card.position = CGPointMake(screenWidth/2,screenHeight/2)
                        gameDeck.addObject(card)
                    } else if (suite == .NOSUITE && value != .Joker) {
                        card = Card(cardType: suite, value: .Joker)
                        card.position = CGPointMake(screenWidth/2,screenHeight/2)
                        gameDeck.addObject(card)
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
            shuffeled.addObject(gameDeck[r])
            gameDeck.removeObjectAtIndex(r)
        }
        gameDeck = shuffeled
    }
    
}