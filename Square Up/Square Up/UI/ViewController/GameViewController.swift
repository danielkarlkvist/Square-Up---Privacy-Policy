//
//  GameViewController.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-11-03.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    @IBOutlet private weak var centeredStackView: UIStackView!
    @IBOutlet private weak var squareUpLabel: UILabel!
    @IBOutlet private weak var highScoreLabel: UILabel!
    @IBOutlet private weak var mainSquareImageView: UIImageView!
    
    @IBOutlet private weak var tapToPlayButton: UIButton!
    
    private var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startScene = StartScene()
        present(scene: startScene)
        
        let highScore = SquareUp.shared.getHighScore()
        highScoreLabel.text = "High score: \(highScore)"
    }
    
    @IBAction func tapToPlayButtonTapped(_ sender: UIButton) {
        if let gameScene = gameScene {
            gameScene.beginNewRound()
        } else {
            let stackViewOrigin = centeredStackView.frame.origin
            gameScene = GameScene(tapToPlayButton: tapToPlayButton, mainSquareOriginPosition: stackViewOrigin)
            present(scene: gameScene!)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self.centeredStackView.alpha = 0
            }) { (animationFinished) in
                if animationFinished {
                    self.centeredStackView.isHidden = true
                }
            }
        }
        
        sender.isHidden = true
        sender.alpha = 0
    }
    
    private func present(scene: SKScene) {
        if let view = self.view as! SKView? {
            scene.size = view.bounds.size
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
        }
    }
}
