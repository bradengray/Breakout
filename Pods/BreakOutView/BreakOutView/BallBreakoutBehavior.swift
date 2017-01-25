//
//  BallBreakoutBehavior.swift
//  BreakOut
//
//  Created by Braden Gray on 12/20/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class BallBreakoutBehavior: BreakoutBehavior {
    
    //MARK: Public
    
    var ballSpeed: CGFloat = 1.0
    
    override func addItem(item: UIDynamicItem) {
        super.addItem(item: item)
        itemBehavior.addItem(item)
    }
    
    override func removeItem(item: UIDynamicItem) {
        super.removeItem(item: item)
        itemBehavior.removeItem(item)
    }
    
    override func removeAllItems() {
        super.removeAllItems()
        for item in itemBehavior.items {
            itemBehavior.removeItem(item)
        }
    }
        
    func push(item: UIDynamicItem, direction: CGPoint) { //Pass in CGPoint(0,0) for random direction
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        let velocity = itemBehavior.linearVelocity(for: item)
        itemBehavior.addLinearVelocity(CGPoint(x: -velocity.x, y: -velocity.y), for: item)
        if direction != CGPoint() {
            push.pushDirection = CGVector(dx: direction.x, dy: direction.y)
        } else {
           push.angle = randomAngle
        }
        push.magnitude = (item.bounds.size.height/100 * ballSpeedToHeightMultiplier) * ballSpeed
        push.action = { [unowned push] in
            push.removeItem(item)
            push.dynamicAnimator!.removeBehavior(push)
        }
        addChildBehavior(push)
//        pushDirection = nil
    }
    
    func getDirectionFor(item: UIDynamicItem) ->CGPoint {
        return itemBehavior.linearVelocity(for: item)
    }
    
    //MARK: Initialization
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
    }
    
    //MARK: - Constants
    
    private struct Constants {
        static let minimumScreenHeight: CGFloat = 540.0
        static let PIOverFour: CGFloat = CGFloat(M_PI_4)
    }
    
    //MARK: Properties
    
//    private var pushDirection: CGPoint?
    
    private let itemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.allowsRotation = false
        itemBehavior.elasticity = 1.0
        itemBehavior.friction = 0.0
        itemBehavior.resistance = 0.0
        return itemBehavior
    }()
    
    private var ballSpeedToHeightMultiplier: CGFloat {
        if let view = dynamicAnimator?.referenceView {
            let height = max(view.bounds.size.height, view.bounds.size.width)
            let multiplier = height/Constants.minimumScreenHeight
            return multiplier * multiplier
        }
        return 1.0
    }
    
    private var randomAngle: CGFloat {
        let randomAngleVariance = Double(arc4random() % 80) / 100
        var angle = Constants.PIOverFour
        let leftOrRight = arc4random() % 2
        let upOrDown = arc4random() % 2
        if upOrDown == 0 {
            angle = -angle
        }
        if leftOrRight == 0 {
            return angle * CGFloat(3 - randomAngleVariance)
        } else {
            return angle * CGFloat(1 + randomAngleVariance)
        }
    }

}
