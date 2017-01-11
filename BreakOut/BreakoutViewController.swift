//
//  BreakoutViewController.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, BreakoutViewDelegate, SettingsDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet weak var gameView: BreakoutView! {
        didSet {
            gameView.delegate = self
            Settings.shared.delegate = self
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(BreakoutView.movePaddle(recognizer:))))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: #selector(BreakoutView.tap(recognizer:))))
            updateUI()
        }
    }
    
    //MARK: - Properties
    
    private var gameStarted: Bool = false
    private lazy var game: BreakoutGame = {
       return BreakoutGame(points: 0, lives: 3)
    }()
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLayoutSubviews() {
        gameView.updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gameView.animating = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = gameStarted
    }
    
    //MARK: - UI
    
    private func updateUI() {
        if gameView != nil {
            switch Settings.shared.paddleDelay {
                case .Delayed: gameView!.paddleDelay = 0.2
                case .Responsive: gameView!.paddleDelay = 0.0
            }
            
            switch Settings.shared.ballSpeed {
                case .Slow: gameView!.ballSpeed = 0.5
                case .Medium: gameView!.ballSpeed = 1.0
                case .Fast: gameView!.ballSpeed = 1.5
            }
            
            gameView.bricksPerRow = Settings.shared.bricksPerRow
            gameView.numberOfBrickRows = Settings.shared.numberOfRows
            gameView.brickColor = Settings.shared.brickColor.color
        }
    }
    
    //MARK: BreakoutViewDelegate
    
    func ballBelowPaddle() {
        gameView.animating = false
        if game.lives < 1 {
            alertUserGameEnded()
        } else {
            gameView.updateUI()
            game.lives -= 1
        }
    }
    
    func viewTapped() {
        gameView.animating = true
        gameStarted = true
    }
    
    //MARK: Alerts
    
    private struct Alert {
        static let gameOver = "Game Over"
        static let gameOverMessage = "Sorry. Try Again."
        static let doneAction = "Done"
    }
    
    private func alertUserGameEnded() {
        let alert = UIAlertController(title: Alert.gameOver, message: Alert.gameOverMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: Alert.doneAction, style: .default) { (done) in
            self.gameView.resetView()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - SettingsDelegate
    
    func settingsChanged() {
        updateUI()
    }
}
