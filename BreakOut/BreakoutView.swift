//
//  BreakoutView.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

protocol BreakoutViewDelegate {
    func ballBelowPaddle()
    func viewTapped()
}

class BreakoutView: UIView, BreakoutBehaviourCollisionDelegate {
    
    //MARK: - Public
    
    var delegate: BreakoutViewDelegate?
    var bricksPerRow = 10 { didSet { if oldValue != bricksPerRow { addBricks() } } }
    var numberOfBrickRows = 5 { didSet { if oldValue != numberOfBrickRows { addBricks() } } }
    var brickSpacing = 5
    var paddleDelay = 0.0
    var ballSpeed: CGFloat = 1.0 { didSet { ballBreakoutBehavior.ballSpeed = ballSpeed } }
    var brickColor: UIColor = .orange { didSet { changebrickColors() } }
    
    var animating: Bool = false {
        didSet {
            if animating {
                animator.addBehavior(ballBreakoutBehavior)
                animator.addBehavior(brickBreakoutBehavior)
                ballBreakoutBehavior.push(item: ball)
            } else {
                ballBreakoutBehavior.getDirectionFor(item: ball)
                animator.removeBehavior(ballBreakoutBehavior)
                animator.removeBehavior(brickBreakoutBehavior)
            }
        }
    }
    
    func movePaddle(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case.changed, .ended:
            UIView.animate(
                withDuration: Animations.PaddleAnimationDuration,
                delay: paddleDelay,
                options: [.curveEaseIn],
                animations: {
                    self.paddle.frame.origin = CGPoint(
                        x: max(min(recognizer.location(in: self).x - self.paddleSize.width/2, self.bounds.maxX - self.paddleSize.width), self.bounds.minX),
                        y: self.paddleOrigin.y
                    )
                },
                completion: { (success) in
                    if success  {
                        self.addPaddleAsBarrier(paddle: self.paddle)
                    }
                }
            )
        default:
            break
        }
    }
    
    func tap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if !animating {
                if delegate != nil {
                    delegate?.viewTapped()
                }
            } else {
                ballBreakoutBehavior.push(item: ball)
            }
        default:
            break
        }
    }
    
    func resetView() {
        for brick in babyBricks {
            brick.removeFromSuperview()
        }
        brickBreakoutBehavior.removeAllItems()
        babyBricks.removeAll()
        addBricks()
        updateUI()
    }
    
    //MARK: - Properties
    
    private var bricks: [String: Brick] = [:]
    
    private var paddle = UIView()
    
    private var ball = BallView()
    
    private lazy var ballBreakoutBehavior: BallBreakoutBehavior = {
        let breakoutBehavior = BallBreakoutBehavior()
        breakoutBehavior.delegate = self
        return breakoutBehavior
    }()
    
    private lazy var brickBreakoutBehavior: BrickBreakoutBehavior = {
        let brickBreakoutBehavior = BrickBreakoutBehavior()
        brickBreakoutBehavior.delegate = self
        return brickBreakoutBehavior
    }()
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        return animator
    }()
    
    private var babyBricks: [UIView] = []
    
    //MARK: - Constants
    
    private struct Animations {
        static let PaddleAnimationDuration = 0.1
    }
    
    private struct Constants {
        static let ViewAspectRatio = 0.41
        static let HeightToViewRatio:CGFloat = 0.034
        static let PaddleWidthToViewRatio = 0.20
        static let PaddleYToViewRatio = 0.20
        static let BallRadiusToViewRatio = 0.051
        static let MinViewHeight: CGFloat = 5.0
        
    }
    
    private var maxViewHeight: CGFloat {
        return min(bounds.size.height, bounds.size.width) * Constants.HeightToViewRatio
    }
    
    //MARK: - UI
    
    func updateUI() {
        for (_, brick) in bricks {
            brick.frame = CGRect(origin: brickOrigin(column: brick.tag % bricksPerRow, row: (brick.tag / bricksPerRow) % numberOfBrickRows), size: brickSize)
            addBrickAsBarrier(brick: brick)
        }
        
        let babyOriginY = paddle.frame.maxY
        for babyBrick in babyBricks {
            let babyOriginX = Int(arc4random()) % ((Int(babyBrickSize.width) * (bricksPerRow*2)))
            babyBrick.frame = CGRect(origin: CGPoint(x:CGFloat(babyOriginX), y:babyOriginY), size: babyBrickSize)
            animator.updateItem(usingCurrentState: babyBrick)
        }
        
        paddle.frame = CGRect(origin: paddleOrigin, size: paddleSize)
        addPaddleAsBarrier(paddle: paddle)
        
        ball.frame = CGRect(center: bounds.mid, size: ballSize)
        animator.updateItem(usingCurrentState: ball)
    }
    
    //MARK: - Bricks
    
    private var brickSize: CGSize {
        let width = (bounds.size.width - CGFloat(brickSpacing * (bricksPerRow + 1))) / CGFloat(bricksPerRow)
        let height = max(min(width * CGFloat(Constants.ViewAspectRatio), maxViewHeight), Constants.MinViewHeight)
        return CGSize(width: width, height: height)
    }
    
    private var babyBrickSize: CGSize {
        return CGSize(width: brickSize.width/2, height: brickSize.height)
    }
    
    private func brickOrigin(column: Int, row: Int)-> CGPoint {
        let x = CGFloat(column)*(brickSize.width+CGFloat(brickSpacing))+CGFloat(brickSpacing)
        let y = CGFloat(row)*(brickSize.height+CGFloat(brickSpacing))
        return CGPoint(x: x, y: y)
    }
    
    private func addBricks() {
        for (_, brick) in bricks {
            brick.removeFromSuperview()
            removeBrickAsBarrier(brick: brick)
        }
        bricks.removeAll()
        var row = 0
        var count = 0
        while row < numberOfBrickRows {
            var column = 0
            while column < bricksPerRow {
                let brick = Brick()
                if arc4random() % 2 == 0 {
                    brick.strength = 3
                    brick.backgroundColor = UIColor.darkGray
                } else {
                    brick.backgroundColor = brickColor
                }
                brick.frame = CGRect(origin: brickOrigin(column: column, row: row), size: brickSize)
                brick.tag = count
                
                addSubview(brick)
                bricks["\(count)"] = brick
                addBrickAsBarrier(brick: brick)
                column += 1
                count += 1
            }
            row += 1
        }
    }
    
    func changebrickColors() {
        for (_, brick) in bricks {
            brick.backgroundColor = brickColor
        }
        for babyBrick in babyBricks {
            babyBrick.backgroundColor = brickColor
        }
    }
    
    private struct Boundaries {
        static let BrickID = "Brick"
        static let PaddleID = "Paddle"
        
        static let Top = "Top"
        static let Bottom = "Bottom"
        static let Right = "Right"
        static let Left = "Left"
    }
    
    private func addBrickAsBarrier(brick: UIView) {
        ballBreakoutBehavior.addBarrier(
            from: brick.frame.upperLeft,
            to: brick.frame.upperRight,
            name: "\(Boundaries.BrickID),\(Boundaries.Top),\(brick.tag)"
        )
        ballBreakoutBehavior.addBarrier(
            from: brick.frame.upperRight,
            to: brick.frame.lowerRight,
            name: "\(Boundaries.BrickID),\(Boundaries.Right),\(brick.tag)"
        )
        ballBreakoutBehavior.addBarrier(
            from: brick.frame.lowerRight,
            to: brick.frame.lowerLeft,
            name: "\(Boundaries.BrickID),\(Boundaries.Bottom),\(brick.tag)"
        )
        ballBreakoutBehavior.addBarrier(
            from: brick.frame.lowerLeft,
            to: brick.frame.upperLeft,
            name: "\(Boundaries.BrickID),\(Boundaries.Left),\(brick.tag)"
        )
    }
    
    private func removeBrickAsBarrier(brick: UIView) {
        ballBreakoutBehavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Top),\(brick.tag)")
        ballBreakoutBehavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Right),\(brick.tag)")
        ballBreakoutBehavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Bottom),\(brick.tag)")
        ballBreakoutBehavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Left),\(brick.tag)")
    }
    
    private var lastBrickHit: UIView?
    
    private func removeBrick(id: String) {
        if let brick = bricks[id] {
            if brick.tag != lastBrickHit?.tag {
                brick.strength -= 1
                if brick.strength <= 0 {
                    let b1 = UIView(frame: CGRect(origin: brick.frame.origin, size: babyBrickSize))
                    let b2 = UIView(frame: CGRect(origin: CGPoint(x: brick.frame.origin.x + babyBrickSize.width, y: brick.frame.origin.y), size: babyBrickSize))
                    b1.backgroundColor = brick.backgroundColor
                    b2.backgroundColor = brick.backgroundColor
                    addSubview(b1)
                    addSubview(b2)
                    babyBricks.append(b1)
                    babyBricks.append(b2)
                        
                    brick.removeFromSuperview()
                    self.removeBrickAsBarrier(brick: brick)
                    self.bricks[id] = nil
                    
                    brickBreakoutBehavior.addItem(item: b1)
                    brickBreakoutBehavior.addItem(item: b2)
                } else {
                    switch brick.strength {
                    case 2:
                        brick.backgroundColor = UIColor.gray
                    case 1:
                        brick.backgroundColor = UIColor.red
                    default:
                        break
                    }
                }
            }
            lastBrickHit = brick
        }
    }
    
    //MARK: - Paddle
    
    private var paddleSize: CGSize {
        let width = bounds.size.width * CGFloat(Constants.PaddleWidthToViewRatio)
        let height = max(min(width * CGFloat(Constants.ViewAspectRatio), maxViewHeight ), Constants.MinViewHeight)
        return CGSize(width: width, height: height)
    }
    
    private var paddleOrigin: CGPoint {
        let x = bounds.midX - paddleSize.width/2
        let y = bounds.maxY - bounds.height * CGFloat(Constants.PaddleYToViewRatio)
        return CGPoint(x: x, y: y)
    }
    
    private func addNewPaddle() {
        paddle.frame = CGRect(origin: paddleOrigin, size: paddleSize)
        addSubview(paddle)
        paddle.backgroundColor = UIColor.black
        addPaddleAsBarrier(paddle: paddle)
    }
    
    private func addPaddleAsBarrier(paddle: UIView) {
        ballBreakoutBehavior.addBarrier(
            from: paddle.frame.upperLeft,
            to: paddle.frame.upperRight,
            name: "\(Boundaries.PaddleID),\(Boundaries.Top)"
        )
        ballBreakoutBehavior.addBarrier(
            from: paddle.frame.upperRight,
            to: paddle.frame.lowerRight,
            name: "\(Boundaries.PaddleID),\(Boundaries.Right)"
        )
        ballBreakoutBehavior.addBarrier(
            from: paddle.frame.lowerRight,
            to: paddle.frame.lowerLeft,
            name: "\(Boundaries.PaddleID),\(Boundaries.Bottom)"
        )
        ballBreakoutBehavior.addBarrier(
            from: paddle.frame.lowerLeft,
            to: paddle.frame.upperLeft,
            name: "\(Boundaries.PaddleID),\(Boundaries.Left)"
        )
    }
    
    //MARK: - Ball
    
    var ballSize: CGSize {
        let radius = min(bounds.size.width, bounds.size.height) * CGFloat(Constants.BallRadiusToViewRatio)
        return CGSize(width: radius, height: radius)
    }
    
    private func createBall() {
        ball.frame = CGRect(center: bounds.mid, size: ballSize)
        addSubview(ball)
        ball.isOpaque = false
        ballBreakoutBehavior.addItem(item: ball)
    }
    
    //MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBricks()
        addNewPaddle()
        createBall()
    }
    
    //MARK: - BreakoutBehavior Collision Delegate
    
    private func isBallBelowPaddle() {
        if delegate != nil {
            if ball.frame.origin.y > paddle.frame.origin.y + paddle.frame.size.height {
                delegate?.ballBelowPaddle()
            }
        }
    }
    
    func collisionWithBoundary(identifier: String?) {
        if let idComponents = identifier?.components(separatedBy: .punctuationCharacters) {
            if let boundaryID = idComponents.first {
                if boundaryID == Boundaries.BrickID {
                    if let brickID = idComponents.last {
                        removeBrick(id: brickID)
                    }
                } else {
                    isBallBelowPaddle()
                }
            }
        } else {
            isBallBelowPaddle()
        }
    }
    
}
