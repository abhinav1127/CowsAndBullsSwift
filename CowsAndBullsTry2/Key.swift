//
//  Key.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 1/16/18.
//  Copyright © 2018 Abhinav Tirath. All rights reserved.
//

import UIKit

class Key: UIButton {

    var isOn: Bool = true

    func changeState() {
        if (isOn) {
            isOn = false
            self.setTitleColor(UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1), for: .normal)
        } else {
            isOn = true
            self.setTitleColor(.blue, for: .normal)

        }
    }
}

