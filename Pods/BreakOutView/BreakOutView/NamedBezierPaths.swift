//
//  NamedBezierPaths.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class NamedBezierPaths: UIView {
    
    var bezierPaths = [String: UIBezierPath]() { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    var lineWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths {
            color.set()
            path.lineWidth = lineWidth
            path.stroke()
            path.fill()
        }
    }
}
