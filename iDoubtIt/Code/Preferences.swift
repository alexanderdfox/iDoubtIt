//
//  Preferences.swift
//  iDoubtIt
//
//  Created by Alexander Fox on 10/12/16.
//
//

import Foundation
import SpriteKit

var soundOn = Pref().Sound()
var isWacky = Pref().Wacky()
var difficulty = Pref().LevelDifficulty()
var background = Pref().BackgroundImage()
var cardCover = Pref().CardCover()
let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let prefs = UserDefaults.standard

struct Pref {
    
    func Sound() -> Bool {
        if (prefs.object(forKey: "Sound") == nil) {
            prefs.set(true, forKey: "Sound")
        }
        let soundOn = prefs.bool(forKey: "Sound")
        return soundOn
    }
    
    func Wacky() -> Bool {
        if (prefs.object(forKey: "Wacky") == nil) {
            prefs.set(false, forKey: "Wacky")
        }
        let isWacky = prefs.bool(forKey: "Wacky")
        return isWacky
    }

    func LevelDifficulty() -> Int {
        if (prefs.object(forKey: "Difficulty") == nil) {
            prefs.set(Difficulty.easy.rawValue, forKey: "Difficulty")
        }
        let difficulty = prefs.integer(forKey: "Difficulty")
        return difficulty
    }
    
    func BackgroundImage() -> String {
        if (prefs.object(forKey: "Background") == nil) {
            prefs.setValue(Background.bg_blue.rawValue, forKey: "Background")
        }
        let background = prefs.string(forKey: "Background")!
        return background
    }
    
    func CardCover() -> String {
        if (prefs.object(forKey: "CardCover") == nil) {
            prefs.setValue(cardBack.cardBack_blue4.rawValue, forKey: "CardCover")
        }
        let cardCover = prefs.string(forKey: "CardCover")!
        return cardCover
    }
    
    func updateVars() {
        soundOn = Sound()
        isWacky = Wacky()
        difficulty = LevelDifficulty()
        background = BackgroundImage()
        cardCover = CardCover()
    }
    
}
