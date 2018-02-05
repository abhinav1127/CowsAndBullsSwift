//
//  Bubble.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 1/31/18.
//  Copyright © 2018 Abhinav Tirath. All rights reserved.
//

import UIKit

class Bubble: UIButton {

    static var numOn = 4
    var isOn: Bool = true

    func changeState() {
        if (isOn) {
            Bubble.numOn -= 1
            isOn = false
            self.backgroundColor = UIColor.gray
        } else {
            Bubble.numOn += 1
            isOn = true
            self.backgroundColor = GameViewController.ice
            
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
