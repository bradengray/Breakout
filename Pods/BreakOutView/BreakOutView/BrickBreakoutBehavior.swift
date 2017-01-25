//
//  BrickBreakoutBehavior.swift
//  BreakOut
//
//  Created by Braden Gray on 12/20/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class BrickBreakoutBehavior: BreakoutBehavior {
    
    //MARK: Public
    
    var brickRotationSpeed: CGFloat = 100
    
    override func addItem(item: UIDynamicItem) {
        super.addItem(item: item)
        itemBehavior.addItem(item)
        let direction = arc4random() % 2
        if direction == 0 {
            brickRotationSpeed = -brickRotationSpeed
        }
        itemBehavior.addAngularVelocity(brickRotationSpeed, for: item)
        gravity.addItem(item)
    }
    
    override func removeItem(item: UIDynamicItem) {
        super.removeItem(item: item)
        itemBehavior.removeItem(item)
        gravity.removeItem(item)
    }
    
    override func removeAllItems() {
        super.removeAllItems()
        for item in itemBehavior.items {
            itemBehavior.removeItem(item)
            gravity.removeItem(item)
        }
    }
    
    func setGravity(direction: CGVector) {
        gravity.gravityDirection = direction
    }
    
    //MARK: Initialization
    
    override init() {
        super.init()
        addChildBehavior(itemBehavior)
        addChildBehavior(gravity)
    }
    
    //MARK: Properties
    
    private let gravity = UIGravityBehavior()
    
    private let itemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.elasticity = 0.2
        return itemBehavior
    }()
    
}
