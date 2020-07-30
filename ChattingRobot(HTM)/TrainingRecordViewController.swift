//
//  TrainingRecordViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/10.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class TrainingRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TrainingRecordTable: UITableView!
    
    private let CharRecord = CharacterRecord()
    private let trainRecord = Record()
    
    // Cell information
    private let cellID = "Cell"
    private var RecordDetails = [RecordDetail]()
    private var SelectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.RecordDetails = self.trainRecord.GetTrainingRecordDetail()
            print("RecordDetails.count = \(self.RecordDetails.count)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "GoToLearning":
            let vc = segue.destination as! LearnCharacterViewController
            vc.SegueName = "BackToRecord"
            vc.RecordIndex = SelectIndex
        default:
            print("Segue is inValid!")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(113)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainRecord.getCurrentTrainRecordCount()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectIndex = indexPath.row
        performSegue(withIdentifier: "GoToLearning", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CharRecord.DeleteCharactersRecord(index: indexPath.row)
            TrainingRecordTable.reloadData()
            if trainRecord.getCurrentTrainRecordCount() == 0 {
                performSegue(withIdentifier: "BackToMenu", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TrainingRecordTableViewCell
        cell.LinksCountLabel.text = "\(RecordDetails[indexPath.row].LC)"
        cell.ColumnActivatedThresoldLabel.text = "\(RecordDetails[indexPath.row].CAT)"
        cell.WinnerColumnsCount.text = "\(RecordDetails[indexPath.row].WCC)"
        cell.LastTrainingDate.text = "\(RecordDetails[indexPath.row].Date)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselect \(indexPath.row) row!")
    }
}
