//
//  TrainingRecordTableViewCell.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/10.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class TrainingRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var LinksCountLabel: UILabel!
    @IBOutlet weak var ColumnActivatedThresoldLabel: UILabel!
    @IBOutlet weak var WinnerColumnsCount: UILabel!
    @IBOutlet weak var LastTrainingDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
