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
    private var shadowNode: SKShapeNode!
    private var selectionBorder: SKShapeNode!
    private var cornerTL: SKLabelNode?
    private var cornerBR: SKLabelNode?
    var touchOffset = CGPoint.zero
    
    private var layoutSize: CGSize
    private var layoutCorner: CGFloat
    private let lineWidth: CGFloat = 2
    private var emojiFontSize: CGFloat { layoutSize.height * 0.62 }
    
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
        
        let metrics = GameLayout.current
        self.layoutSize = metrics.cardSize
        self.layoutCorner = metrics.cardCornerRadius
        
        super.init(texture: nil, color: .clear, size: layoutSize)
        
        self.name = cardName
        self.isUserInteractionEnabled = false
        self.zPosition = 100
        
        setupCard()
    }
    
    // MARK: - Setup Methods
    private func setupCard() {
        setupShadow()
        setupBackground()
        setupSelectionBorder()
        setupLabel()
    }
    
    /// Rebuild card chrome after screen size / rotation changes.
    func applyLayoutMetrics(_ metrics: GameLayout.Metrics = GameLayout.current) {
        layoutSize = metrics.cardSize
        layoutCorner = metrics.cardCornerRadius
        self.size = layoutSize
        shadowNode.removeFromParent()
        bgNode.removeFromParent()
        selectionBorder.removeFromParent()
        labelNode.removeFromParent()
        cornerTL?.removeFromParent()
        cornerBR?.removeFromParent()
        setupShadow()
        setupBackground()
        setupSelectionBorder()
        setupLabel()
    }

    private func setupShadow() {
        shadowNode = SKShapeNode(rectOf: layoutSize, cornerRadius: layoutCorner)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.28)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 4, y: -5)
        shadowNode.zPosition = -1
        addChild(shadowNode)
    }
    
    private func setupBackground() {
        bgNode = SKShapeNode(rectOf: layoutSize, cornerRadius: layoutCorner)
        bgNode.fillColor = currentFillColor
        bgNode.strokeColor = .black
        bgNode.lineWidth = lineWidth
        bgNode.zPosition = 0
        bgNode.isUserInteractionEnabled = false
        addChild(bgNode)
        
        let inset = max(6, layoutSize.width * 0.06)
        let inner = SKShapeNode(
            rectOf: CGSize(width: layoutSize.width - inset, height: layoutSize.height - inset),
            cornerRadius: max(4, layoutCorner - 4)
        )
        inner.fillColor = .clear
        inner.strokeColor = UIColor.white.withAlphaComponent(facedUp ? 0.35 : 0.15)
        inner.lineWidth = 1
        inner.zPosition = 0.5
        inner.name = "innerHighlight"
        bgNode.addChild(inner)
    }
    
    private func setupSelectionBorder() {
        let pad = max(6, layoutSize.width * 0.05)
        let borderSize = CGSize(width: layoutSize.width + pad, height: layoutSize.height + pad)
        selectionBorder = SKShapeNode(rectOf: borderSize, cornerRadius: layoutCorner + 2)
        selectionBorder.fillColor = .clear
        selectionBorder.strokeColor = GameTheme.gold
        selectionBorder.lineWidth = 4
        selectionBorder.zPosition = 2
        selectionBorder.isHidden = true
        addChild(selectionBorder)
    }
    
    private func setupLabel() {
        labelNode = SKLabelNode(text: facedUp ? emojiIcon : "🎴")
        labelNode.fontName = GameTheme.emojiFont
        labelNode.fontSize = facedUp ? emojiFontSize : layoutSize.height * 0.5
        labelNode.verticalAlignmentMode = .center
        labelNode.horizontalAlignmentMode = .center
        labelNode.zPosition = 1
        labelNode.fontColor = facedUp ? textColor : .white
        addChild(labelNode)
        updateCornerLabels()
    }
    
    private func updateCardDisplay() {
        labelNode.text = facedUp ? emojiIcon : "🎴"
        labelNode.fontColor = facedUp ? textColor : .white
        labelNode.fontSize = facedUp ? emojiFontSize : layoutSize.height * 0.5
        bgNode.fillColor = currentFillColor
        if let inner = bgNode.childNode(withName: "innerHighlight") as? SKShapeNode {
            inner.strokeColor = UIColor.white.withAlphaComponent(facedUp ? 0.35 : 0.15)
        }
        updateCornerLabels()
    }

    private func updateCornerLabels() {
        cornerTL?.removeFromParent()
        cornerBR?.removeFromParent()
        cornerTL = nil
        cornerBR = nil
        guard facedUp else { return }

        let cornerText: String
        let cornerColor: UIColor
        if value == .Joker {
            cornerText = "JK"
            cornerColor = UIColor(red: 0.35, green: 0.28, blue: 0.05, alpha: 1)
        } else {
            cornerText = GameTheme.rankShort(value) + GameTheme.suitSymbol(suit)
            cornerColor = textColor
        }

        let fontSize = max(14, layoutSize.width * (value == .Ten ? 0.12 : 0.15))
        let halfW = layoutSize.width / 2
        let halfH = layoutSize.height / 2
        let inset = max(8, layoutSize.width * 0.075)

        let tl = SKLabelNode(text: cornerText)
        tl.fontName = GameTheme.titleFont
        tl.fontSize = fontSize
        tl.fontColor = cornerColor
        tl.verticalAlignmentMode = .top
        tl.horizontalAlignmentMode = .left
        tl.position = CGPoint(x: -halfW + inset, y: halfH - inset * 0.85)
        tl.zPosition = 1.5
        addChild(tl)
        cornerTL = tl

        let br = SKLabelNode(text: cornerText)
        br.fontName = GameTheme.titleFont
        br.fontSize = fontSize
        br.fontColor = cornerColor
        br.verticalAlignmentMode = .bottom
        br.horizontalAlignmentMode = .right
        br.position = CGPoint(x: halfW - inset, y: -halfH + inset * 0.85)
        br.zPosition = 1.5
        addChild(br)
        cornerBR = br
    }
    
    // MARK: - Computed Properties
    private var currentFillColor: UIColor {
        if !facedUp { return GameTheme.cardBackFill }
        switch suit {
        case .Hearts, .Diamonds: return GameTheme.cardRedFill
        case .Spades, .Clubs: return GameTheme.cardBlackFill
        case .NoSuit: return GameTheme.cardJokerFill
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
    
    func setSelected(_ selected: Bool) {
        selectionBorder.isHidden = !selected
        if selected {
            run(SKAction.scale(to: 1.08, duration: 0.12))
            zPosition = CardLevel.moving.rawValue
        } else {
            run(SKAction.scale(to: 1.0, duration: 0.1))
            zPosition = CardLevel.board.rawValue
        }
    }
    
    // MARK: - Touch Handling (disabled — PlayScene handles selection)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled,
              let touch = touches.first,
              let parentScene = scene as? PlayScene else { return }
        
        parentScene.pickedCard = self
        let locationInCard = touch.location(in: self)
        touchOffset = CGPoint(x: locationInCard.x, y: locationInCard.y)
        zPosition = 200
        
        startWiggleAnimation()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled,
              let touch = touches.first,
              let parentScene = scene else { return }
        
        let location = touch.location(in: parentScene)
        position = CGPoint(x: location.x - touchOffset.x, y: location.y - touchOffset.y)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
        stopWiggleAnimation()
        zPosition = 100
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
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
