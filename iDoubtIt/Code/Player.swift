//
//  Player.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 9/2/16.
//
//

import SpriteKit

enum Difficulty :Int {
    case Easy = 60,
    Medium = 35,
    Hard = 15
    
    static let allValues = [Easy,
                     Medium,
                     Hard]
}

enum player :Int {
    case HumanPlayer = 0,
    AiPlayerOne = 1,
    AiPlayerTwo = 2,
    AiPlayerThree = 3
}

struct noCardsBluff {
    let Easy = (60, 30)
    let Medium = (60, 10)
    let Hard = (20,20)
}

struct determineBluff {
    let Easy = (82,67,25)
    let Medium = (67, 45,10)
    let Hard = (50,25,4)
}

class Player : SKNode {
    
    var playerHand = NSMutableArray()
    var NoCardsBluff = noCardsBluff.init()
    var playThisMany = Int()
    var isWacky = Bool()
    
    init(isHuman: Bool, playerName: String, level: Difficulty?) {
        if (isHuman) {
            
        }
        else if (!isHuman && level != nil) {
            switch level {
            case .Easy?: playThisMany = NoCardsBluff.Easy.0
            case .Medium?: playThisMany = NoCardsBluff.Medium.0
            case .Hard?: playThisMany = NoCardsBluff.Hard.0
            default: print("‼️")
            }
        }
        super.init()
    }
    
    func addCard(card: Card) {
        playerHand.addObject(card)
    }
    
    func addCards(cards: NSMutableArray) {
        playerHand.addObjectsFromArray(cards as [AnyObject])
    }
    
    func hasCards() -> Bool {
        if (playerHand.count > 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func findCardsInHand(value: Value) -> NSIndexSet {
        let locations = NSMutableIndexSet()
        var indexes = NSIndexSet()
        
        for i in 0 ..< playerHand.count {
            let card = playerHand.objectAtIndex(i) as! Card
            if (isWacky) {
                if (card.value == value) {
                    locations.addIndex(i)
                }
            } else {
                if (card.value == value && locations.count <= 3) {
                    locations.addIndex(i)
                }
            }
        }
        if (locations.count != 0) {
           indexes = NSIndexSet.init(indexSet: locations)
        }
        return indexes
    }
    
    func playHand(value: Value, diff: Difficulty) -> NSMutableArray {
        let matchingCardsInHand = findCardsInHand(value)
//        let randomCads = NSIndexSet()
        if (isWacky && (playerHand.count > matchingCardsInHand.count)) {
            switch diff{
            case .Easy:
                if (abs(Int(arc4random()) % 100) <= Difficulty.Easy.rawValue) {
                    if (matchingCardsInHand.count >= 6) {

                    }
                }
            case .Medium:
                if (abs(Int(arc4random()) % 100) <= Difficulty.Medium.rawValue) {
            
                }
            case .Hard:
                if (abs(Int(arc4random()) % 100) <= Difficulty.Hard.rawValue) {
                    
                }
            }
        }
        return NSMutableArray()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}