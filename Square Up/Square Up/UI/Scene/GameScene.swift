//
//  GameScene.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-11-03.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    // Nodes
    private var scoreLabel = SKLabelNode(fontNamed: standardFont)
    private var highScoreLabel = SKLabelNode(fontNamed: standardFont)
    private var tapToRotateLabel = SKLabelNode(fontNamed: standardFont)
    private var mainSquare = SKSpriteNode(imageNamed: "mainSquare")
    private var singleSquare: SKSpriteNode?
    private var tapToPlayButton: UIButton!
    
    private var mainSquareOriginPosition: CGPoint!
    
    private var squareUp = SquareUp.shared
    
    private var previousHighScore: Int!
    
    let squareColors = [
        SquareUpColor.yellow,
        SquareUpColor.purple,
        SquareUpColor.blue,
        SquareUpColor.green
    ]
    
    convenience init(tapToPlayButton: UIButton, mainSquareOriginPosition: CGPoint) {
        self.init()
        
        self.tapToPlayButton = tapToPlayButton
        tapToPlayButton.setTitle("Play again", for: .normal)
        
        self.mainSquareOriginPosition = mainSquareOriginPosition
        
        previousHighScore = squareUp.getHighScore()
        
        squareUp.addScoreObserver(self)
        squareUp.addRotationObserver(self)
    }
    
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    func layoutScene() {
        backgroundColor = UIColor.white
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        setUpScoreLabel()
        setUpTapToRotateLabel()
        setUpMainSquare()
        setUpHighScoreLabel()
        
        let yPosition = frame.size.height / 3
        moveMainSquareTo(yPosition: yPosition, withDuration: 2.0, rotationAngle: .pi * -4) {
            self.squareUp.activateGame()
            self.fadeIn(self.scoreLabel, withDuration: 0.7)
            self.fadeIn(self.tapToRotateLabel, withDuration: 0.7)
            self.spawnSingleSquare()
        }
    }
    
    func moveMainSquareTo(yPosition: CGFloat, withDuration duration: TimeInterval, rotationAngle: CGFloat, completion: (() -> Void)?) {
        let ease = SKActionTimingMode.easeInEaseOut
        
        let moveDown = SKAction.moveTo(y: yPosition, duration: duration)
        moveDown.timingMode = ease
        
        let rotation = SKAction.rotate(byAngle: rotationAngle, duration: duration)
        rotation.timingMode = ease
        
        self.mainSquare.run(rotation)
        self.mainSquare.run(moveDown) {
            if let completion = completion {
                completion()
            }
        }
    }
    
    func setUpScoreLabel() {
        fadeOut(scoreLabel, withDuration: 0)
        
        // Text
        scoreLabel.fontColor = SquareUpColor.red
        scoreLabel.fontSize = 72
        scoreLabel.text = "0"
        
        // Position label
        let centerOfScreenWidth = frame.size.width / 2
        let twoThirdsOfScreenHeight = frame.size.height - frame.size.height / 3
        scoreLabel.position = CGPoint(x: centerOfScreenWidth, y: twoThirdsOfScreenHeight)
        
        addChild(scoreLabel)
    }
    
    func setUpHighScoreLabel() {
        // Text
        highScoreLabel.fontColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.7)
        highScoreLabel.fontSize = 16
        highScoreLabel.text = "High score: \(squareUp.getHighScore())"
        
        // Position label
        let xPosition = mainSquare.position.x + highScoreLabel.frame.size.width / 2 - mainSquare.size.width / 2
        let yPosition = mainSquare.position.y - mainSquare.size.height / 2 + 5
        highScoreLabel.position = CGPoint(x: xPosition, y: yPosition)
        
        fadeOut(highScoreLabel, withDuration: 0)
        
        addChild(highScoreLabel)
    }
    
    func setUpTapToRotateLabel() {
        fadeOut(tapToRotateLabel, withDuration: 0)
        
        // Text
        tapToRotateLabel.fontColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 0.7)
        tapToRotateLabel.fontSize = 14
        tapToRotateLabel.text = "Tap anywhere to rotate"
        
        // Position label
        let centerOfScreenWidth = frame.size.width / 2
        let centerOfScreenHeight = frame.size.height / 2
        tapToRotateLabel.position = CGPoint(x: centerOfScreenWidth, y: centerOfScreenHeight)
        
        addChild(tapToRotateLabel)
    }
    
    func setUpMainSquare() {
        // Size of square
        let mainSquareSize = CGSize(width: 60, height: 60)
        mainSquare.size = mainSquareSize
        
        // Position square
        let xPosition = mainSquareOriginPosition.x + mainSquareSize.width / 2
        let yPosition = mainSquareOriginPosition.y + mainSquareSize.height / 2
        mainSquare.position = CGPoint(x: xPosition, y: yPosition)
        mainSquare.zPosition = ZPosition.mainSquare
        
        // Physics body
        mainSquare.physicsBody = SKPhysicsBody(rectangleOf: mainSquare.size)
        mainSquare.physicsBody?.categoryBitMask = PhysicsCategory.mainSquare
        mainSquare.physicsBody?.isDynamic = false
        
        addChild(mainSquare)
    }
    
    func spawnSingleSquare() {
        singleSquare = SKSpriteNode(imageNamed: "singleSquare")
        
        // Color of square
        let currentSquareColorIndex = squareUp.getRandomSquareStateIndex(inRange: 0..<squareColors.count)
        
        singleSquare!.color = squareColors[currentSquareColorIndex]
        singleSquare!.colorBlendFactor = 1
        
        // Size of square
        let squareSize = CGSize(width: mainSquare.size.width / 2, height: mainSquare.size.height / 2)
        singleSquare!.size = squareSize
        
        // Position square
        let xPosition = frame.width + squareSize.width / 2
        let yPosition = mainSquare.position.y - mainSquare.size.height / 4
        singleSquare!.position = CGPoint(x: xPosition, y: yPosition)
        singleSquare!.zPosition = ZPosition.singleSquare
        
        // Physics body
        singleSquare!.physicsBody = SKPhysicsBody(rectangleOf: singleSquare!.size)
        singleSquare!.physicsBody?.categoryBitMask = PhysicsCategory.singleSquare
        singleSquare!.physicsBody?.contactTestBitMask = PhysicsCategory.mainSquare
        singleSquare!.physicsBody?.collisionBitMask = PhysicsCategory.none   // Do not want the square to collide with mainSquare
        
        addChild(singleSquare!)
        
        moveSingleSquareToMainSquare()
    }
    
    func fadeOutAndRemove(node: SKNode) {
        let fadeOut = SKAction.fadeOut(withDuration: standardDuration)
        node.run(fadeOut) {
            node.removeFromParent()
        }
    }
    
    func transitionScoreLabelTextTo(_ value: String, labelShouldBeGreen: Bool) {
        scoreLabel.text = value
        
        if labelShouldBeGreen {
            scoreLabel.fontColor = SquareUpColor.green
        } else {
            scoreLabel.fontColor = SquareUpColor.red
        }
    }
    
    func fadeIn(_ node: SKNode, withDuration duration: TimeInterval) {
        let fadeIn = SKAction.fadeIn(withDuration: duration)
        node.run(fadeIn)
    }
    
    func fadeOut(_ node: SKNode, withDuration duration: TimeInterval) {
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        node.run(fadeOut)
    }
    
    func beginNewRound() {
        transitionScoreLabelTextTo("0", labelShouldBeGreen: false)
        
        if let singleSquare = singleSquare {
            fadeOutAndRemove(node: singleSquare)
        }
        
        self.fadeOut(highScoreLabel, withDuration: 0.3)
        
        let xPosition = self.mainSquare.position.x + self.highScoreLabel.frame.size.width / 2 - self.mainSquare.size.width / 2
        let move = SKAction.moveTo(x: xPosition, duration: 0.5)
        move.timingMode = SKActionTimingMode.easeInEaseOut
        self.highScoreLabel.run(move) {
            let yPosition = self.frame.size.height / 3
            self.moveMainSquareTo(yPosition: yPosition, withDuration: 1, rotationAngle: .pi * -2) {
                self.squareUp.beginNewRound()
                self.fadeIn(self.tapToRotateLabel, withDuration: 0.5)
                self.spawnSingleSquare()
            }
        }
    }
    
    func moveSingleSquareToMainSquare() {
        if let singleSquare = singleSquare {
            let xPosition = mainSquare.position.x + mainSquare.size.width / 4
            let duration = TimeInterval(squareUp.getSingleSquareMovingDuration())
            let move = SKAction.moveTo(x: xPosition, duration: duration)
            
            singleSquare.run(move) {
                singleSquare.removeFromParent()
            }
        }
    }
    
    func gameOver() {
        fadeOut(tapToRotateLabel, withDuration: standardDuration)
        
        previousHighScore = squareUp.getHighScore()
        
        if let singleSquare = singleSquare {
            singleSquare.physicsBody = nil // physics body has to be removed in order to set the position
            
            let moveNextToMainSquare = SKAction.moveTo(x: mainSquare.position.x + (3/2) * singleSquare.size.width, duration: standardDuration)
            singleSquare.run(moveNextToMainSquare) {
                singleSquare.removeAllActions()
                self.fadeOutAndRemove(node: singleSquare)
            }
        }
        
        squareUp.deactivateGame()
        
        vibrate(withVibrationType: .error)
        
        let yPosition = frame.size.height / 2
        moveMainSquareTo(yPosition: yPosition, withDuration: 1, rotationAngle: .pi * 2) {
            self.fadeIn(self.highScoreLabel, withDuration: 0.3)
            let xPosition = self.mainSquare.position.x + self.highScoreLabel.frame.size.width / 2 + self.mainSquare.size.width / 2 + 5
            let move = SKAction.moveTo(x: xPosition, duration: 0.3)
            move.timingMode = SKActionTimingMode.easeInEaseOut
            self.highScoreLabel.run(move) {
                self.showTapToPlayButton()
            }
        }
    }
    
    func showTapToPlayButton() {
        tapToPlayButton.isHidden = false
        UIView.animate(withDuration: standardDuration, delay: 0, options: .curveLinear, animations: {
            self.tapToPlayButton.alpha = 1
        })
    }
    
    func vibrate(withVibrationType vibrationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(vibrationType)
    }
    
    func touchUp() {
        fadeOut(tapToRotateLabel, withDuration: standardDuration)
        squareUp.rotateMainSquare()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchUp()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchUp()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        let singleSquareHitMainSquare = contactMask == PhysicsCategory.singleSquare | PhysicsCategory.mainSquare
        if singleSquareHitMainSquare {
            singleSquare?.physicsBody?.categoryBitMask = PhysicsCategory.none // Make sure the same single square won't hit the main square twice (or more). A single square can be hit more than once if the main square rotates while touching it
            let currentSquareColorIndex = squareUp.getCurrentSquareStateIndex()
            let currentMainSquareColorIndex = squareUp.getMainSquareStateIndex()
            
            let squareHitCorrectColor = currentSquareColorIndex == currentMainSquareColorIndex
            if squareHitCorrectColor {
                let gameIsActive = squareUp.getGameIsActive()
                if gameIsActive {
                    squareUp.increaseScore()
                    spawnSingleSquare()
                }
            } else {
                gameOver()
            }
        }
    }
}

extension GameScene: ScoreObserver {
    func updateScore(to score: Int) {
        scoreLabel.text = "\(score)"
        
        var didSetNewHighScore = false
        if score > previousHighScore {
            didSetNewHighScore = true
            highScoreLabel.text = "High score: \(score)"
        }
        
        transitionScoreLabelTextTo("\(score)", labelShouldBeGreen: didSetNewHighScore)
    }
}

extension GameScene: RotationObserver {
    func updateRotation() {
        let rotation45Degrees = SKAction.rotate(byAngle: -.pi / 2, duration: 0.25)
        let easeInAndOut = SKActionTimingMode.easeInEaseOut
        rotation45Degrees.timingMode = easeInAndOut
        mainSquare.run(rotation45Degrees)
    }
}
