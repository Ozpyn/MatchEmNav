//
//  ConfigViewController.swift
//  MatchEmNav
//
//  Created by ozpyn on 10/21/24.
//

import UIKit

class ConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var difficultySegmentedControl: UISegmentedControl!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var spawnRateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreTableView: UITableView! // IBOutlet for the score table

    // Reference to the GameSceneViewController
    var gameSceneVC: GameSceneViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set initial labels
        updateLabels()

        // Set up table view
        scoreTableView.dataSource = self
        scoreTableView.delegate = self

        // Add target-action for sliders
        rateSlider.addTarget(self, action: #selector(rateSliderChanged(_:)), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderChanged(_:)), for: .valueChanged)

        // Add swipe gesture recognizer for returning to the game scene
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(returnToGameScene))
        swipeGesture.direction = .right
        self.view.addGestureRecognizer(swipeGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the controls to their current values
        updateControls()
        scoreTableView.reloadData() // Reload the table data
    }

    func updateControls() {
        guard let gameScene = gameSceneVC else { return }

        difficultySegmentedControl.selectedSegmentIndex = Int(3 - gameScene.spawnModifier)
        rateSlider.value = Float(1 / gameScene.rateModifier)
        redSwitch.isOn = gameScene.haveRed > 0.1
        blueSwitch.isOn = gameScene.haveBlue > 0.1
        greenSwitch.isOn = gameScene.haveGreen > 0.1
        timeSlider.value = Float(gameScene.playTime)

        // Update labels with the current slider values
        updateLabels()
    }

    private func updateLabels() {
        let spawnRate = Double(rateSlider.value)
        let totalTime = Double(timeSlider.value)

        // Truncate to 2 decimal places and update labels
        spawnRateLabel.text = String(format: "Spawn Rate (Pair/sec): %.2f", spawnRate)
        timeLabel.text = String(format: "Total Time: %.2f", totalTime)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameSceneVC?.highScores.count ?? 0 // Return number of high scores
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath)
        if let gameScene = gameSceneVC {
            cell.textLabel?.text = "\(indexPath.row + 1). \(gameScene.highScores[indexPath.row])"
        }
        return cell
    }

    // Actions for sliders
    @objc func rateSliderChanged(_ sender: UISlider) {
        updateLabels()
    }

    @objc func timeSliderChanged(_ sender: UISlider) {
        updateLabels()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveGameSceneSettings() // Save settings when exiting
    }

    private func saveGameSceneSettings() {
        guard let gameScene = gameSceneVC else { return }

        // Save settings back to GameSceneViewController
        gameScene.spawnModifier = Int(3 - difficultySegmentedControl.selectedSegmentIndex)
        gameScene.rateModifier = 1 / Double(rateSlider.value)
        gameScene.haveRed = redSwitch.isOn ? 1.0 : 0.1
        gameScene.haveBlue = blueSwitch.isOn ? 1.0 : 0.1
        gameScene.haveGreen = greenSwitch.isOn ? 1.0 : 0.1
        gameScene.time = Double(timeSlider.value)
        gameScene.playTime = Double(timeSlider.value)
    }

    @objc func returnToGameScene() {
        navigationController?.popViewController(animated: true) // Return to GameSceneViewController
    }
}
