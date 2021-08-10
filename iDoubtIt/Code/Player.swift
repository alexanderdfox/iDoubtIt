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

class Player :SKSpriteNode {
    
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
        let texture = SKTexture(imageNamed: "bg_blue")
        let size = CGSize(width: screenWidth, height: 190)
        super.init(texture: texture, color: .clear, size: size)
        name = playerName
        anchorPoint = CGPoint(x: size.width/2, y: size.height/2)
    }
    
    func addCard(card: Card) {
        playerHand.append(card)
        addChild(card)
    }
    
    func addCards(cards: [Card]) {
        for card in cards {
            addCard(card: card)
        }
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
        var indexes :IndexSet = IndexSet()
        
        for c in 0..<playerHand.count {
            if isWacky {
                if playerHand[c].value == value {
                    locations.insert(c)
                }
            }
            else {
                if (playerHand[c].value == value && locations.count <= 3) {
                    locations.insert(c)
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
        var howMany :Int = thisMany
        
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
            if howMany <= playerHand.count - howMany {
                while hasFound < howMany {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !alreadySelected.contains(random) && !locations.contains(random) {
                        locations.insert(random)
                    }
                    hasFound += 1
                }
                randomCards = locations as IndexSet
            }
            else if playerHand.count - howMany != 0 {
                while hasFound < playerHand.count {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !locations.contains(random) {
                        locations.insert(random)
                    }
                    hasFound += 1
                }
                randomCards = locations as IndexSet
            }
            else {
                print("Error: AIPlayer can't find any cards to play.")
            }
        }
        else {
            if howMany <= playerHand.count {
                while hasFound < howMany {
                    random = abs(Int(arc4random_uniform(UInt32(playerHand.count))))
                    if !alreadySelected.contains(random) && !locations.contains(random) {
                        locations.insert(random)
                    }
                    hasFound += 1
                }
                randomCards = locations as IndexSet
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
    
    func playHand(currValue: Value) -> [Card] {

        let matchingCards :IndexSet = findCardsInHand(value: currValue)
        var randomCards :IndexSet = findRandomCards(thisMany: 4, alreadySelected: matchingCards)
        var cardsToRemove :IndexSet = IndexSet()
        var cardsToPlay = [Card]()

        if !isHuman {
            if ((isWacky && (matchingCards.count > 0)) && playerHand.count > matchingCards.count) {
                switch difficulty {
                case Difficulty.easy.rawValue:
                    if (Int(arc4random_uniform(100)) <= difficulty) {
                        if matchingCards.count >= 6 {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                        else if (cardsToPlay.count < 6 && cardsToPlay.count > 2) {
                            if (Int(arc4random_uniform(100)) <= difficulty) {
                                randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                            }
                            else {
                                randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                            }
                        }
                    }
                    else {
                        if (Int(arc4random_uniform(100)) <= difficulty) {
                            randomCards = findRandomCards(thisMany: 3, alreadySelected: matchingCards)
                        }
                        else if (Int(arc4random_uniform(100)) <= difficulty / 3){
                            randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                        }
                        else {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                    }
                break
                case Difficulty.medium.rawValue:
                    if (Int(arc4random_uniform(100)) <= difficulty) {
                        if matchingCards.count >= 6 {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                        else if (cardsToPlay.count < 6 && cardsToPlay.count > 2) {
                            if (Int(arc4random_uniform(100)) <= difficulty + 10) {
                                randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                            }
                            else {
                                randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                            }
                        }
                    }
                    else {
                        if (Int(arc4random_uniform(100)) <= difficulty) {
                            randomCards = findRandomCards(thisMany: 3, alreadySelected: matchingCards)
                        }
                        else if (Int(arc4random_uniform(100)) <= 50){
                            randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                        }
                        else {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                    }
                break
                case Difficulty.hard.rawValue:
                    if (Int(arc4random_uniform(100)) <= difficulty / 4) {
                        if matchingCards.count >= 6 {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                        else if (cardsToPlay.count < 6 && cardsToPlay.count > 2) {
                            if (Int(arc4random_uniform(100)) <= difficulty) {
                                randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                            }
                            else {
                                randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                            }
                        }
                    }
                    else {
                        if (Int(arc4random_uniform(100)) <= difficulty) {
                            randomCards = findRandomCards(thisMany: 3, alreadySelected: matchingCards)
                        }
                        else if (Int(arc4random_uniform(100)) <= difficulty + 10){
                            randomCards = findRandomCards(thisMany: 2, alreadySelected: matchingCards)
                        }
                        else {
                            randomCards = findRandomCards(thisMany: 1, alreadySelected: matchingCards)
                        }
                    }
                break
                default:
                    print("Error No Default Difficulty!")
                break
                }
            }
        }
        
        print(randomCards)
        for rc in randomCards {
            cardsToRemove.insert(rc)
        }

        print(matchingCards)
        for mc in matchingCards {
            cardsToRemove.insert(mc)
        }
        
        print(cardsToRemove)
        for ctr in cardsToRemove.sorted().reversed() {
            cardsToPlay.append(playerHand[ctr])
            playerHand.remove(at: ctr)
        }
        
        if cardsToPlay.count == 0 {
            print("Error: no cards to play")
        }
        
        return cardsToPlay
    }
    
    func callDoubt(lastValue :Value, numCardsPlayed: Int, lastPlayerCount :Int ) {
        let haveCards = findCardsInHand(value: lastValue)
        var willCallDoubt = false
        
        if isWacky {
            if haveCards.count + numCardsPlayed > 4 {
                if arc4random_uniform(101) < 75 {
                    willCallDoubt = true
                }
            }
            else {
                switch difficulty {
                case Difficulty.easy.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if numCardsPlayed >= 3 {
                            willCallDoubt = true
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Easy.2 + 10 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Easy.0 {
                                willCallDoubt = true
                            }
                            else {
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.1 + 20 {
                                    willCallDoubt = true
                                }
                            }
                        }
                        else {
                            if numCardsPlayed == 4 {
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.2 {
                                    willCallDoubt = true
                                }
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.1 {
                                    willCallDoubt = true
                                }
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.0 {
                                    willCallDoubt = true
                                }
                            }
                        }
                    }
                    break
                case Difficulty.medium.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.2 {
                                willCallDoubt = true
                            }
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 + 10 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 + 20 {
                                willCallDoubt = true
                            }
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.0 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else {
                        if numCardsPlayed == 4 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.2 {
                                willCallDoubt = true
                            }
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 {
                                willCallDoubt = true
                            }
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.0 {
                                willCallDoubt = true
                            }
                        }
                    }
                    break
                case Difficulty.hard.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.1 + 8 {
                            willCallDoubt = true
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if Int(arc4random_uniform(101)) < determineBluff().Easy.1 + 8 {
                            willCallDoubt = true
                        }
                    }
                    else {
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.2 {
                            willCallDoubt = true
                        }
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.1 {
                            willCallDoubt = true
                        }
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.0 {
                            willCallDoubt = true
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        else {
            if haveCards.count + numCardsPlayed > 4 {
                willCallDoubt = true
            }
            else {
                switch difficulty {
                case Difficulty.easy.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if numCardsPlayed >= 3 {
                            willCallDoubt = true
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Easy.2 + 10 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Easy.0 {
                                willCallDoubt = true
                            }
                            else {
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.1 + 20 {
                                    willCallDoubt = true
                                }
                            }
                        }
                        else {
                            if numCardsPlayed == 4 {
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.2 {
                                    willCallDoubt = true
                                }
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.1 {
                                    willCallDoubt = true
                                }
                                if Int(arc4random_uniform(101)) < determineBluff().Easy.0 {
                                    willCallDoubt = true
                                }
                            }
                        }
                    }
                    break
                case Difficulty.medium.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.2 {
                                willCallDoubt = true
                            }
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 + 10 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if numCardsPlayed >= 3 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 + 20 {
                                willCallDoubt = true
                            }
                        }
                        else {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.0 {
                                willCallDoubt = true
                            }
                        }
                    }
                    else {
                        if numCardsPlayed == 4 {
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.2 {
                                willCallDoubt = true
                            }
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.1 {
                                willCallDoubt = true
                            }
                            if Int(arc4random_uniform(101)) < determineBluff().Medium.0 {
                                willCallDoubt = true
                            }
                        }
                    }
                    break
                case Difficulty.hard.rawValue:
                    if numCardsPlayed + lastPlayerCount == 13 {
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.1 + 8 {
                            willCallDoubt = true
                        }
                    }
                    else if lastPlayerCount == 0 {
                        if Int(arc4random_uniform(101)) < determineBluff().Easy.1 + 8 {
                            willCallDoubt = true
                        }
                    }
                    else {
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.2 {
                            willCallDoubt = true
                        }
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.1 {
                            willCallDoubt = true
                        }
                        if Int(arc4random_uniform(101)) < determineBluff().Hard.0 {
                            willCallDoubt = true
                        }
                    }
                    break
                default:
                    break
                }
            }
        }
        
        if willCallDoubt {
            print("\(String(describing: name)) called Doubt")
        }
        else {
            print("\(String(describing: name)) did not call Doubt")
        }
    }
    
}
