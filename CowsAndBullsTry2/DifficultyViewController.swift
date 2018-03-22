//
//  DifficultyViewController.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/19/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    var difficultyLevel: String?
    
    @IBAction func DifficultySelected(_ sender: UIButton) {
        difficultyLevel = sender.titleLabel?.text
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier == "Easy" || segue.identifier == "Medium" || segue.identifier == "Hard" || segue.identifier == "veryHard" {
            let navController = segue.destination as! UINavigationController
            let gameviewController = navController.topViewController as! GameViewController
            gameviewController.difficultyLevel = self.difficultyLevel
            print("text: \(gameviewController.difficultyLevel)")
        }
        
        print("what")
    }

}
