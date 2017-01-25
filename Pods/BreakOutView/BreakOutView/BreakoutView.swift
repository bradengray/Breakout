//
//  BreakoutView.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit
import CoreMotion

public protocol BreakoutViewDelegate {
    func ballBelowPaddle()
    func viewTapped()
    func removedBrick(brick: Brick)
    func resetView()
}

public class BreakoutView: UIView, BreakoutBehaviourCollisionDelegate {
    
    //MARK: - Public
    
    public var delegate: BreakoutViewDelegate?
    public var bricksPerRow = 10 { didSet { if oldValue != bricksPerRow { resetView() } } }
    public var numberOfBrickRows = 5 { didSet { if oldValue != numberOfBrickRows { resetView() } } }
    public var brickSpacing = 5
    public var specialBricks = false { didSet { if oldValue != specialBricks { resetView() } } }
    public var ballSpeed: CGFloat = 1.0 { didSet { ballBreakoutBehavior.ballSpeed = ballSpeed } }
    public var brickColor: UIColor = .orange { didSet { changebrickColors() } }
    
    public var animating: Bool = false {
        didSet {
            if animating {
                primaryAnimator.addBehavior(ballBreakoutBehavior)
            } else {
                ballDirection = ballBreakoutBehavior.getDirectionFor(item: ball)
                primaryAnimator.removeBehavior(ballBreakoutBehavior)
            }
        }
    }
    
    public func restartBall() {
        ballBreakoutBehavior.push(item: ball, direction: ballDirection)
    }
    
    public var realGravity: Bool = false {
        didSet {
            updateRealGravity()
        }
    }
    
    public var rotationWithoutTransition = false
    
    public var secondariesAnimating: Bool = false {
        didSet {
            if secondariesAnimating {
                secondaryAnimator.addBehavior(brickBreakoutBehavior)
                updateRealGravity()
            } else {
                secondaryAnimator.removeBehavior(brickBreakoutBehavior)
            }
        }
    }
    
    public func movePaddle(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case.changed, .ended:
            UIView.animate(
                withDuration: Animations.PaddleAnimationDuration,
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
    
    public func tap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if !animating {
                if delegate != nil {
                    delegate?.viewTapped()
                }
            } else {
                ballBreakoutBehavior.push(item: ball, direction: CGPoint())
            }
        default:
            break
        }
    }
    
    public func resetView() {
        for brick in babyBricks {
            brick.removeFromSuperview()
            brickBreakoutBehavior.removeAllItems()
        }
        brickBreakoutBehavior.removeAllItems()
        babyBricks.removeAll()
        addBricks()
        updateSubviews()
        delegate?.resetView()
    }
    
    //MARK: - Properties
    
    private var bricks: [String: Brick] = [:]
    
    private var paddle = UIView()
    
    private var ball = BallView()
    
    private var ballDirection = CGPoint()
    
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
    
    private lazy var primaryAnimator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        return animator
    }()
    
    private lazy var secondaryAnimator: UIDynamicAnimator = {
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
        static let BallToPaddleDistance: CGFloat = 50.0
    }
    
    private var maxViewHeight: CGFloat {
        return min(bounds.size.height, bounds.size.width) * Constants.HeightToViewRatio
    }
    
    //MARK: - UI
    
    public func updateSubviews() {
        for (_, brick) in bricks {
            brick.frame = CGRect(origin: brickOrigin(column: brick.tag % bricksPerRow, row: (brick.tag / bricksPerRow) % numberOfBrickRows), size: brickSize)
            addBrickAsBarrier(brick: brick, to: ballBreakoutBehavior)
            addBrickAsBarrier(brick: brick, to: brickBreakoutBehavior)
        }
        
        for babyBrick in babyBricks {
            let origin = babyBrickOrigin(babyBrick: babyBrick)
            babyBrick.frame = CGRect(origin: CGPoint(x: origin.x, y: origin.y), size: babyBrickSize)
            secondaryAnimator.updateItem(usingCurrentState: babyBrick)
        }
        
        paddle.frame = CGRect(origin: paddleOrigin, size: paddleSize)
        addPaddleAsBarrier(paddle: paddle)
        
        ball.frame = CGRect(center: ballOrigin, size: ballSize)
        primaryAnimator.updateItem(usingCurrentState: ball)
    }
    
    //MARK: - Real Gravity
    
    private struct Motion {
        static let accelerometerUpdateInterval = 0.25
    }
    
    private let motionManager = CMMotionManager()
    
    private var lastOrientation: UIDeviceOrientation?
    
    private func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = Motion.accelerometerUpdateInterval
                motionManager.startAccelerometerUpdates(to: .main)
                { [unowned self] (data, error) in
                    if self.brickBreakoutBehavior.dynamicAnimator != nil {
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            let orientation = UIDevice.current.orientation
                            if self.lastOrientation != orientation {
                                self.rotationWithoutTransition = true
                                self.lastOrientation = orientation
                            }
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft:
                                swap(&dx, &dy)
                                dy = -dy
                                if self.rotationWithoutTransition { dx = -dx }
                            default: dx = 0; dy = 0
                            }
                            self.brickBreakoutBehavior.setGravity(direction: CGVector(dx: dx, dy: dy))
                        }
                    } else {
                        self.motionManager.stopAccelerometerUpdates()
                    }
                }
            }
        } else {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    //MARK: - Bricks
    
    private var brickSize: CGSize {
        let width = (bounds.size.width - CGFloat(brickSpacing * (bricksPerRow + 1))) / CGFloat(bricksPerRow)
        let height = max(min(width * CGFloat(Constants.ViewAspectRatio), maxViewHeight), Constants.MinViewHeight)
        return CGSize(width: width, height: height)
    }
    
    private var babyBrickSize: CGSize {
        return CGSize(width: brickSize.height * 1.5, height: brickSize.height)
    }
    
    private func brickOrigin(column: Int, row: Int)-> CGPoint {
        let x = CGFloat(column)*(brickSize.width+CGFloat(brickSpacing))+CGFloat(brickSpacing)
        let y = CGFloat(row)*(brickSize.height+CGFloat(brickSpacing))
        return CGPoint(x: x, y: y)
    }
    
    func babyBrickOrigin(babyBrick: UIView)-> CGPoint {
        let maxD = max(bounds.size.width, bounds.size.height)
        let minD = min(bounds.size.width, bounds.size.height)
        let widthVariable = maxD - minD
        let y = babyBrick.frame.origin.y
        if y > minD, y < maxD {
            let x = bounds.size.width > minD ? babyBrick.frame.origin.x * (maxD/widthVariable) : babyBrick.frame.origin.x
            return CGPoint(x: x, y: bounds.size.height - (maxD - (y+2)))
        } else {
            let x = bounds.size.width < maxD ? babyBrick.frame.origin.x * (widthVariable/maxD) : babyBrick.frame.origin.x
            return CGPoint(x: x, y: bounds.size.height - (minD - (y+2)))
        }
    }
    
    private func addBricks() {
        for (_, brick) in bricks {
            brick.removeFromSuperview()
            removeBrickAsBarrier(brick: brick, from: ballBreakoutBehavior)
            removeBrickAsBarrier(brick: brick, from: brickBreakoutBehavior)
        }
        bricks.removeAll()
        var row = 0
        var count = 0
        while row < numberOfBrickRows {
            var column = 0
            while column < bricksPerRow {
                let brick = Brick()
                if specialBricks {
                    if arc4random() % 2 == 0 {
                        brick.strength = 3
                        brick.special = true
                        brick.backgroundColor = UIColor.darkGray
                    } else {
                        brick.backgroundColor = brickColor
                    }
                } else {
                    brick.backgroundColor = brickColor
                }
                brick.frame = CGRect(origin: brickOrigin(column: column, row: row), size: brickSize)
                brick.tag = count
                
                addSubview(brick)
                bricks["\(count)"] = brick
                addBrickAsBarrier(brick: brick, to: ballBreakoutBehavior)
                addBrickAsBarrier(brick: brick, to: brickBreakoutBehavior)
                column += 1
                count += 1
            }
            row += 1
        }
    }
    
    func changebrickColors() {
        for (_, brick) in bricks {
            if !brick.special {
                brick.backgroundColor = brickColor
            }
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
    
    private func addBrickAsBarrier(brick: UIView, to behavior: BreakoutBehavior) {
        behavior.addBarrier(
            from: brick.frame.upperLeft,
            to: brick.frame.upperRight,
            name: "\(Boundaries.BrickID),\(Boundaries.Top),\(brick.tag)"
        )
        behavior.addBarrier(
            from: brick.frame.upperRight,
            to: brick.frame.lowerRight,
            name: "\(Boundaries.BrickID),\(Boundaries.Right),\(brick.tag)"
        )
        behavior.addBarrier(
            from: brick.frame.lowerRight,
            to: brick.frame.lowerLeft,
            name: "\(Boundaries.BrickID),\(Boundaries.Bottom),\(brick.tag)"
        )
        behavior.addBarrier(
            from: brick.frame.lowerLeft,
            to: brick.frame.upperLeft,
            name: "\(Boundaries.BrickID),\(Boundaries.Left),\(brick.tag)"
        )
    }
    
    private func removeBrickAsBarrier(brick: UIView, from behavior: BreakoutBehavior) {
        behavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Top),\(brick.tag)")
        behavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Right),\(brick.tag)")
        behavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Bottom),\(brick.tag)")
        behavior.removeBarrierFor(id: "\(Boundaries.BrickID),\(Boundaries.Left),\(brick.tag)")
    }
    
    private func removeBrick(brick: Brick) {
        brick.hitDate = Date()
        brick.strength -= 1
        if brick.strength <= 0 {
            let b1 = UIView(frame: CGRect(origin: brick.frame.origin, size: babyBrickSize))
            let b2 = UIView(frame: CGRect(origin: CGPoint(x: brick.frame.origin.x + babyBrickSize.width, y: brick.frame.origin.y), size: babyBrickSize))
            b1.backgroundColor = brickColor
            b2.backgroundColor = brickColor
            addSubview(b1)
            addSubview(b2)
            babyBricks.append(b1)
            babyBricks.append(b2)
                
            brick.removeFromSuperview()
            delegate?.removedBrick(brick: brick)
            removeBrickAsBarrier(brick: brick, from: ballBreakoutBehavior)
            removeBrickAsBarrier(brick: brick, from: brickBreakoutBehavior)
            bricks["\(brick.tag)"] = nil
            
            brickBreakoutBehavior.addItem(item: b1)
            brickBreakoutBehavior.addItem(item: b2)
        } else {
            switch brick.strength {
            case 2:
                brick.backgroundColor = UIColor.cyan
            case 1:
                brick.backgroundColor = UIColor.magenta
            default:
                break
            }
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
    
    private var ballSize: CGSize {
        let radius = min(bounds.size.width, bounds.size.height) * CGFloat(Constants.BallRadiusToViewRatio)
        return CGSize(width: radius, height: radius)
    }
    
    private var ballOrigin: CGPoint {
        return CGPoint(x: bounds.midX, y: paddleOrigin.y - Constants.BallToPaddleDistance)
    }
    
    private func createBall() {
        ball.frame = CGRect(center: ballOrigin, size: ballSize)
        addSubview(ball)
        ball.isOpaque = false
        ballBreakoutBehavior.addItem(item: ball)
    }
    
    //MARK: - View Life Cycle
    
    override public func awakeFromNib() {
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
    
    func collisionBetween(item: UIDynamicItem, boundary identifier: String?) {
        if item as? BallView == ball {
            if let idComponents = identifier?.components(separatedBy: .punctuationCharacters) {
                if let boundaryID = idComponents.first {
                    if boundaryID == Boundaries.BrickID {
                        if let brickID = idComponents.last, let brick = bricks[brickID] {
                            if brick.hitDate != nil {
                                if Date() > Date(timeInterval: TimeInterval(0.1), since: brick.hitDate!) {
                                    removeBrick(brick: brick)
                                }
                            } else {
                                removeBrick(brick: brick)
                            }
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
    
}
