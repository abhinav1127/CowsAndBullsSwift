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
    var lastBubbleSelected = 0
    var hasRepeatingLetters = false
    var difficultyLevel = 0
    
    
    @IBOutlet var keyboardKeys: [Key]!
    var keyboardKeyLongPressRecognizers: [UILongPressGestureRecognizer] = []
    
    
    @IBOutlet var bubbles: [Bubble]!
    var currentGuess: String = "    "
    
    
    
    var startTime = TimeInterval()
    var timer = Timer()
    
    @IBAction func KeyboardClicked(_ sender: Key) {
        // convert Int to a valid UnicodeScalar
        print("hol0 \((sender as AnyObject).isOn)")

        if (sender.isOn) {
            
            bubbles[lastBubbleSelected].setTitle("\(String(sender.letter))", for: .normal)

            currentGuess = replace(myString: currentGuess, lastBubbleSelected, sender.letter)
            print(currentGuess)
            examineGuess(currGuess: currentGuess)
            selectNextBubble()
        } else {
            info.text = "\(sender.letter) has been disabled. Hold it to enable."
        }
    
    }
    
    @IBAction func submitGuess(_ sender: Any) {
        performGuess(currGuess: currentGuess)
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
        currentGuess = "    "
        fadeViewInThenOut(view: info, delay: 2)
        
        for bubs in bubbles {
            bubs.setTitle(" ", for: .normal)
            bubs.isOn = true
        }
        
        selectThisBubble(bubble: 0)
    }
    
    @IBAction func previousBubbleFunction(_ sender: Any) {
        if (lastBubbleSelected != 0) {
            selectThisBubble(bubble: lastBubbleSelected - 1)
        } else {
            selectThisBubble(bubble: 3)
        }
    }
    @IBAction func nextBubbleFunction(_ sender: Any) {
        selectNextBubble()
    }
    @IBAction func giveUpFunction(_ sender: Any) {
        gameOver(won: false)
    }
    
    @IBAction func bubbleClicked(_ sender: Bubble) {
        let bubbleIndex = sender.tag
        for bubs in bubbles {
            bubs.backgroundColor = ice
        }
        bubbles[bubbleIndex].backgroundColor = turquoise
        lastBubbleSelected = bubbleIndex
    }
    
    func bubbleClicked(bubbleIndex: Int) {
        for bubs in bubbles {
            bubs.backgroundColor = ice
        }
        bubbles[bubbleIndex].backgroundColor = turquoise
        lastBubbleSelected = bubbleIndex
    }

//    func changeGuess() {
//        currentGuess = ""
//        for bubs in bubbles {
//            if (bubs.titleLabel!.text! != " ") {
//                currentGuess += bubs.titleLabel!.text!
//            }
//        }
//        print("huhhhhhhh + \(currentGuess)")
//        guessField.text = currentGuess
//
//        //necessary?
//        //textChange((Any).self)
//        examineGuess(currGuess: currentGuess)
//    }

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
    
//    @IBAction func textChange(_ sender: Any) {
//        guessField.text = guessField.text?.uppercased()
//        if var textInputtedWithSpaces = guessField.text {
//            let textInputted = textInputtedWithSpaces.replacingOccurrences(of: " ", with: "")
//            hasRepeatingLetters = false
//            if (textInputted == "") {
//                clear.isEnabled = false
//            } else {
//                clear.isEnabled = true
//            }
//            if (textInputted.count == 4) {
//
//                if (!allPossibleWords.contains(textInputted.lowercased())) {
//                    info.text = "This is not a guessable word"
//                    fadeViewInThenOut(view: info, delay: 2)
//                }
//            }
//            if (textInputted.count > 1) {
//                var count = 0
//                for (position1, char1) in textInputted.enumerated() {
//                    for (position2, char2) in textInputted.enumerated() {
//                        if (char1 == char2 && position1 != position2) {
//                            count += 1
//                        }
//                    }
//                }
//                if (count > 0) {
//                    info.text = "Warning: Cannot have repeating letters"
//                    hasRepeatingLetters = true
//                    fadeViewInThenOut(view: info, delay: 2)
//                }
//
//            }
//            if (pastGuesses.contains(textInputted)) {
//                info.text = "You have already guessed this word"
//                fadeViewInThenOut(view: info, delay: 2)
//            }
//
//            if (textInputted.count > 4) {
//                guessField.text = textInputtedWithSpaces.substring(to: textInputted.index(textInputted.startIndex, offsetBy: 4))
//            }
//
//            var inputArray: [Character] = [textInputtedWithSpaces[textInputtedWithSpaces.startIndex], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 1)], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 2)], textInputtedWithSpaces[textInputtedWithSpaces.index(textInputtedWithSpaces.startIndex, offsetBy: 3)]]
//
//            bubbles[0].setTitle("\(inputArray[0])", for: .normal)
//            bubbles[1].setTitle("\(inputArray[1])", for: .normal)
//            bubbles[2].setTitle("\(inputArray[2])", for: .normal)
//            bubbles[3].setTitle("\(inputArray[3])", for: .normal)
//
//            selectNextBubble()
//        }
//    }
    
    func selectNextBubble() {
        print("huhhh")
        if (lastBubbleSelected != 3) {
            selectThisBubble(bubble: lastBubbleSelected + 1)
        } else {
            selectThisBubble(bubble: 0)
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
        if (currGuess.count != 4) {
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
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guessField.delegate = self
        guessTable.delegate = self
        guessTable.dataSource = self
        
        
        for key in keyboardKeys {
            let keyTitle: Character = Character((key.titleLabel?.text!)!)
            key.setLetter(theLetter: keyTitle)
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.keyboardHeld))
            gestureRecognizer.minimumPressDuration = 0.6
            keyboardKeyLongPressRecognizers.append(gestureRecognizer)
            key.addGestureRecognizer(gestureRecognizer)
        }
        
//        for bubs in bubbles {
//            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.keyboardHeld))
//            gestureRecognizer.minimumPressDuration = 0.6
//            keyboardKeyLongPressRecognizers.append(gestureRecognizer)
//            key.addGestureRecognizer(gestureRecognizer)
//        }
        
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
        
        bubbles[0].setTitle(" ", for: .normal)
        bubbles[1].setTitle(" ", for: .normal)
        bubbles[2].setTitle(" ", for: .normal)
        bubbles[3].setTitle(" ", for: .normal)
        
        selectThisBubble(bubble: 0)
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(GameViewController.updateTime)), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
        
    }
    
   
    
    
    //For some reason, we need to delay before the text can select initially
//    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//            completion()
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//
//        super.viewWillAppear(true)
//        delayWithSeconds(0.0001) {
//            self.guessField.selectedTextRange = self.guessField.textRange(from: self.guessField.beginningOfDocument, to: self.guessField.position(from: self.guessField.endOfDocument, offset: -3)!)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //not sure what this does
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performGuess(currGuess: currentGuess)
        return false
    }
    
  
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        var onlyCharacters: Bool = true
//
//        info.text = ""
//
//        guard let text = textField.text else { return true }
//        let newLength = text.characters.count + string.characters.count - range.length
//        if newLength > 4 {
//            info.text = "Cannot enter more than 4 letters"
//            fadeViewInThenOut(view: info, delay: 2)
//        }
//
//        let characterSet = CharacterSet.letters
//        if string.rangeOfCharacter(from: characterSet.inverted) != nil {
//            onlyCharacters = false
//        } else {
//            onlyCharacters = true
//        }
//
//        let char = string.cString(using: String.Encoding.utf8)!
//        let isBackSpace = strcmp(char, "\\b")
//
//        if (isBackSpace == -92) {
//            bubbles[lastBubbleSelected].setTitle(" ", for: .normal)
//            guessField.text = replace(myString: guessField.text!, lastBubbleSelected - 1, " ")
//            if (lastBubbleSelected != 1) {
//                selectThisBubble(bubble: lastBubbleSelected - 1)
//            } else {
//                selectThisBubble(bubble: lastBubbleSelected)
//            }
//            return false
//        }
//
//        return (newLength <= limitLength) && onlyCharacters
//
//    }
    
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
        bubbles[0].isEnabled = false
        bubbles[1].isEnabled = false
        bubbles[2].isEnabled = false
        bubbles[3].isEnabled = false
        guessField.resignFirstResponder()
        for key: Key in keyboardKeys {
            key.isOn = false
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

