//
//  TrainningMenuViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/10.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class TrainningMenuViewController: UIViewController {
    
    @IBOutlet weak var CreateNewTrain: UIButton!
    @IBOutlet weak var ShowTrainingRecord: UIButton!
    
    let trainRecord = Record()

    override func viewDidLoad() {
        super.viewDidLoad()

        if trainRecord.getCurrentTrainRecordCount() > 0 {
            ShowTrainingRecord.isEnabled = true
        } else {
            print("There is no data in CoreData!")
        }
    }
}
