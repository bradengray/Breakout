//
//  SettingsTableViewController.swift
//  BreakOut
//
//  Created by Braden Gray on 12/21/16.
//  Copyright © 2016 Graycode. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    //MARK: - Properties 
    
    @IBOutlet weak var paddleDelaySwitch: UISwitch!
    @IBOutlet weak var ballSpeedSegmentControl: UISegmentedControl!
    @IBOutlet weak var bricksPerRowStepper: UIStepper!
    @IBOutlet weak var numberOfRowsStepper: UIStepper!
    @IBOutlet weak var brickColorSlider: UISlider! {
        didSet {
            brickColorSlider.maximumValue = Float(Settings.shared.colors.count - 1)
            brickColorSlider.minimumValue = 0
        }
    }
    @IBOutlet weak var numberOfRowsLabel: UILabel!
    @IBOutlet weak var bricksPerRowLabel: UILabel!
    @IBOutlet weak var brickColorView: UIView!
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch Settings.shared.paddleDelay {
            case .Delayed: paddleDelaySwitch.isOn = true
            case .Responsive: paddleDelaySwitch.isOn = false
        }
        
        switch Settings.shared.ballSpeed {
            case .Slow: ballSpeedSegmentControl.selectedSegmentIndex = 0
            case .Medium: ballSpeedSegmentControl.selectedSegmentIndex = 1
            case.Fast: ballSpeedSegmentControl.selectedSegmentIndex = 2
        }
        
        bricksPerRowStepper.value = Double(min(Int(bricksPerRowStepper.maximumValue), max(Settings.shared.bricksPerRow, Int(bricksPerRowStepper.minimumValue))))
        
        numberOfRowsStepper.value = Double(min(Int(numberOfRowsStepper.maximumValue), max(Settings.shared.numberOfRows, Int(numberOfRowsStepper.minimumValue))))
        
        if let index = Settings.shared.colors.index(where: { $0.color == Settings.shared.brickColor.color } ) {
            brickColorSlider.setValue(Float(index.hashValue), animated: true)
        }
        
        updateUI()
    }
    
    func updateUI() {
        bricksPerRowLabel.text = "\(Int(bricksPerRowStepper.value))"
        numberOfRowsLabel.text = "\(Int(numberOfRowsStepper.value))"
        brickColorView.backgroundColor = Settings.shared.brickColor.color
    }
    
    //MARK: - Constants
    
    private struct Constants {
        static let sliderMax:Float = 6.0
        static let sliderMin:Float = 0.0
    }
    
    //MARK: - Actions
    
    @IBAction func paddleDelaySwitchTouched(_ sender: UISwitch) {
        Settings.shared.paddleDelay = sender.isOn ? .Delayed : .Responsive
    }

    @IBAction func ballSpeedSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: Settings.shared.ballSpeed = .Slow
            case 1: Settings.shared.ballSpeed = .Medium
            case 2: Settings.shared.ballSpeed = .Fast
            default: break
        }
    }

    @IBAction func bricksPerRowStepperChanged(_ sender: UIStepper) {
        Settings.shared.bricksPerRow = Int(sender.value)
        updateUI()
    }
    
    @IBAction func numberOfRowsStepperChanged(_ sender: UIStepper) {
        Settings.shared.numberOfRows = Int(sender.value)
        updateUI()
    }
    
    @IBAction func bricksColorChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        Settings.shared.brickColor = .Brick(Settings.shared.colors[value].color)
        updateUI()
    }
}
