//
//  BreakoutBehavior.swift
//  BreakOut
//
//  Created by Braden Gray on 12/4/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

protocol BreakoutBehaviourCollisionDelegate {
    func collisionBetween(item: UIDynamicItem, boundary identifier: String?)
}

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    //Mark: - Public
    
    func addBarrier(from: CGPoint, to: CGPoint, name: String) {
        collider.removeBoundary(withIdentifier: name as NSCopying)
        collider.addBoundary(withIdentifier: name as NSCopying, from: from, to: to)
    }
    
    func removeBarrierFor(id: String) {
        collider.removeBoundary(withIdentifier: id as NSCopying)
    }
    
    func addItem(item: UIDynamicItem) {
        collider.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem) {
        collider.removeItem(item)
    }
    
    func removeAllItems() {
        for item in collider.items {
            collider.removeItem(item)
        }
    }
    
    //MARK: - Initialization
    
    override init() {
        super.init()
        addChildBehavior(collider)
    }
    
    //MARK: - Properties
    
    var delegate: BreakoutBehaviourCollisionDelegate?
        
    private lazy var collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.collisionDelegate = self
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    //MARK: UICollisionBehaviorDelegate
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if delegate != nil {
            let id = identifier as? String
            delegate?.collisionBetween(item: item, boundary: id)
        }
    }
    
}
