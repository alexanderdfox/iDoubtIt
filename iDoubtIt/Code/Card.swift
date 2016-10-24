//
//  Card.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 8/30/16.
//  Copyright © 2016
//

import Foundation
import SpriteKit

enum Suit :String {
  case Hearts,
  Spades,
  Clubs,
  Diamonds,
  NoSuit

    
  static let allValues = [ Hearts,
                           Spades,
                           Clubs,
                           Diamonds,
                           NoSuit ]
}

enum Value :Int {
    case Ace,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Joker
    
    static let allValues = [ Ace,
                             Two,
                             Three,
                             Four,
                             Five,
                             Six,
                             Seven,
                             Eight,
                             Nine,
                             Ten,
                             Jack,
                             Queen,
                             King,
                             Joker ]
}

enum cardBack :String {
    case cardBack_blue1,
    cardBack_blue2,
    cardBack_blue3,
    cardBack_blue4,
    cardBack_blue5,
    cardBack_green1,
    cardBack_green2,
    cardBack_green3,
    cardBack_green4,
    cardBack_green5,
    cardBack_red1,
    cardBack_red2,
    cardBack_red3,
    cardBack_red4,
    cardBack_red5
    
    static let allValues = [cardBack_blue1,
                            cardBack_blue2,
                            cardBack_blue3,
                            cardBack_blue4,
                            cardBack_blue5,
                            cardBack_green1,
                            cardBack_green2,
                            cardBack_green3,
                            cardBack_green4,
                            cardBack_green5,
                            cardBack_red1,
                            cardBack_red2,
                            cardBack_red3,
                            cardBack_red4,
                            cardBack_red5]
}

class Card : SKSpriteNode {
  let suit :Suit
  let frontTexture :SKTexture
  let backTexture :SKTexture
  let value :Value
  var cardName :String
  var facedUp :Bool
  var curTexture :SKTexture
    
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
    init(suit: Suit, value: Value, faceUp: Bool) {
    self.suit = suit
    self.value = value
    if (value != .Joker || suit != .NoSuit) {
        cardName = "\(value)of\(suit)"
    }
    else {
        cardName = String(format: "Joker")
    }
    backTexture = SKTexture(imageNamed: cardCover)
    frontTexture = SKTexture(imageNamed: cardName)
    facedUp = faceUp
    if faceUp {
        curTexture = frontTexture
    } else {
        curTexture = backTexture
    }
    super.init(texture: curTexture, color: .clear, size: curTexture.size())
    name = cardName
  }
  
  func flipOver() {
    if facedUp {
        texture = frontTexture
    } else {
        texture = backTexture
    }
    facedUp = !facedUp
  }
    
  func getIcon() -> String {
    let Cards = ["Ace": ["Hearts": "🂱", "Spades": "🂡", "Clubs": "🃑", "Diamonds": "🃁", "NoSuit": "❗️"],
                "Two": ["Hearts": "🂲", "Spades": "🂢", "Clubs": "🃒", "Diamonds": "🃂", "NoSuit": "❗️"],
                "Three": ["Hearts": "🂳", "Spades": "🂣", "Clubs": "🃓", "Diamonds": "🃃", "NoSuit": "❗️"],
                "Four": ["Hearts": "🂴", "Spades": "🂤", "Clubs": "🃔", "Diamonds": "🃄", "NoSuit": "❗️"],
                "Five": ["Hearts": "🂵", "Spades": "🂥", "Clubs": "🃕", "Diamonds": "🃅", "NoSuit": "❗️"],
                "Six": ["Hearts": "🂶", "Spades": "🂦", "Clubs": "🃖", "Diamonds": "🃆", "NoSuit": "❗️"],
                "Seven": ["Hearts": "🂷", "Spades": "🂧", "Clubs": "🃗", "Diamonds": "🃇", "NoSuit": "❗️"],
                "Eight": ["Hearts": "🂸", "Spades": "🂨", "Clubs": "🃘", "Diamonds": "🃈", "NoSuit": "❗️"],
                "Nine": ["Hearts": "🂹", "Spades": "🂩", "Clubs": "🃙", "Diamonds": "🃉", "NoSuit": "❗️"],
                "Ten": ["Hearts": "🂺", "Spades": "🂪", "Clubs": "🃚", "Diamonds": "🃊", "NoSuit": "❗️"],
                "Jack": ["Hearts": "🂻", "Spades": "🂫", "Clubs": "🃛", "Diamonds": "🃋", "NoSuit": "❗️"],
                "Queen": ["Hearts": "🂽", "Spades": "🂭", "Clubs": "🃝", "Diamonds": "🃍", "NoSuit": "❗️"],
                "King": ["Hearts": "🂾", "Spades": "🂮", "Clubs": "🃞", "Diamonds": "🃎", "NoSuit": "❗️"],
                "Joker": ["Hearts": "🃟", "Spades": "🃟", "Clubs": "🃟", "Diamonds": "🃟", "NoSuit": "❗️"]]
    let icon = Cards["\(value)"]?["\(suit)"]
    return icon!
  }
}
