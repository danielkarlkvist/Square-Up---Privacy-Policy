//
//  SquareUp.swift
//  Square Up
//
//  Created by Daniel Karlkvist on 2019-11-10.
//  Copyright © 2019 Daniel Karlkvist. All rights reserved.
//

import Foundation

class SquareUp {
    static var shared = SquareUp()
    
    private var score: Int = 0 {
        didSet {
            if score > highScore {
                highScore = score
                saveHighScore()
            }
            
            notifyScoreObservers()
        }
    }
    private var highScore = 0
    
    private var scoreObservers: [ScoreObserver] = []
    private var rotationObservers: [RotationObserver] = []
    
    private var currentSquareStateIndex: Int?
    private var mainSquareStateIndex = 0
    
    private let userDefaultsHighScoreKey = "highScore"
    
    private var gameIsActive = false
    
    private init() {
        let highScore = getSavedHighScore()
        self.highScore = highScore
        scoreObservers = []
    }
    
    func getRandomSquareStateIndex(inRange range: Range<Int>) -> Int {
        currentSquareStateIndex = Int.random(in: range)
        return currentSquareStateIndex!
    }
    
    func getCurrentSquareStateIndex() -> Int? {
        return currentSquareStateIndex
    }
    
    func getMainSquareStateIndex() -> Int {
        return mainSquareStateIndex
    }
    
    func getScore() -> Int {
        return score
    }
    
    func getHighScore() -> Int {
        return highScore
    }
    
    func getSingleSquareMovingDuration() -> Double {
        return score > 0 ? 5.0 - 1.1 * log(Double(score)) : 5.5
    }
    
    func getGameIsActive() -> Bool {
        return gameIsActive
    }
    
    private func getSavedHighScore() -> Int {
        UserDefaults.standard.integer(forKey: userDefaultsHighScoreKey)
    }
    
    private func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: userDefaultsHighScoreKey)
    }
    
    func activateGame() {
        gameIsActive = true
    }
    
    func deactivateGame() {
        gameIsActive = false
    }
    
    func beginNewRound() {
        gameIsActive = true
        score = 0
    }
    
    func rotateMainSquare() {
        if !gameIsActive {
            return
        }
        
        mainSquareStateIndex += 1
        
        let mainSquareTurned360Degrees = mainSquareStateIndex > 3
        if mainSquareTurned360Degrees {
            mainSquareStateIndex = 0
        }
        
        notifyRotationObservers()
    }
    
    func increaseScore() {
        score += 1
    }
}

// MARK: - Score observable implementation
extension SquareUp: ScoreObservable {
    func addScoreObserver(_ observer: ScoreObserver) {
        scoreObservers.append(observer)
    }
    
    func notifyScoreObservers() {
        for observer in scoreObservers {
            observer.updateScore(to: score)
        }
    }
}

// MARK: - Rotation observable implementation
extension SquareUp: RotationObservable {
    func addRotationObserver(_ observer: RotationObserver) {
        rotationObservers.append(observer)
    }
    
    func notifyRotationObservers() {
        for observer in rotationObservers {
            observer.updateRotation()
        }
    }
}
