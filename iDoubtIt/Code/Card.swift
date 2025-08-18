import Foundation
import SpriteKit

// MARK: - Card Suits
public enum Suit: String, CaseIterable {
    case Hearts, Spades, Clubs, Diamonds, NoSuit
}

// MARK: - Card Values
public enum Value: Int, CaseIterable {
    case Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Joker
}

class Card: SKSpriteNode {
    
    let suit: Suit
    let value: Value
    var cardName: String
    var facedUp: Bool {
        didSet {
            labelNode.text = facedUp ? emojiIcon : "🎴"
        }
    }
    var emojiIcon: String
    
    private var labelNode: SKLabelNode!
    private var bgNode: SKShapeNode! // background with rounded corners
    var touchOffset = CGPoint.zero

    required init?(coder aDecoder: NSCoder) { fatalError("NSCoding not supported") }

    init(suit: Suit, value: Value, faceUp: Bool) {
        self.suit = suit
        self.value = value
        self.facedUp = faceUp
        self.cardName = (value == .Joker || suit == .NoSuit) ? "Joker" : "\(value) of \(suit)"
        self.emojiIcon = Card.getEmoji(for: value, suit: suit)
        
        let cardSize = CGSize(width: 160, height: 220)
        super.init(texture: nil, color: .clear, size: cardSize)
        self.name = cardName
        self.isUserInteractionEnabled = true
        self.zPosition = 100
        
        // MARK: - Rounded Background
        let bgColor: UIColor
        switch suit {
        case .Hearts, .Diamonds: bgColor = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
        case .Spades, .Clubs:    bgColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        case .NoSuit:             bgColor = .yellow
        }
        
        bgNode = SKShapeNode(rectOf: cardSize, cornerRadius: 20)
        bgNode.fillColor = bgColor
        bgNode.strokeColor = .black
        bgNode.lineWidth = 2
        bgNode.zPosition = 0
        bgNode.isUserInteractionEnabled = false
        addChild(bgNode)
        
        // MARK: - Label
        labelNode = SKLabelNode(text: facedUp ? emojiIcon : "🎴")
        labelNode.fontName = "AppleColorEmoji"
        labelNode.fontSize = 180
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1
        switch suit {
        case .Hearts, .Diamonds: labelNode.fontColor = .red
        case .Spades, .Clubs:    labelNode.fontColor = .black
        case .NoSuit:             labelNode.fontColor = .yellow
        }
        addChild(labelNode)
    }

    // Flip with animation
    func flipOver() {
        facedUp.toggle()
        let flipAction = SKAction.sequence([
            SKAction.scaleX(to: 0.0, duration: 0.15),
            SKAction.run { },
            SKAction.scaleX(to: 1.0, duration: 0.15)
        ])
        run(flipAction)
    }

    // Touch dragging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parentScene = scene as? PlayScene else { return }
        parentScene.pickedCard = self
        let locationInCard = touch.location(in: self)
        touchOffset = CGPoint(x: locationInCard.x, y: locationInCard.y)
        zPosition = 200
        
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 0.15),
            SKAction.rotate(byAngle: -0.05, duration: 0.15),
            SKAction.rotate(byAngle: -0.05, duration: 0.15),
            SKAction.rotate(byAngle: 0.05, duration: 0.15)
        ])
        run(SKAction.repeatForever(wiggle), withKey: "wiggle")
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parentScene = scene else { return }
        let location = touch.location(in: parentScene)
        position = CGPoint(x: location.x - touchOffset.x, y: location.y - touchOffset.y)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAction(forKey: "wiggle")
        zPosition = 100
    }

    // Emoji mapping
    static func getEmoji(for value: Value, suit: Suit) -> String {
        let cards: [Value: [Suit: String]] = [
            .Ace:    [.Hearts: "🂱", .Spades: "🂡", .Clubs: "🃑", .Diamonds: "🃁", .NoSuit: "❗️"],
            .Two:    [.Hearts: "🂲", .Spades: "🂢", .Clubs: "🃒", .Diamonds: "🃂", .NoSuit: "❗️"],
            .Three:  [.Hearts: "🂳", .Spades: "🂣", .Clubs: "🃓", .Diamonds: "🃃", .NoSuit: "❗️"],
            .Four:   [.Hearts: "🂴", .Spades: "🂤", .Clubs: "🃔", .Diamonds: "🃄", .NoSuit: "❗️"],
            .Five:   [.Hearts: "🂵", .Spades: "🂥", .Clubs: "🃕", .Diamonds: "🃅", .NoSuit: "❗️"],
            .Six:    [.Hearts: "🂶", .Spades: "🂦", .Clubs: "🃖", .Diamonds: "🃆", .NoSuit: "❗️"],
            .Seven:  [.Hearts: "🂷", .Spades: "🂧", .Clubs: "🃗", .Diamonds: "🃇", .NoSuit: "❗️"],
            .Eight:  [.Hearts: "🂸", .Spades: "🂨", .Clubs: "🃘", .Diamonds: "🃈", .NoSuit: "❗️"],
            .Nine:   [.Hearts: "🂹", .Spades: "🂩", .Clubs: "🃙", .Diamonds: "🃉", .NoSuit: "❗️"],
            .Ten:    [.Hearts: "🂺", .Spades: "🂪", .Clubs: "🃚", .Diamonds: "🃊", .NoSuit: "❗️"],
            .Jack:   [.Hearts: "🂻", .Spades: "🂫", .Clubs: "🃛", .Diamonds: "🃋", .NoSuit: "❗️"],
            .Queen:  [.Hearts: "🂽", .Spades: "🂭", .Clubs: "🃝", .Diamonds: "🃍", .NoSuit: "❗️"],
            .King:   [.Hearts: "🂾", .Spades: "🂮", .Clubs: "🃞", .Diamonds: "🃎", .NoSuit: "❗️"],
            .Joker:  [.Hearts: "🃟", .Spades: "🃟", .Clubs: "🃟", .Diamonds: "🃟", .NoSuit: "❗️"]
        ]
        return cards[value]?[suit] ?? "❓"
    }
}
