//
//  UIKitExtensions.swift
//  DropItSwift
//
//  Created by Braden Gray on 12/2/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

extension CGFloat {
    static func random(max: Int)-> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

extension CGFloat {
    static var random: CGFloat {
        switch arc4random() % 6 {
        case 0: return CGFloat(M_PI)
        case 1: return CGFloat(-M_PI)
        case 2: return CGFloat(M_PI/2)
        case 3: return CGFloat(-M_PI/2)
        case 4: return CGFloat(M_PI/4)
        case 5: return  CGFloat(-M_PI/4)
        default: return CGFloat(M_PI)
        }
    }
}

extension UIColor {
    class var random: UIColor {
        switch arc4random()%7 {
        case 0: return UIColor.green
        case 1: return UIColor.blue
        case 2: return UIColor.orange
        case 3: return UIColor.red
        case 4: return UIColor.purple
        case 5: return UIColor.brown
        case 6: return UIColor.black
        default: return black
        }
    }
}

extension CGRect {
    var mid: CGPoint { return CGPoint(x: midX, y: midY) }
    var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
    var lowerLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
    var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
    var lowerRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
    
    init(center: CGPoint, size: CGSize) {
        let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        self.init(origin: upperLeft, size:size)
    }
}

extension UIView {
    func hitTest(p: CGPoint)-> UIView? {
        return hitTest(p, with: nil)
    }
}

extension UIBezierPath {
    class func line(from: CGPoint, to: CGPoint)-> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}
