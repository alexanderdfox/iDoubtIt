//
//  Player.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 9/2/16.
//
//

import SpriteKit

enum Difficulty :Int {
    case easy = 60,
    medium = 35,
    hard = 15
    
    static let allValues = [easy,
                     medium,
                     hard]
}

enum player :Int {
    case humanPlayer = 0,
    aiPlayerOne = 1,
    aiPlayerTwo = 2,
    aiPlayerThree = 3
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
    
    fileprivate var playerHand = NSMutableArray()
    fileprivate var NoCardsBluff = noCardsBluff.init()
    fileprivate var playThisMany = Int()
    
    init(isHuman: Bool, playerName: String, level: Difficulty?) {
        if (isHuman) {
            
        }
        else if (!isHuman && level != nil) {
            switch level {
            case .easy?: playThisMany = NoCardsBluff.Easy.0
            case .medium?: playThisMany = NoCardsBluff.Medium.0
            case .hard?: playThisMany = NoCardsBluff.Hard.0
            default: print("‼️")
            }
        }
        super.init()
    }
    
    func addCard(_ card: Card) {
        playerHand.add(card)
    }
    
    func addCards(_ cards: NSMutableArray) {
        playerHand.addObjects(from: cards as [AnyObject])
    }
    
    func hasCards() -> Bool {
        if (playerHand.count > 0) {
            return true
        }
        else {
            return false
        }
    }
    
    func findCardsInHand(_ value: Value) -> IndexSet {
        let locations = NSMutableIndexSet()
        var indexes = IndexSet()
        
        for i in 0 ..< playerHand.count {
            let card = playerHand.object(at: i) as! Card
            if (isWacky) {
                if (card.value == value) {
                    locations.add(i)
                }
            } else {
                if (card.value == value && locations.count <= 3) {
                    locations.add(i)
                }
            }
        }
        if (locations.count != 0) {
           indexes = IndexSet.init(locations)
        }
        return indexes
    }
    
    func playHand(_ value: Value, diff: Difficulty) -> NSMutableArray {
        let matchingCardsInHand = findCardsInHand(value)
//        let randomCads = NSIndexSet()
        if (isWacky && (playerHand.count > matchingCardsInHand.count)) {
            switch diff{
            case .easy:
                if (abs(Int(arc4random()) % 100) <= Difficulty.easy.rawValue) {
                    if (matchingCardsInHand.count >= 6) {

                    }
                }
            case .medium:
                if (abs(Int(arc4random()) % 100) <= Difficulty.medium.rawValue) {
            
                }
            case .hard:
                if (abs(Int(arc4random()) % 100) <= Difficulty.hard.rawValue) {
                    
                }
            }
        }
        return NSMutableArray()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
