import Foundation
import SpriteKit
import UIKit  // Needed for UIColor

// MARK: - Screen Constants
let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

// MARK: - Preference Manager (Singleton)
/// Centralized singleton for managing user preferences.
class Pref {
    
    // ✅ Singleton instance
    static let shared = Pref()
    private init() {} // prevent external instantiation
    
    // ✅ UserDefaults instance
    private let prefs = UserDefaults.standard
    
    // MARK: - Stored Preferences
    
    /// Whether sound is enabled (default: true)
    var soundOn: Bool {
        get {
            if prefs.object(forKey: "Sound") == nil { prefs.set(true, forKey: "Sound") }
            return prefs.bool(forKey: "Sound")
        }
        set { prefs.set(newValue, forKey: "Sound") }
    }
    
    /// Whether wacky mode is active (default: false)
    var isWacky: Bool {
        get {
            if prefs.object(forKey: "Wacky") == nil { prefs.set(false, forKey: "Wacky") }
            return prefs.bool(forKey: "Wacky")
        }
        set { prefs.set(newValue, forKey: "Wacky") }
    }
    
    /// Game difficulty (default: `.easy`)
    var difficulty: Int {
        get {
            if prefs.object(forKey: "Difficulty") == nil {
                prefs.set(Difficulty.easy.rawValue, forKey: "Difficulty")
            }
            return prefs.integer(forKey: "Difficulty")
        }
        set { prefs.set(newValue, forKey: "Difficulty") }
    }
    
    /// Background color (default: blue)
    var backgroundColor: UIColor {
        get {
            if let hex = prefs.string(forKey: "BackgroundColor") {
                return UIColor(hex: hex)
            } else {
                let defaultColor = UIColor.systemBlue
                prefs.set(defaultColor.toHexString(), forKey: "BackgroundColor")
                return defaultColor
            }
        }
        set {
            prefs.set(newValue.toHexString(), forKey: "BackgroundColor")
        }
    }
    
    /// Card cover color (default: light gray)
    var cardColor: UIColor {
        get {
            if let hex = prefs.string(forKey: "CardColor") {
                return UIColor(hex: hex)
            } else {
                let defaultColor = UIColor.lightGray
                prefs.set(defaultColor.toHexString(), forKey: "CardColor")
                return defaultColor
            }
        }
        set {
            prefs.set(newValue.toHexString(), forKey: "CardColor")
        }
    }
}

// MARK: - UIColor <-> Hex Conversion
extension UIColor {
    
    /// Initialize UIColor from hex string (e.g., "#RRGGBB")
    convenience init(hex: String) {
        var hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") { hexFormatted.removeFirst() }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let r = CGFloat((rgbValue & 0xFF0000) >> 16)/255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8)/255
        let b = CGFloat(rgbValue & 0x0000FF)/255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// Convert UIColor to hex string
    func toHexString() -> String {
        guard let components = cgColor.components, components.count >= 3 else { return "#FFFFFF" }
        let r = Int(components[0]*255)
        let g = Int(components[1]*255)
        let b = Int(components[2]*255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
