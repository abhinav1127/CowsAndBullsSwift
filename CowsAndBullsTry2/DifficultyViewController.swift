//
//  DifficultyViewController.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/19/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    static var difficultyLevel: Int = 0
    
    
    @IBAction func easyDifficultySelected(_ sender: UIButton) {
        DifficultyViewController.difficultyLevel = sender.tag
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
