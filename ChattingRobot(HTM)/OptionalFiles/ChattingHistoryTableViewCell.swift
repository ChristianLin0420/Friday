//
//  ChattingHistoryTableViewCell.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2019/9/6.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit

class ChattingHistoryTableViewCell: UITableViewCell {
    
    // cell elements
    @IBOutlet weak var Indicator: UILabel!
    @IBOutlet weak var AI_img: UIImageView!
    @IBOutlet weak var AI_name: UILabel!
    @IBOutlet weak var LastComment: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
