import Foundation
import SpriteKit

// MARK: - Card Suits
public enum Suit: String, CaseIterable {
    case Hearts, Spades, Clubs, Diamonds, NoSuit
    
    var isRed: Bool {
        switch self {
        case .Hearts, .Diamonds: return true
        case .Spades, .Clubs: return false
        case .NoSuit: return false
        }
    }
    
    var description: String {
        switch self {
        case .Hearts: return "Hearts"
        case .Spades: return "Spades"
        case .Clubs: return "Clubs"
        case .Diamonds: return "Diamonds"
        case .NoSuit: return "No Suit"
        }
    }
}

// MARK: - Card Values
public enum Value: Int, CaseIterable {
    case Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Joker
    
    var description: String {
        switch self {
        case .Ace: return "Ace"
        case .Two: return "Two"
        case .Three: return "Three"
        case .Four: return "Four"
        case .Five: return "Five"
        case .Six: return "Six"
        case .Seven: return "Seven"
        case .Eight: return "Eight"
        case .Nine: return "Nine"
        case .Ten: return "Ten"
        case .Jack: return "Jack"
        case .Queen: return "Queen"
        case .King: return "King"
        case .Joker: return "Joker"
        }
    }
    
    var isFaceCard: Bool {
        switch self {
        case .Jack, .Queen, .King: return true
        default: return false
        }
    }
}

// MARK: - Card Class
class Card: SKSpriteNode {
    
    // MARK: - Properties
    let suit: Suit
    let value: Value
    var cardName: String
    var facedUp: Bool {
        didSet {
            updateCardDisplay()
        }
    }
    var emojiIcon: String
    
    // MARK: - Private Properties
    private var labelNode: SKLabelNode!
    private var bgNode: SKShapeNode!
    var touchOffset = CGPoint.zero
    
    // MARK: - Constants
    private static let cardSize = CGSize(width: 160, height: 220)
    private static let cornerRadius: CGFloat = 20
    private static let lineWidth: CGFloat = 2
    private static let emojiFontSize: CGFloat = 180
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) { 
        fatalError("NSCoding not supported") 
    }
    
    init(suit: Suit, value: Value, faceUp: Bool) {
        self.suit = suit
        self.value = value
        self.facedUp = faceUp
        self.cardName = Card.generateCardName(suit: suit, value: value)
        self.emojiIcon = Card.getEmoji(for: value, suit: suit)
        
        super.init(texture: nil, color: .clear, size: Card.cardSize)
        
        self.name = cardName
        self.isUserInteractionEnabled = true
        self.zPosition = 100
        
        setupCard()
    }
    
    // MARK: - Setup Methods
    private func setupCard() {
        setupBackground()
        setupLabel()
    }
    
    private func setupBackground() {
        bgNode = SKShapeNode(rectOf: Card.cardSize, cornerRadius: Card.cornerRadius)
        bgNode.fillColor = backgroundColor
        bgNode.strokeColor = .black
        bgNode.lineWidth = Card.lineWidth
        bgNode.zPosition = 0
        bgNode.isUserInteractionEnabled = false
        addChild(bgNode)
    }
    
    private func setupLabel() {
        labelNode = SKLabelNode(text: facedUp ? emojiIcon : "🎴")
        labelNode.fontName = "AppleColorEmoji"
        labelNode.fontSize = Card.emojiFontSize
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1
        labelNode.fontColor = textColor
        addChild(labelNode)
    }
    
    private func updateCardDisplay() {
        labelNode.text = facedUp ? emojiIcon : "🎴"
        labelNode.fontColor = textColor
    }
    
    // MARK: - Computed Properties
    private var backgroundColor: UIColor {
        switch suit {
        case .Hearts, .Diamonds: 
            return UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
        case .Spades, .Clubs:    
            return UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        case .NoSuit:             
            return .yellow
        }
    }
    
    private var textColor: UIColor {
        switch suit {
        case .Hearts, .Diamonds: return .red
        case .Spades, .Clubs:    return .black
        case .NoSuit:             return .yellow
        }
    }
    
    // MARK: - Card Name Generation
    private static func generateCardName(suit: Suit, value: Value) -> String {
        if value == .Joker || suit == .NoSuit {
            return "Joker"
        } else {
            return "\(value.description) of \(suit.description)"
        }
    }
    
    // MARK: - Card Actions
    func flipOver() {
        facedUp.toggle()
        animateFlip()
    }
    
    private func animateFlip() {
        let flipAction = SKAction.sequence([
            SKAction.scaleX(to: 0.0, duration: 0.15),
            SKAction.run { [weak self] in
                self?.updateCardDisplay()
            },
            SKAction.scaleX(to: 1.0, duration: 0.15)
        ])
        run(flipAction)
    }
    
    func highlight() {
        let highlightAction = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        run(highlightAction)
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let parentScene = scene as? PlayScene else { return }
        
        parentScene.pickedCard = self
        let locationInCard = touch.location(in: self)
        touchOffset = CGPoint(x: locationInCard.x, y: locationInCard.y)
        zPosition = 200
        
        startWiggleAnimation()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let parentScene = scene else { return }
        
        let location = touch.location(in: parentScene)
        position = CGPoint(x: location.x - touchOffset.x, y: location.y - touchOffset.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopWiggleAnimation()
        zPosition = 100
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopWiggleAnimation()
        zPosition = 100
    }
    
    // MARK: - Animation Methods
    private func startWiggleAnimation() {
        let wiggle = SKAction.sequence([
            SKAction.rotate(byAngle: 0.05, duration: 0.15),
            SKAction.rotate(byAngle: -0.05, duration: 0.15),
            SKAction.rotate(byAngle: -0.05, duration: 0.15),
            SKAction.rotate(byAngle: 0.05, duration: 0.15)
        ])
        run(SKAction.repeatForever(wiggle), withKey: "wiggle")
    }
    
    private func stopWiggleAnimation() {
        removeAction(forKey: "wiggle")
    }
    
    // MARK: - Utility Methods
    func isMatching(_ otherCard: Card) -> Bool {
        return value == otherCard.value || suit == otherCard.suit
    }
    
    func isSameValue(as otherCard: Card) -> Bool {
        return value == otherCard.value
    }
    
    func isSameSuit(as otherCard: Card) -> Bool {
        return suit == otherCard.suit
    }
    
    // MARK: - Static Methods
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

//// MARK: - Extensions
//extension Card: Equatable {
//    static func == (lhs: Card, rhs: Card) -> Bool {
//        return lhs.suit == rhs.suit && lhs.value == rhs.value
//    }
//}
//
//extension Card: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(suit)
//        hasher.combine(value)
//    }
//}
