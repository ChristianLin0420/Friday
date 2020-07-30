//
//  RecordTableViewCell.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/28.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var TrainNumber: UILabel!
    @IBOutlet weak var Correctness: UILabel!
    @IBOutlet weak var Match: UILabel!
    @IBOutlet weak var unMatch: UILabel!
    @IBOutlet weak var Wrong: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
