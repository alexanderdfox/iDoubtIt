//
//  Player.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 9/2/16.
//
//

import Foundation
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
    let Easy :(Int,Int) = (60, 30)
    let Medium :(Int,Int) = (60, 10)
    let Hard :(Int,Int) = (20,20)
}

struct determineBluff {
    let Easy :(Int,Int,Int) = (82,67,25)
    let Medium :(Int,Int,Int) = (67, 45,10)
    let Hard :(Int,Int,Int) = (50,25,4)
}

class Player :SKNode {
    
    var playerHand = [Card]()
    var playThisMany :Float
    var isHuman : Bool
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(human: Bool, playerName: String, level: Difficulty?) {
        playThisMany = Float(noCardsBluff().Medium.0)
        isHuman = human
        if (isHuman) {
            
        }
        else if (!isHuman && level != nil) {
            switch level {
            case .easy?: playThisMany = Float(noCardsBluff().Easy.0)
            case .medium?: playThisMany = Float(noCardsBluff().Medium.0)
            case .hard?: playThisMany = Float(noCardsBluff().Hard.0)
            default: print("‼️")
            }
        }
        super.init()
    }
    
    func addCard(card: Card) {
        playerHand.append(card)
    }
    
    func addCards(cards: [Card]) {
        playerHand.append(contentsOf: cards)
    }
    
    func hasCards() -> Bool {
        var hascards :Bool
        if playerHand.count != 0 {
            hascards = true
        }
        else {
            hascards = false
        }
        return hascards
    }
    
    func emptyHand() {
        if playerHand.count != 0 {
            playerHand.removeAll()
        }
        else {
            print("HumanPlayer: not holding any cards")
        }
    }
    
    func findCardsInHand(value: Value) -> IndexSet {
        var locations :IndexSet = IndexSet()
        var card :Card
        var indexes :IndexSet = IndexSet()
        
        for i in 0...playerHand.count {
            card = playerHand[i]
            if isWacky {
                if card.value == value {
                    locations.insert(i)
                }
            }
            else {
                if (card.value == value && locations.count <= 3) {
                    locations.insert(i)
                }
            }
        }
        if locations.count != 0 {
            indexes = locations as IndexSet
        }
        
        return indexes
    }
    
    func findRandomCards(thisMany: Int, alreadySelected: IndexSet) -> IndexSet {
        var randomCards :IndexSet = IndexSet()
        var locations :IndexSet = IndexSet()
        var random :Int = 0
        var hasFound :Int = 0
        var howMany = thisMany
        
        if isWacky {
            if howMany + alreadySelected.count > 6 {
                howMany = 6 - alreadySelected.count
            }
        }
        else {
            if howMany + alreadySelected.count > 4 {
                howMany = 4 - alreadySelected.count
            }
        }
            
        if alreadySelected.count != 0 {
            if howMany <= playerHand.count - alreadySelected.count {
                while hasFound < howMany {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !alreadySelected.contains(random) && locations.contains(random) {
                        locations.insert(random)
                        hasFound += 1
                    }
                }
                randomCards = locations
            }
            else if playerHand.count - alreadySelected.count != 0 {
                while hasFound < playerHand.count {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !locations.contains(random) {
                        locations.insert(random)
                        hasFound += 1
                    }
                }
                randomCards = locations
            }
            else {
                print("Error: AIPlayer can't find any cards to play.")
            }
        }
        else {
            if howMany <= playerHand.count {
                while hasFound < howMany {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !alreadySelected.contains(random) && locations.contains(random) {
                        locations.insert(random)
                        hasFound += 1
                    }
                }
                randomCards = locations
            }
            else if playerHand.count != 0 {
                while hasFound < playerHand.count {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    locations.insert(random)
                    hasFound += 1
                }
            }
        }
        return randomCards
    }
    
//    func playHand(currValue: Value) -> [Card] {
//
//        var matchingCards = findCardsInHand(value: currValue)
//        var cardsToRemove = matchingCards
//        var cardsToPlay = cardsToRemove
//
//        if isHuman {
//            //edit this code
//        }
//        else {
//            //edit this code
//        }
//
//        playerHand.remove(at: <#T##Int#>)???????
//        
//        if cardsToPlay.count == 0 {
//            print("Error: no cards to play")
//        }
//        
//        return cardsToPlay
//    }
    
//    func callDoubt(lastValue :Value, numCardsPlayed: Int, lastPlayerCount :Int ) {
//        var haveCards = findCardsInHand(value: lastValue)
//        var willCallDoubt = false
//        
//        if isWacky {
//            //edit this code
//        }
//        else {
//            //edit this code
//        }
//        
//        if willCallDoubt {
//            print("\(name) called Doubt")
//        }
//        else {
//            print("\(name) did not call Doubt")
//        }
//    }
    
}
