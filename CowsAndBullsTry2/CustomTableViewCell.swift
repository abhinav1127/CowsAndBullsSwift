//
//  CustomTableViewCell.swift
//  CowsAndBullsTry2
//
//  Created by Abhinav Tirath on 12/5/17.
//  Copyright © 2017 Abhinav Tirath. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var wordLbl: UILabel!
    @IBOutlet weak var cowsLbl: UILabel!
    @IBOutlet weak var bullsLbl: UILabel!
    @IBOutlet weak var CustomTableViewCell: CustomTableViewCell!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
