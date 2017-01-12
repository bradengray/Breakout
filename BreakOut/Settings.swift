//
//  Settings.swift
//  BreakOut
//
//  Created by Braden Gray on 12/21/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

protocol SettingsDelegate {
    func settingsChanged()
}

struct Settings {
    
    //MARK: - Public
    
    static var shared = Settings()
    
    var delegate: SettingsDelegate?
    
    var specialBricks: SpecialBricks {
        get {
            let value = getDefault(key: Constants.SpecialBricksKey) as? NSNumber.IntegerLiteralType ?? 1
            return SpecialBricks(rawValue: value) ?? .Yes
        }
        set {
            setDefault(value: NSNumber.init(integerLiteral: newValue.rawValue) as AnyObject, key: Constants.SpecialBricksKey)
        }
    }
    
    var ballSpeed: BallSpeed {
        get {
            let value = getDefault(key: Constants.BallSpeedKey) as? NSNumber.IntegerLiteralType ?? 0
            return BallSpeed(rawValue: value) ?? .Slow
        }
        set {
            setDefault(value: NSNumber.init(integerLiteral: newValue.rawValue) as AnyObject, key: Constants.BallSpeedKey)
        }
    }
    
    var bricksPerRow: Int {
        get {
            return getDefault(key: Constants.BricksPerRowKey) as? NSNumber.IntegerLiteralType ?? 2
        }
        set {
            setDefault(value: NSNumber.init(integerLiteral: newValue) as AnyObject, key: Constants.BricksPerRowKey)
        }
    }
    
    var numberOfRows: Int {
        get {
            return getDefault(key: Constants.NumberOfRowsKey) as? NSNumber.IntegerLiteralType ?? 1
        }
        set {
            setDefault(value: NSNumber.init(integerLiteral: newValue) as AnyObject, key: Constants.NumberOfRowsKey)
        }
    }
    
    var brickColor: Item {
        get {
            let value = getDefault(key: Constants.BrickColorKey) as? NSNumber.IntegerLiteralType ?? 0
            return colors[value % colors.count]
        }
        set {
            var index: Int = 0
            if let arrIndex = colors.index(where: { $0.color == newValue.color } ) {
                index = arrIndex.hashValue
            }
            setDefault(value: NSNumber.init(integerLiteral: index) as AnyObject, key: Constants.BrickColorKey)
        }
    }
    
    enum SpecialBricks: Int {
        case No
        case Yes
    }
    
    enum BallSpeed: Int {
        case Slow
        case Medium
        case Fast
    }
    
    enum Item {
        case Brick(UIColor)
        
        var color: (UIColor) {
            switch self {
            case .Brick(let val): return val
            }
        }
    }
    
    let colors: [Item] = [
        .Brick(.green),
        .Brick(.blue),
        .Brick(.orange),
        .Brick(.red),
        .Brick(.purple),
        .Brick(.black),
        .Brick(.brown)
    ]

    //Mark: - Constants

    private struct Constants {
        static let UserDefaultsKey = "User Defaults Key"
        static let SpecialBricksKey = "Special Bricks Key"
        static let BallSpeedKey = "Ball Speed Key"
        static let NumberOfRowsKey = "Number Of Rows Key"
        static let BricksPerRowKey = "Bricks Per Row Key"
        static let BrickColorKey = "Brick Color Key"
    }
    
    //Mark: - User Defaults
    
    private func getDefault(key: String) -> AnyObject? {
        let defaults = UserDefaults.standard
        if let dictionary = defaults.dictionary(forKey: Constants.UserDefaultsKey) {
            if let value = dictionary[key] {
                return value as AnyObject
            }
        }
        return nil
    }
    
    private func setDefault(value: AnyObject, key: String) {
        let defaults = UserDefaults.standard
        var dictionary = defaults.dictionary(forKey: Constants.UserDefaultsKey)
        if dictionary == nil {
            dictionary = [:]
        }
        dictionary?[key] = value
        defaults.setValue(dictionary, forKey: Constants.UserDefaultsKey)
        defaults.synchronize()
        changedSomeSetting()
    }
    
    func changedSomeSetting() {
        delegate?.settingsChanged()
    }
}
