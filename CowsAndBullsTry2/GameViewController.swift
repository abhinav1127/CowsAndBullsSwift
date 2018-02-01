//
//  ViewController.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/4/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var giveUp: UIButton!
    @IBOutlet weak var nextBubble: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var previousBubble: UIButton!
    @IBOutlet weak var bubbleFirstLetter: UIButton!
    @IBOutlet weak var bubbleSecondLetter: UIButton!
    @IBOutlet weak var bubbleThirdLetter: UIButton!
    @IBOutlet weak var bubbleFourthLetter: UIButton!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var guessTable: UITableView!
    var word = "!!!!"
    let limitLength = 4
    var cowsArray: [Int] = []
    var bullsArray: [Int] = []
    var pastGuesses: [String] = []
    var allPossibleWords: [String] = []
    let ice = UIColor(red: 115/255, green: 253/255, blue: 255/255, alpha: 1)
    let turquoise = UIColor(red: 118/255, green: 214/255, blue: 255/255, alpha: 1)
    var lastBubbleSelected = 1
    var hasRepeatingLetters = false
    var difficultyLevel = 0
    
    
    @IBOutlet var keyboardKeys: [Key]!
    var keyboardKeyLongPressRecognizers: [UILongPressGestureRecognizer] = []
    
    
    var startTime = TimeInterval()
    var timer = Timer()
    
    @IBAction func KeyboardClicked(_ sender: Key) {
        // convert Int to a valid UnicodeScalar
        print("hol0 \((sender as AnyObject).isOn)")

        if (sender.isOn) {
            
            guessField.text = replace(myString: guessField.text!, lastBubbleSelected - 1, sender.letter)
            textChange((Any).self)
        } else {
            info.text = "\(sender.letter) has been disabled. Hold it to enable."
        }
    
    }
    
    @objc @IBAction func keyboardHeld(sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.began) {
            print("yayyy")
            let theView = sender.view
            let theKey = (theView as! Key)
            theKey.changeState()
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
        timerLabel.text = "\(strMinutes):\(strSeconds)"
        
    }

    
    
    @IBAction func clearBubbles(_ sender: Any) {
        info.text = "Cleared!"
        guessField.text = "    "
        fadeViewInThenOut(view: info, delay: 2)
        
        bubbleFirstLetter.setTitle(" ", for: .normal)
        bubbleSecondLetter.setTitle(" ", for: .normal)
        bubbleThirdLetter.setTitle(" ", for: .normal)
        bubbleFourthLetter.setTitle(" ", for: .normal)
        
        selectThisBubble(bubble: 1)
    }
    
    @IBAction func previousBubbleFunction(_ sender: Any) {
        if (lastBubbleSelected != 1) {
            selectThisBubble(bubble: lastBubbleSelected - 1)
        } else {
            selectThisBubble(bubble: lastBubbleSelected)
        }
    }
    @IBAction func nextBubbleFunction(_ sender: Any) {
        if (lastBubbleSelected != 4) {
            selectThisBubble(bubble: lastBubbleSelected + 1)
        } else {
            selectThisBubble(bubble: lastBubbleSelected)
        }
    }
    @IBAction func giveUpFunction(_ sender: Any) {
        gameOver(won: false)
    }
    
    @IBAction func bubbleFirstClicked(_ sender: Any) {
        guessField.becomeFirstResponder()
        guessField.selectedTextRange = guessField.textRange(from: guessField.beginningOfDocument, to: guessField.position(from: guessField.endOfDocument, offset: -3)!)
        bubbleFirstLetter.backgroundColor = turquoise
        bubbleSecondLetter.backgroundColor = ice
        bubbleThirdLetter.backgroundColor = ice
        bubbleFourthLetter.backgroundColor = ice
        
        lastBubbleSelected = 1
        
        nextBubble.isEnabled = true
        previousBubble.isEnabled = false
    }
    
    @IBAction func bubbleSecondClicked(_ sender: Any) {
        guessField.becomeFirstResponder()
        guessField.selectedTextRange = guessField.textRange(from: guessField.position(from: guessField.endOfDocument, offset: -3)!, to: guessField.position(from: guessField.endOfDocument, offset: -2)!)
        
        bubbleFirstLetter.backgroundColor = ice
        bubbleSecondLetter.backgroundColor = turquoise
        bubbleThirdLetter.backgroundColor = ice
        bubbleFourthLetter.backgroundColor = ice
        
        lastBubbleSelected = 2
        
        nextBubble.isEnabled = true
        previousBubble.isEnabled = true
    }
    
    @IBAction func bubbleThirdClicked(_ sender: Any) {
        guessField.becomeFirstResponder()
        guessField.selectedTextRange = guessField.textRange(from: guessField.position(from: guessField.endOfDocument, offset: -2)!, to: guessField.position(from: guessField.endOfDocument, offset: -1)!)
        
        bubbleFirstLetter.backgroundColor = ice
        bubbleSecondLetter.backgroundColor = ice
        bubbleThirdLetter.backgroundColor = turquoise
        bubbleFourthLetter.backgroundColor = ice
        
        lastBubbleSelected = 3
        
        nextBubble.isEnabled = true
        previousBubble.isEnabled = true
    }
    
    @IBAction func bubbleFourthClicked(_ sender: Any) {
        guessField.becomeFirstResponder()
        guessField.selectedTextRange = guessField.textRange(from: guessField.position(from: guessField.endOfDocument, offset: -1)!, to: guessField.endOfDocument)
        
        bubbleFirstLetter.backgroundColor = ice
        bubbleSecondLetter.backgroundColor = ice
        bubbleThirdLetter.backgroundColor = ice
        bubbleFourthLetter.backgroundColor = turquoise
        
        lastBubbleSelected = 4
        
        nextBubble.isEnabled = false
        previousBubble.isEnabled = true
    }
    
    
    @IBAction func textChange(_ sender: Any) {
        guessField.text = guessField.text?.uppercased()
        if var textInputtedWithSpaces = guessField.text {
            let textInputted = textInputtedWithSpaces.replacingOccurrences(of: " ", with: "")
            hasRepeatingLetters = false
            if (textInputted == "") {
                clear.isEnabled = false
            } else {
                clear.isEnabled = true
            }
            if (textInputted.count == 4) {
                
                if (!allPossibleWords.contains(textInputted.lowercased())) {
                    info.text = "This is not a guessable word"
                    fadeViewInThenOut(view: info, delay: 2)
                }
            }
            if (textInputted.count > 1) {
                var count = 0
                for (position1, char1) in textInputted.enumerated() {
                    for (position2, char2) in textInputted.enumerated() {
                        if (char1 == char2 && position1 != position2) {
                            count += 1
                        }
                    }
                }
                if (count > 0) {
                    info.text = "Warning: Cannot have repeating letters"
                    hasRepeatingLetters = true
                    fadeViewInThenOut(view: info, delay: 2)
                }
                
            }
            if (pastGuesses.contains(textInputted)) {
                info.text = "You have already guessed this word"
                fadeViewInThenOut(view: info, delay: 2)
            }
            
            if (textInputted.count > 4) {
                guessField.text = textInputtedWithSpaces.substring(to: textInputted.index(textInputted.startIndex, offsetBy: 4))
            }

            var inputArray: [Character] = [textInputtedWithSpaces[textInputtedWithSpaces.startIndex], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 1)], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 2)], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 3)]]
            
            bubbleFirstLetter.setTitle("\(inputArray[0])", for: .normal)
            bubbleSecondLetter.setTitle("\(inputArray[1])", for: .normal)
            bubbleThirdLetter.setTitle("\(inputArray[2])", for: .normal)
            bubbleFourthLetter.setTitle("\(inputArray[3])", for: .normal)
            
            selectNextBubble(previousBubble: lastBubbleSelected)
        }
    }
    
    func selectNextBubble(previousBubble: Int) -> Bool {
        
        let bubbleArray = [bubbleFirstLetter, bubbleSecondLetter, bubbleThirdLetter, bubbleFourthLetter]
        
        if (previousBubble != 4) {
            selectThisBubble(bubble: previousBubble + 1)
        } else {
            selectThisBubble(bubble: 1)
        }
        
        return false
    }
    
    func selectThisBubble(bubble: Int) {
        if (bubble == 1) {
            bubbleFirstClicked((Any).self)
        } else if (bubble == 2) {
            bubbleSecondClicked((Any).self)
        } else if (bubble == 3) {
            bubbleThirdClicked((Any).self)
        } else if (bubble == 4) {
            bubbleFourthClicked((Any).self)
        }
    }
    
    func returnThisBubble(bubble: Int) -> UIButton {
        if (bubble == 1) {
            return bubbleFirstLetter
        } else if (bubble == 2) {
            return bubbleSecondLetter
        } else if (bubble == 3) {
            return bubbleThirdLetter
        } else {
            return bubbleFourthLetter
        }
    }
    
    func performGuess() {
        if let textInputted = guessField.text {
            selectThisBubble(bubble: 1)
            if (textInputted.count != 4) {
                info.text = "Submit a word with 4 letters"
                fadeViewInThenOut(view: info, delay: 2)
            } else if (hasRepeatingLetters) {
                info.text = "Your guess must not have repeating letters"
                fadeViewInThenOut(view: info, delay: 2)
            }else if (pastGuesses.contains(textInputted)) {
                info.text = "You cannot guess a word you have already guessed"
                fadeViewInThenOut(view: info, delay: 2)
            } else if (!allPossibleWords.contains(textInputted.lowercased())) {
                info.text = "This is not a guessable word"
                fadeViewInThenOut(view: info, delay: 2)
            } else {
                pastGuesses.insert(textInputted, at: 0)
                guessChecker(guess: textInputted)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guessField.delegate = self
        guessTable.delegate = self
        guessTable.dataSource = self
        
        for (index, key) in keyboardKeys.enumerated() {
            let keyTitle: Character = Character((key.titleLabel?.text!)!)
            key.setLetter(theLetter: keyTitle)
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.keyboardHeld))
            gestureRecognizer.minimumPressDuration = 0.6
            keyboardKeyLongPressRecognizers.append(gestureRecognizer)
            key.addGestureRecognizer(gestureRecognizer)
        }
        
        print("Dll: \(difficultyLevel)")

        if let wordsFilePath = Bundle.main.path(forResource: "CBwords", ofType: "txt") {
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath)
                
                let wordLines = wordsString.components(separatedBy: .newlines)
                
                allPossibleWords = wordLines
                
                if (difficultyLevel != 1) {
                    let randomLine = wordLines[numericCast(arc4random_uniform(numericCast(wordLines.count)))]
                    
                    word = randomLine.uppercased()
                    
                    print(word + "Finder")
                }
                
            } catch { // contentsOfFile throws an error
                print("Error: \(error)")
            }
            
        }
        
        if (difficultyLevel == 1) {
            
            if let wordsFilePath = Bundle.main.path(forResource: "EasyWords", ofType: "txt") {
                
                do {
                    let wordsString = try String(contentsOfFile: wordsFilePath)
                    
                    let wordLines = wordsString.components(separatedBy: .newlines)
                    
                    let randomLine = wordLines[numericCast(arc4random_uniform(numericCast(wordLines.count)))]
                    
                    word = randomLine.uppercased()
                    
                    print(word + "Finder")
                    
                } catch { // contentsOfFile throws an error
                    print("Error: \(error)")
                }
            }
            
        }
        
        
        info.text = "Enter a guess!"
        guessField.text = "    "
        guessField.autocorrectionType = .no
        fadeViewInThenOut(view: info, delay: 2)
        
        bubbleFirstLetter.setTitle(" ", for: .normal)
        bubbleSecondLetter.setTitle(" ", for: .normal)
        bubbleThirdLetter.setTitle(" ", for: .normal)
        bubbleFourthLetter.setTitle(" ", for: .normal)
        
        selectThisBubble(bubble: 1)
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
        
    }
    
   
    
    
    //For some reason, we need to delay before the text can select initially
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        delayWithSeconds(0.0001) {
            self.guessField.selectedTextRange = self.guessField.textRange(from: self.guessField.beginningOfDocument, to: self.guessField.position(from: self.guessField.endOfDocument, offset: -3)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performGuess()
        return false
    }
    
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var onlyCharacters: Bool = true
        
        info.text = ""

        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        if newLength > 4 {
            info.text = "Cannot enter more than 4 letters"
            fadeViewInThenOut(view: info, delay: 2)
        }

        let characterSet = CharacterSet.letters
        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
            onlyCharacters = false
        } else {
            onlyCharacters = true
        }
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            returnThisBubble(bubble: lastBubbleSelected).setTitle(" ", for: .normal)
            guessField.text = replace(myString: guessField.text!, lastBubbleSelected - 1, " ")
            if (lastBubbleSelected != 1) {
                selectThisBubble(bubble: lastBubbleSelected - 1)
            } else {
                selectThisBubble(bubble: lastBubbleSelected)
            }
            return false
        }

        return (newLength <= limitLength) && onlyCharacters
        
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func guessChecker(guess: String) {
        
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
        
        cowsArray.insert(cows, at: 0)
        bullsArray.insert(bulls, at: 0)
        self.guessTable.reloadData()
    }
    
    func gameOver(won: Bool) {
        timer.invalidate()
        timer == nil
        if (won) {
            info.text = "Correct! You got it in \(pastGuesses.count) guesses and \(timerLabel.text!) seconds!"
            fadeViewInThenOut(view: info, delay: 10000)

        } else {
            info.text = "The word was \(word)!"
            fadeViewInThenOut(view: info, delay: 10000)
        }
        giveUp.isEnabled = false
        nextBubble.isEnabled = false
        clear.isEnabled = false
        previousBubble.isEnabled = false
        bubbleFirstLetter.isEnabled = false
        bubbleSecondLetter.isEnabled = false
        bubbleThirdLetter.isEnabled = false
        bubbleFourthLetter.isEnabled = false
        guessField.resignFirstResponder()
        for key: Key in keyboardKeys {
            key.isEnabled = false
        }
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

