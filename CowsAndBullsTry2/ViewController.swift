//
//  ViewController.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/4/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bullsLbl: UILabel!
    @IBOutlet weak var cowsLbl: UILabel!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var guessTable: UITableView!
    var word = "!!!!"
    let limitLength = 4
    var cowsArray: [Int] = []
    var bullsArray: [Int] = []
    var pastGuesses: [String] = []
    var allPossibleWords: [String] = []

    
    @IBAction func textChange(_ sender: Any) {
        guessField.text = guessField.text?.uppercased()
        if var textInputted = guessField.text {
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
                    fadeViewInThenOut(view: info, delay: 2)
                    guessField.text = textInputted
                }
                
            }
            if (pastGuesses.contains(textInputted)) {
                info.text = "You have already guessed this word"
                fadeViewInThenOut(view: info, delay: 2)
            }
            
            if (textInputted.count > 4) {
                guessField.text = textInputted.substring(to: textInputted.index(textInputted.startIndex, offsetBy: 4))
            }
           
        }
    }
    

    
    func performGuess() {
        if var textInputted = guessField.text {
            if (textInputted.count != 4) {
                info.text = "Submit a word with 4 letters"
                fadeViewInThenOut(view: info, delay: 2)
            } else if (pastGuesses.contains(textInputted)) {
                info.text = "You cannot guess a word you guessed in the past"
                fadeViewInThenOut(view: info, delay: 2)
            } else if (!allPossibleWords.contains(textInputted.lowercased())) {
                info.text = "This is not a guessable word"
                fadeViewInThenOut(view: info, delay: 2)
            } else {
                guessField.text = ""
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

        if let wordsFilePath = Bundle.main.path(forResource: "CBwords", ofType: "txt") {
            do {
                let wordsString = try String(contentsOfFile: wordsFilePath)
                
                let wordLines = wordsString.components(separatedBy: .newlines)
                
                allPossibleWords = wordLines
                
            } catch { // contentsOfFile throws an error
                print("Error: \(error)")
            }
            
        }
        
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
        
        info.text = "Enter a guess!"
        fadeViewInThenOut(view: info, delay: 2)

        
        
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

        return (newLength <= limitLength) && onlyCharacters //&& !(count > 1)
        return true;
        
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
            info.text = "That's Exactly Right! You win and you took \(pastGuesses.count) guesses"
        }
        
        cowsArray.insert(cows, at: 0)
        bullsArray.insert(bulls, at: 0)
        self.guessTable.reloadData()
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

