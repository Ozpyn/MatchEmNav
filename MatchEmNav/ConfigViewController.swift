//
//  ConfigViewController.swift
//  MatchEmNav
//
//  Created by ozpyn on 10/21/24.
//

import UIKit

class ConfigSceneViewController: UIViewController {
    
    weak var gameScene: GameSceneViewController?

    let speedSlider = UISlider()
    let colorSegmentControl = UISegmentedControl(items: ["Red", "Green", "Blue"])
    let customControl1 = UISlider()
    let customControl2 = UISegmentedControl(items: ["Option 1", "Option 2"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Game Configuration"
        setupControls()
        setupGesture()
    }
    
    func setupControls() {
        // Speed Slider
        speedSlider.minimumValue = 0.1
        speedSlider.maximumValue = 2.0
        speedSlider.value = Float(gameScene?.time ?? 1.0)
        speedSlider.addTarget(self, action: #selector(updateSpeed), for: .valueChanged)
        self.view.addSubview(speedSlider)
        
        // Color Control
        colorSegmentControl.selectedSegmentIndex = 0
        colorSegmentControl.addTarget(self, action: #selector(updateColor), for: .valueChanged)
        self.view.addSubview(colorSegmentControl)
        
        // Additional controls setup
        // Add custom controls as needed and assign their actions
    }

    @objc func updateSpeed() {
        gameScene?.time = Double(speedSlider.value)
    }

    @objc func updateColor() {
        // Update gameScene's color configuration based on selection
    }

    // Set up swipe gesture to return to GameScene
    func setupGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(returnToGameScene))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }

    @objc func returnToGameScene() {
        navigationController?.popViewController(animated: true)
    }
}
