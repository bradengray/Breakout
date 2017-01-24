//
//  BreakoutViewController.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit
import BreakOutView

class BreakoutViewController: UIViewController, BreakoutViewDelegate, SettingsDelegate, UIViewControllerTransitioningDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var gameView: BreakoutView! {
        didSet {
            gameView.delegate = self
            Settings.shared.delegate = self
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(BreakoutView.movePaddle(recognizer:))))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: #selector(BreakoutView.tap(recognizer:))))
            gameView.realGravity = true
            updateUI()
        }
    }
    
    //MARK: - Properties
    
    private var gameStarted: Bool = false
    private lazy var game: BreakoutGame = {
       return BreakoutGame(points: Game.startingPoints, lives: Game.numberOfLives)
    }()
    
    //MARK: - View Controller Life Cycle
    
//    override func viewDidLayoutSubviews() {
//        gameView.updateUI()
//        gameView.animating = false
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gameView.animating = false
        gameView.secondariesAnimating = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = gameStarted
        if gameStarted { gameView.restartBall() }
        gameView.secondariesAnimating = true
    }
    
    //MARK: - UI
    
    private func updateUI() {
        if gameView != nil {
            switch Settings.shared.specialBricks {
                case .Yes: gameView!.specialBricks = true
                case .No: gameView!.specialBricks = false
            }
            
            switch Settings.shared.ballSpeed {
                case .Slow: gameView!.ballSpeed = 0.5
                case .Medium: gameView!.ballSpeed = 1.0
                case .Fast: gameView!.ballSpeed = 1.5
            }
            
            gameView.bricksPerRow = Settings.shared.bricksPerRow
            gameView.numberOfBrickRows = Settings.shared.numberOfRows
            gameView.brickColor = Settings.shared.brickColor.color
            pointsLabel?.text = "\(game.points)"
        }
    }

    //MARK: BreakoutViewDelegate
    
    func ballBelowPaddle() {
        gameView.animating = false
        if game.lives <= 1 {
            alertUserGameEnded()
        } else {
            gameView.updateSubviews()
            game.lives -= 1
        }
    }
    
    func viewTapped() {
        gameView.animating = true
        gameView.restartBall()
        gameStarted = true
    }
    
    func removedBrick(brick: Brick) {
        if brick.special {
            game.points += Game.pointsForSpecialBrick
        } else {
            game.points += Game.pointsForBrick
        }
        updateUI()
    }
    
    func resetView() {
        resetGame()
    }
    
    //MARK: Alerts
    
    private struct Alert {
        static let gameOver = "Game Over"
        static let gameOverMessage = "Try Again."
        static let doneAction = "Done"
    }
    
    private func alertUserGameEnded() {
        let alert = UIAlertController(title: Alert.gameOver, message: Alert.gameOverMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: Alert.doneAction, style: .default) { (done) in
            self.gameView.resetView()
            self.resetGame()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Game
    
    private struct Game {
        static let numberOfLives = 3
        static let pointsForBrick = 1
        static let pointsForSpecialBrick = 15
        static let startingPoints = 0
    }
    
    private func resetGame() {
        gameStarted = false
        self.game.lives = Game.numberOfLives
        self.game.points = Game.startingPoints
        updateUI()
    }
    
    //MARK: - SettingsDelegate
    
    func settingsChanged() {
        updateUI()
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.gameView.updateSubviews()
            self.gameView.animating = false
            self.gameView.rotationWithoutTransition = false
        }) { (context) in
            self.gameStarted = false
        }
    }
}
