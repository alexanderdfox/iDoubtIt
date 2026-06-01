//
//  GameViewController.swift
//  iDoubtIt
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    private var lastLayoutSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GameTheme.backgroundTop
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        if #available(iOS 13.0, *) {
            view.insetsLayoutMarginsFromSafeArea = true
        }
        becomeFirstResponder()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let skView: SKView
        if let existing = view as? SKView {
            skView = existing
        } else {
            skView = SKView(frame: view.bounds)
            skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            skView.ignoresSiblingOrder = true
            view = skView
        }
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let newSize = skView.bounds.size
        guard newSize.width > 1, newSize.height > 1 else { return }

        if skView.scene == nil {
            presentMainMenu(on: skView, size: newSize)
            lastLayoutSize = newSize
            return
        }

        guard abs(newSize.width - lastLayoutSize.width) > 0.5
                || abs(newSize.height - lastLayoutSize.height) > 0.5 else { return }

        lastLayoutSize = newSize
        skView.scene?.size = newSize
        GameLayout.configure(for: newSize)
        (skView.scene as? LayoutResizing)?.layoutForCurrentSize()
    }

    private func presentMainMenu(on skView: SKView, size: CGSize) {
        GameLayout.configure(for: size)
        let scene = MainMenu(size: size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = GameTheme.backgroundTop
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.3))
    }

    override var prefersStatusBarHidden: Bool { true }
    override var canBecomeFirstResponder: Bool { true }
}
