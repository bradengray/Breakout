//
//  BallView.swift
//  BreakOut
//
//  Created by Braden Gray on 12/3/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class BallView: NamedBezierPaths {
    
    private struct PathNames {
        static let BallPathName = "Ball Path Name"
    }
    
    override func layoutSubviews() {
        let ball = UIBezierPath(ovalIn: bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2))
        bezierPaths[PathNames.BallPathName] = ball
    }
}
