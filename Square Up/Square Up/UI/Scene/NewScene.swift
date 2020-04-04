//
//  NewScene.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-11-06.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import SpriteKit

class StartScene: SKScene {
    private var scoreLabel: SKLabelNode!
    
    var score = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.white
        scoreLabel = SKLabelNode(fontNamed: "Futura-Bold")
        
        // Text
        scoreLabel.text = "New"
        scoreLabel.fontColor = UIColor(red: 220/255, green: 133/255, blue: 128/255, alpha: 1)
        scoreLabel.fontSize = 72
        
        // Position label
        let centerOfScreenWidth = frame.size.width / 2
        let twoThirdsOfScreenHeight = frame.size.height - frame.size.height / 3
        scoreLabel.position = CGPoint(x: centerOfScreenWidth, y: twoThirdsOfScreenHeight)
        
        addChild(scoreLabel)
    }
}
