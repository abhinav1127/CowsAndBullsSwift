//
//  ViewController.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/4/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var enable: UIButton!
    @IBOutlet weak var giveUp: UIBarButtonItem!
    @IBOutlet weak var nextBubble: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var previousBubble: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backspaceButton: UIButton!
    
    @IBOutlet weak var info: UITextView!
    @IBOutlet weak var guessTable: UITableView!
    var word = "!!!!"
    let limitLength = 4
    var cowsArray: [Int] = []
    var bullsArray: [Int] = []
    var pastGuesses: [String] = []
    var allPossibleWords: [String] = []
    static let ice = UIColor(red: 115/255, green: 253/255, blue: 255/255, alpha: 1)
    let turquoise = UIColor(red: 118/255, green: 214/255, blue: 255/255, alpha: 1)
    var lastBubbleSelected = 0
    var hasRepeatingLetters = false
    
    
    @IBOutlet var keyboardKeys: [Key]!
    var keyboardKeyLongPressRecognizers: [UILongPressGestureRecognizer] = []
    
    
    @IBOutlet var bubbles: [Bubble]!
    var bubblesLongPressRecognizers: [UILongPressGestureRecognizer] = []
    var currentGuess: String = "    "
    
    var startTime = TimeInterval()
    var timer = Timer()
    
    @IBOutlet weak var navigation: UINavigationItem!
    
    var wordsFilePath: String?
    
    
    @IBAction func backspacePressed(_ sender: Any) {
        previousBubbleFunction(sender)
        info.text = ""
        bubbles[lastBubbleSelected].setTitle(" ", for: .normal)
        currentGuess = replace(myString: currentGuess, lastBubbleSelected, " ")
        
    }
    @IBAction func enableAllKeys(_ sender: Any) {
        for key in keyboardKeys {
            if (!key.isOn) {
                key.changeState()
            }
        }
        info.text = "All keys enabled!"
        fadeViewInThenOut(view: info, delay: 2)
    }
    
    @IBAction func KeyboardClicked(_ sender: Key) {
        // convert Int to a valid UnicodeScalar
        
        if (sender.isOn) {
            info.text = ""
            bubbles[lastBubbleSelected].setTitle("\(String(sender.letter))", for: .normal)
            currentGuess = replace(myString: currentGuess, lastBubbleSelected, sender.letter)
            examineGuess(currGuess: currentGuess)
            selectNextBubble(fromNextFunc: false)
        } else {
            info.text = "\(sender.letter) has been disabled. Hold it to enable."
            fadeViewInThenOut(view: info, delay: 2)
        }
    
    }
    
    @IBAction func submitGuess(_ sender: Any) {
        performGuess(currGuess: currentGuess)
    }
    
    @objc @IBAction func keyboardHeld(sender: UILongPressGestureRecognizer) {
        
        let theView = sender.view
        let theKey = (theView as! Key)
        print(43)

        if (sender.state == UIGestureRecognizerState.began) {
            if let titleText = theKey.titleLabel?.text {
                if (titleText == " ") {
                    info.text = "Cannot lock an empty bubble"
                    fadeViewInThenOut(view: info, delay: 2)
                } else {
                    print(33)
                    theKey.changeState()
                }
            } else {
                print("Error 27")
            }

        }
        
    }
    
    //combine this method and the one above
    @objc @IBAction func bubbleHeld(sender: UILongPressGestureRecognizer) {
        
        print(Bubble.numOn)
        let theView = sender.view
        let theBubble = (theView as! Bubble)
        
        if (sender.state == UIGestureRecognizerState.began) {
            if (theBubble.isOn) {
                if (Bubble.numOn > 1) {
                    if let titleText = theBubble.titleLabel?.text {
                        if (titleText == " ") {
                            info.text = "Cannot lock an empty bubble"
                            fadeViewInThenOut(view: info, delay: 2)
                        } else {
                            theBubble.changeState()
                            if (theBubble.tag == lastBubbleSelected) {
                                selectNextBubble(fromNextFunc: false)
                            }
                        }
                    } else {
                        print("Error 27")
                    }
                } else {
                    info.text = "Cannot lock all bubbles"
                    fadeViewInThenOut(view: info, delay: 2)
                }
            } else {
                theBubble.changeState()
                selectThisBubble(bubble: theBubble.tag)
            }
        }
        
    }
    
    
    @objc func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        navigation.title = "\(strMinutes):\(strSeconds)"
    }

    
    
    @IBAction func clearBubbles(_ sender: Any) {
        info.text = "Cleared!"
        fadeViewInThenOut(view: info, delay: 2)
        var assigned = false

        for (index, bubs) in bubbles.enumerated() {
            if (bubs.isOn) {
                bubs.setTitle(" ", for: .normal)
                currentGuess = replace(myString: currentGuess, index, " ")
                if (!assigned) {
                    print("\(index)")
                    selectThisBubble(bubble: index)
                    assigned = true
                }
            }
        }
        
    }
    
    @IBAction func previousBubbleFunction(_ sender: Any) {
        var assigned = false
        var counter = lastBubbleSelected - 1
        let originalBubble = lastBubbleSelected
        while (!assigned) {
            if (counter == -1) {
                counter = 3
            }
            if (bubbles[counter].isOn) {
                selectThisBubble(bubble: counter)
                assigned = true
            }
            counter -= 1
        }
        if (originalBubble == lastBubbleSelected) {
            info.text = "All other bubbles are locked. Hold to unlock"
            fadeViewInThenOut(view: info, delay: 2)
        }
    }
    @IBAction func nextBubbleFunction(_ sender: Any) {
        selectNextBubble(fromNextFunc: true)
    }
    @IBAction func giveUpFunction(_ sender: UIBarButtonItem) {
        if (sender.title == "Give Up") {
            gameOver(won: false)
        } else {
            restartGame()
        }
    }
    
    func restartGame() {
        cowsArray = []
        bullsArray = []
        pastGuesses = []
        lastBubbleSelected = 0
        hasRepeatingLetters = false
        currentGuess = "    "
        self.guessTable.reloadData()
        nextBubble.isEnabled = true
        clear.isEnabled = true
        previousBubble.isEnabled = true
        enable.isEnabled = true
        for bubs in bubbles {
            bubs.isEnabled = true
            if (!bubs.isOn) {
                bubs.backgroundColor = GameViewController.ice
                bubs.changeState()
            }
        }
        backspaceButton.isEnabled = true
        submitButton.isEnabled = true
        for key: Key in keyboardKeys {
            key.isEnabled = true
            if (!key.isOn) {
                key.changeState()
            }
        }
        navigation.title = "00:00"
        giveUp.title = "Give Up"
        info.text = "Enter a guess!"
        fadeViewInThenOut(view: info, delay: 2)
        bubbles[0].setTitle(" ", for: .normal)
        bubbles[1].setTitle(" ", for: .normal)
        bubbles[2].setTitle(" ", for: .normal)
        bubbles[3].setTitle(" ", for: .normal)
        bubbleClicked(bubbles[0])
        do {
            let wordsString = try String(contentsOfFile: wordsFilePath!)
            
            let wordLines = wordsString.components(separatedBy: .newlines)
            
            let randomLine = wordLines[numericCast(arc4random_uniform(numericCast(wordLines.count)))]
            
            word = randomLine.uppercased()
            
            print(word + "Finder")
            
        } catch { // contentsOfFile throws an error
            print("Error: \(error)")
        }
    }
    
    @IBAction func bubbleClicked(_ sender: Bubble) {
        bubbleClicked(bubbleIndex: sender.tag)
    }
    
    func bubbleClicked(bubbleIndex: Int) {
        for bubs in bubbles {
            if (bubs.isOn) {
                bubs.backgroundColor = GameViewController.ice
            }
        }
        if (bubbles[bubbleIndex].isOn) {
            bubbles[bubbleIndex].backgroundColor = turquoise
            lastBubbleSelected = bubbleIndex
        } else {
            bubbles[lastBubbleSelected].backgroundColor = turquoise
            info.text = "That bubble is disabled. Hold it to enable it."
            fadeViewInThenOut(view: info, delay: 2)

        }
    }

    func examineGuess(currGuess: String) {
        let currGuessWOSpaces = currGuess.replacingOccurrences(of: " ", with: "")
        hasRepeatingLetters = false
        
        if (currGuessWOSpaces == "") {
            clear.isEnabled = false
        } else {
            clear.isEnabled = true
        }
        
        if (currGuessWOSpaces.count == 4) {
            if (!allPossibleWords.contains(currGuess.lowercased())) {
                info.text = "This is not a guessable word"
                fadeViewInThenOut(view: info, delay: 2)
            }
            if (pastGuesses.contains(currGuess)) {
                info.text = "You have already guessed this word"
                fadeViewInThenOut(view: info, delay: 2)
            }
        }
        
        if (currGuessWOSpaces.count > 1) {
            var count = 0
            for (position1, char1) in currGuessWOSpaces.enumerated() {
                for (position2, char2) in currGuessWOSpaces.enumerated() {
                    if (char1 == char2 && position1 != position2) {
                        count += 1
                    }
                }
            }
            if (count > 0) {
                info.text = "Warning: Cannot have repeating letters"
                hasRepeatingLetters = true
                fadeViewInThenOut(view: info, delay: 2)
            } else {
                hasRepeatingLetters = false
            }
            
        }
    }
    
    func selectNextBubble(fromNextFunc: Bool) {
        var assigned = false
        var counter = lastBubbleSelected + 1
        let originalBubble = lastBubbleSelected
        while (!assigned) {
            if (counter == 4) {
                counter = 0
            }
            if (bubbles[counter].isOn) {
                selectThisBubble(bubble: counter)
                assigned = true
            }
            counter += 1
        }
        if (fromNextFunc && originalBubble == lastBubbleSelected) {
            info.text = "All other bubbles are locked. Hold to unlock"
            fadeViewInThenOut(view: info, delay: 2)
        }
        
    }
    
    func selectThisBubble(bubble: Int) {
        if (bubble == 0) {
            bubbleClicked(bubbleIndex: 0)
        } else if (bubble == 1) {
            bubbleClicked(bubbleIndex: 1)
        } else if (bubble == 2) {
            bubbleClicked(bubbleIndex: 2)
        } else if (bubble == 3) {
            bubbleClicked(bubbleIndex: 3)
        }
    }
    
    
    func performGuess(currGuess: String) {

        selectThisBubble(bubble: 0)
        if (currGuess.contains(" ")) {
            info.text = "Submit a word with 4 letters"
            fadeViewInThenOut(view: info, delay: 2)
        } else if (hasRepeatingLetters) {
            info.text = "Your guess must not have repeating letters"
            fadeViewInThenOut(view: info, delay: 2)
        }else if (pastGuesses.contains(currGuess)) {
            info.text = "You cannot guess a word you have already guessed"
            fadeViewInThenOut(view: info, delay: 2)
        } else if (!allPossibleWords.contains(currGuess.lowercased())) {
            info.text = "This is not a guessable word"
            fadeViewInThenOut(view: info, delay: 2)
        } else {
            pastGuesses.insert(currGuess, at: 0)
            guessChecker(guess: currGuess)
        }
        
        print(Bubble.numOn)

        
    }
    
    private func adjustImageAndTitleOffsetsForButton(button: UIButton) {
        
        let spacing: CGFloat = 6.0
        
        let imageSize = button.imageView!.frame.size
        
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -imageSize.width, -(imageSize.height + spacing), 0)
        
        let titleSize = button.titleLabel!.frame.size
        
        button.imageEdgeInsets = UIEdgeInsetsMake(-(titleSize.height + spacing), 0, 0, -titleSize.width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        info.textAlignment = .center
        Bubble.numOn = 4
        guessTable.delegate = self
        guessTable.dataSource = self
        print("num on: \(Bubble.numOn)")
        
        for key in keyboardKeys {
            let keyTitle: Character = Character((key.titleLabel?.text!)!)
            key.setLetter(theLetter: keyTitle)
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.keyboardHeld))
            gestureRecognizer.minimumPressDuration = 0.45
            keyboardKeyLongPressRecognizers.append(gestureRecognizer)
            key.addGestureRecognizer(gestureRecognizer)
        }
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.clearBubbles(_:)))
        gestureRecognizer.minimumPressDuration = 0.45
        backspaceButton.addGestureRecognizer(gestureRecognizer)
        
        for bubs in bubbles {
            bubs.layer.cornerRadius = bubs.frame.width / 2
            bubs.clipsToBounds = true
            self.adjustImageAndTitleOffsetsForButton(button: bubs)
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.bubbleHeld(sender:)))
            gestureRecognizer.minimumPressDuration = 0.45
            bubblesLongPressRecognizers.append(gestureRecognizer)
            bubs.addGestureRecognizer(gestureRecognizer)
        }

        print("Dll: \(DifficultyViewController.difficultyLevel)")

        if let wordsFilePath1 = Bundle.main.path(forResource: "CBWords", ofType: "txt") {
            print("hello")
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath1)
                
                let wordLines = wordsString.components(separatedBy: .newlines)
                
                allPossibleWords = wordLines
                
            } catch { // contentsOfFile throws an error
                print("Error: \(error)")
            }
            
        }
        
        if (DifficultyViewController.difficultyLevel == 1) {
            wordsFilePath = Bundle.main.path(forResource: "EasyWords", ofType: "txt")
        } else if (DifficultyViewController.difficultyLevel == 2) {
            wordsFilePath = Bundle.main.path(forResource: "MediumWords", ofType: "txt")
        } else if (DifficultyViewController.difficultyLevel == 3) {
            wordsFilePath = Bundle.main.path(forResource: "HardWords", ofType: "txt")
        } else {
            wordsFilePath = Bundle.main.path(forResource: "VeryHardWords", ofType: "txt")
        }
                
        do {
            let wordsString = try String(contentsOfFile: wordsFilePath!)
            
            let wordLines = wordsString.components(separatedBy: .newlines)
            
            let randomLine = wordLines[numericCast(arc4random_uniform(numericCast(wordLines.count)))]
            
            word = randomLine.uppercased()
            
            print(word + "Finder")
            
        } catch { // contentsOfFile throws an error
            print("Error: \(error)")
        }
        
        
        
        info.text = "Enter a guess!"
        fadeViewInThenOut(view: info, delay: 2)
        
        bubbles[0].setTitle(" ", for: .normal)
        bubbles[1].setTitle(" ", for: .normal)
        bubbles[2].setTitle(" ", for: .normal)
        bubbles[3].setTitle(" ", for: .normal)
        
        selectThisBubble(bubble: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func guessChecker(guess: String) {
        if (pastGuesses.count == 1) {
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
        }
        
        var cows = 0
        var bulls = 0
        var wordArray: [Character] = [word[word.startIndex], word[word.index(word.startIndex, offsetBy: 1)], word[word.index(word.startIndex, offsetBy: 2)], word[word.index(word.startIndex, offsetBy: 3)]]
        var guessArray: [Character] = [guess[guess.startIndex], guess[guess.index(guess.startIndex, offsetBy: 1)], guess[guess.index(guess.startIndex, offsetBy: 2)], guess[guess.index(guess.startIndex, offsetBy: 3)]]
        
        for word in wordArray {
            for guess in guessArray {
                if (word == guess) {
                    cows += 1
                }
            }
        }
        var iterator = 0
        while (iterator <= 3) {
            if (wordArray[iterator] == guessArray[iterator]) {
                cows -= 1
                bulls += 1
            }
            iterator += 1
        }
        info.text = "Cows: \(cows), Bulls: \(bulls)"
        fadeViewInThenOut(view: info, delay: 2)
        if (bulls == 4) {
            gameOver(won: true)
        }
        print(currentGuess)
        if (cows == 0 && bulls == 0) {
            for key in keyboardKeys {
                if (currentGuess.contains(Character(key.titleLabel!.text!)) && key.isOn) {
                    key.changeState()
                }
            }
        }
        cowsArray.insert(cows, at: 0)
        bullsArray.insert(bulls, at: 0)
        self.guessTable.reloadData()
    }
    
    func gameOver(won: Bool) {
        timer.invalidate()
        if (won) {
            if (pastGuesses.count != 1) {
                info.text = "Correct! You got it in \(pastGuesses.count) guesses and \(navigation.title!)!"
            } else {
                info.text = "Correct! You got it in 1 guess! How's that even possible?"
            }
            fadeViewInThenOut(view: info, delay: 10000)

        } else {
            info.text = "The word was \(word)!"
            fadeViewInThenOut(view: info, delay: 10000)
        }
        nextBubble.isEnabled = false
        clear.isEnabled = false
        previousBubble.isEnabled = false
        enable.isEnabled = false
        for bubs in bubbles {
            bubs.backgroundColor = UIColor.gray
            bubs.isEnabled = false
        }
        submitButton.isEnabled = false
        for key: Key in keyboardKeys {
            if (key.isOn) {
                key.changeState()
            }
            key.isEnabled = false
        }
        backspaceButton.isEnabled = false
        giveUp.title = "Play Again"
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastGuesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = guessTable.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        cell.wordLbl.text = pastGuesses[indexPath.row]
        cell.cowsLbl.text = String(cowsArray[indexPath.row])
        cell.bullsLbl.text = String(bullsArray[indexPath.row])
        
        return cell
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: [.curveEaseOut], animations: { () -> Void in
                view.alpha = 0
            }, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

