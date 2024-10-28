//
//  ViewController.swift
//  MatchEmNav
//
//  Created by ozpyn on 9/18/24.
//

import UIKit

class GameSceneViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    var buttonPairs: [String: [UIButton]] = [:]
    var btns: [UIButton] = []
    var firstButton: UIButton?
    
    // Difficulty Controls
    var spawnModifier: Int = 2; // Lower number is higher difficulty, should be a set of 3 options, easy(3) med(2) hard(1)
    // Speed Controls
    var rateModifier: Double = 1; // Lower number increases the rate at which pairs spawn
    // Color Controls
    var haveRed: Double = 1.0; // flip flop switches turning on and off colors
    var haveBlue: Double = 1.0;
    var haveGreen: Double = 1.0;
    // Playtime Controls
    var playTime: Double = 12.0;
    var highScores: [Int] = []
    
    
    var score = 0 {
        didSet {
            self.infoLabel.text = labelText(self.time, self.score, self.recCount)
        }
    }
    
    var recCount = 0 {
        didSet {
            self.infoLabel.text = labelText(self.time, self.score, self.recCount)
        }
    }
    
    var time = 12.0 {
        didSet {
            self.infoLabel.text = labelText(self.time, self.score, self.recCount)
        }
    }
    
    var labelText: (Double, Int, Int) -> String = { time, score, recCount in
        return "Time: \(Int(time)) - Score: \(score) - Total Count: \(recCount)"
    }
    
    var scoreLabel: (Int) -> String = { score in
        return "Final Score: \(score)"
    }
    
    let startButton = UIButton(type: .system)
    let restartButton = UIButton(type: .system)
    let endScoreLabel = UILabel()
    
    var gameTimer: Timer?
    var spawnTimer: Timer?
    var isPaused: Bool = false
    
    let pauseButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoLabel.text = labelText(self.time, self.score, self.recCount)
        
        setupRestartButton()
        setupStartButton()
        setupEndScore()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(openConfigView))
                swipeGesture.direction = .left // Adjust direction as needed
                self.view.addGestureRecognizer(swipeGesture)
        setupPauseButton()
    }

    func setupPauseButton() {
        pauseButton.setImage(UIImage(systemName: "pause"), for: .normal) // Use the pause icon
        pauseButton.tintColor = .systemBlue // Set a tint color if desired
        pauseButton.frame = CGRect(x: self.view.frame.width - 75, y: 50, width: 75, height: 75)
        pauseButton.addTarget(self, action: #selector(pauseGame), for: .touchUpInside)
        pauseButton.isHidden = true;
        self.view.addSubview(pauseButton)
    }

    func setupStartButton() {
        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        startButton.frame = CGRect(x: (self.view.frame.width - 200) / 2, y: (self.view.frame.height - 50) / 2, width: 200, height: 50)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        self.view.addSubview(startButton)
    }
    
    func setupEndScore() {
        endScoreLabel.frame = CGRect(x: (self.view.frame.width - 400) / 2, y: (self.view.frame.height - 100) / 3, width: 400, height: 100)
        endScoreLabel.font = UIFont.systemFont(ofSize: 40)
        endScoreLabel.textAlignment = .center
        endScoreLabel.text = scoreLabel(score)
        endScoreLabel.isHidden = true
        self.view.addSubview(endScoreLabel)
    }

    @objc func openConfigView() {
        if let configViewController = storyboard?.instantiateViewController(withIdentifier: "ConfigViewController") as? ConfigViewController {
            if !isPaused && !pauseButton.isHidden{
                pauseGame()
            }
            configViewController.gameSceneVC = self // Pass the reference of GameSceneViewController
            navigationController?.pushViewController(configViewController, animated: true)
        }
    }
    

    
    @objc func startGame() {
        startButton.isHidden = true // Hide start button
        pauseButton.isHidden = false
        infoLabel.isHidden = false
        self.time = self.playTime
        countdown(from: 3)
    }

    func setupRestartButton() {
        restartButton.setTitle("Restart?", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        restartButton.frame = CGRect(x: (self.view.frame.width - 200) / 2, y: (self.view.frame.height - 50) / 2, width: 200, height: 50)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        restartButton.isHidden = true
        self.view.addSubview(restartButton)
    }

    @objc func restartGame() {
        endScoreLabel.isHidden = true
        // Reset scores and counts
        self.score = 0
        self.recCount = 0
        infoLabel.text = labelText(self.time, self.score, self.recCount)
        restartButton.isHidden = true
        
        // Invalidate existing timers to prevent issues
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        timersRunning = false // Reset timer state

        startGame() // Start the game
    }


    func countdown(from seconds: Int) {
        var remainingTime = seconds + 1
        let countdownLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 100) / 2, y: (self.view.frame.height - 100) / 2, width: 100, height: 100))
        countdownLabel.font = UIFont.systemFont(ofSize: 60)
        countdownLabel.textAlignment = .center
        self.view.addSubview(countdownLabel)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if remainingTime > 0 {
                if remainingTime == 1 {
                    countdownLabel.text = "Go!"
                } else {
                    countdownLabel.text = "\(remainingTime - 1)"
                }
                remainingTime -= 1
            } else {
                timer.invalidate()
                self.startGameTimer()
                countdownLabel.removeFromSuperview()
            }
        }
    }

    var timersRunning: Bool = false // Add this property to track timer state

    func startGameTimer() {
        guard !timersRunning else { return } // Prevent creating new timers if already running
        timersRunning = true // Mark timers as running

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.time > 0 {
                self.time -= 0.1
            } else {
                timer.invalidate()
                self.endGame()
            }
        }

        spawnTimer = Timer.scheduledTimer(withTimeInterval: self.rateModifier, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.time > 0 {
                self.createRandomRectangleSet()
            } else {
                timer.invalidate()
            }
        }
    }

    @objc func pauseGame() {
        if isPaused {
            resumeGame()
        } else {
            isPaused = true
            gameTimer?.invalidate()
            spawnTimer?.invalidate()
            timersRunning = false // Mark timers as not running
            disableGameButtons(true)
            pauseButton.setImage(UIImage(systemName: "play"), for: .normal) // Change to play icon
        }
    }

    func resumeGame() {
        isPaused = false
        startGameTimer() // Restart the timers
        disableGameButtons(false)
        pauseButton.setImage(UIImage(systemName: "pause"), for: .normal) // Change back to pause icon
    }



    func disableGameButtons(_ disable: Bool) {
        for button in btns {
            button.isUserInteractionEnabled = !disable
        }
    }


    func endGame() {
        // Clear existing buttons and pairs
        for button in btns {
            button.removeFromSuperview()
        }
        btns.removeAll()
        
        // Update and display the end score
        endScoreLabel.isHidden = false
        endScoreLabel.text = scoreLabel(score)
        
        // Add the final score to the high scores
        addToScores(score: score)
        
        // Show the restart button
        restartButton.isHidden = false
        pauseButton.isHidden = true
        isPaused = true;
    }

    func addToScores(score: Int) {
        highScores.append(score)
        highScores.sort(by: >)
        if highScores.count > 3 {
            highScores = Array(highScores.prefix(3))
        }
    }


    
    func createRandomRectangleSet() {
        let minSize: CGFloat = 50.0
        let maxSize: CGFloat = 200.0
        
        let width = CGFloat.random(in: minSize...maxSize)
        let height = CGFloat.random(in: minSize...maxSize)
        
        let randomChar = String(UnicodeScalar(Array(0x1F300...0x1F3F0).randomElement()!)!)
        let color = UIColor(red: CGFloat.random(in: 0...haveRed), green: CGFloat.random(in: 0...haveGreen), blue: CGFloat.random(in: 0...haveBlue), alpha: 1.0)
        
        let cornerRadius = min(width, height) / 3
        
        let maxY = (self.view.frame.maxY - self.view.safeAreaInsets.bottom - infoLabel.frame.height - height)
        
        for _ in 0...1 {
            let y = CGFloat.random(in: self.view.safeAreaInsets.top...maxY)
            var x = CGFloat.random(in: 0...self.view.frame.maxX - width)
            if (y < self.view.safeAreaInsets.top + pauseButton.frame.height){
                x = CGFloat.random(in: 0...(self.view.frame.maxX - width - pauseButton.frame.width))
            }

            let frame = CGRect(x: x, y: y, width: width, height: height)
            let rectBtn = UIButton(frame: frame)
            
            rectBtn.backgroundColor = color
            rectBtn.setTitle(randomChar, for: .normal)
            rectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            rectBtn.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            
            rectBtn.layer.cornerRadius = cornerRadius
            rectBtn.clipsToBounds = true
            rectBtn.layer.borderColor = nil
            rectBtn.layer.borderWidth = 2
            
            self.btns.append(rectBtn)
            self.view.addSubview(rectBtn)
            
            buttonPairs[randomChar, default: []].append(rectBtn)
            
            self.recCount += 1
        }
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        guard self.time > 0 else { return }
        
        if firstButton == nil {
            // First button tapped
            firstButton = sender
            sender.transform = CGAffineTransform(scaleX: 1.25, y: 1.25) // Slightly enlarge
            if let fillColor = sender.backgroundColor {
                // Get the RGBA components of the fill color
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                
                fillColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

                // Calculate the inverse color
                let inverseColor = UIColor(red: 1 - red, green: 1 - green, blue: 1 - blue, alpha: alpha)

                // Set the border color
                sender.layer.borderColor = inverseColor.cgColor
            }
        } else {
            // Second button tapped
            
            if let title = sender.title(for: .normal), let pair = buttonPairs[title], title == firstButton?.currentTitle, sender.backgroundColor == firstButton?.backgroundColor {
//                if sender.transform != .identity {
                if sender.layer.borderColor != nil {
                    // If the second button is already highlighted, unhighlight first
//                    sender.transform = .identity // Reset scale
                    firstButton?.transform = .identity // Reset Scaale
                    firstButton?.layer.borderColor = nil // Reset Border
//                    firstButton = nil // Reset
                } else if pair.contains(firstButton!) {
                    // Remove buttons with animation
                    animateButtonRemoval(firstButton!)
                    animateButtonRemoval(sender)
                    
                    self.btns.removeAll { $0 == firstButton || $0 == sender }
                    buttonPairs[title] = nil
                    self.score += 1
                    
                    if (self.score % spawnModifier) == 0{
                        createRandomRectangleSet() //Difficult
                    }
                }
                } else {
                    // No match
                    firstButton?.transform = .identity // Reset scale
                    firstButton?.layer.borderColor = nil // Reset Border
                    
                }
            
            firstButton = nil // Reset for the next pair
        }
    }

    private func animateButtonRemoval(_ button: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // Shrink
            button.alpha = 0.0 // Fade out
        }) { _ in
            button.removeFromSuperview() // Remove after animation completes
        }
    }
}

