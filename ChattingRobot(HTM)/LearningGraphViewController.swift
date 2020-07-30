//
//  LearningGraphViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/5.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class LearningGraphViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var RecordGraph: ShowResult!
    @IBOutlet weak var SearchCharacterField: UITextField!
    @IBOutlet weak var Search: UIButton!
    @IBOutlet weak var RecordTable: UITableView!
    
    @IBOutlet weak var CorrectBtn: UIButton!
    @IBOutlet weak var MatchBtn: UIButton!
    @IBOutlet weak var unMatchBtn: UIButton!
    @IBOutlet weak var WrongBtn: UIButton!
    
    // Files
    private let CharacterVC = LearnCharacterViewController()
    
    // Graph
    private var showCorrect = true
    private var showMatch = false
    private var showUnMatch = false
    private var showWrong = false
    private var dataIndex = -1
    
    // Character info
    public var CharacterID = ""
    public var TrainRecord = [Correctness]()
    public var CharactersTrainningRecord = [CharacterTrainningRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.SearchCharacterField.delegate = self
        self.RecordTable.delegate = self
    }
    
    private func ShowTrainningRecord(id: String) {
        var data = [Correctness]()
        
        for char in CharactersTrainningRecord {
            if char.codeID == id {
                data = char.FaultRecord
                TrainRecord = data
                break
            }
        }
        
        if data.isEmpty { return }

        UpdateLineChart()
    }
    
    private func UpdateLineChart() {
        RecordGraph.showCorrect = showCorrect
        RecordGraph.showMatch = showMatch
        RecordGraph.showUnMatch = showUnMatch
        RecordGraph.showWrong = showWrong
        RecordGraph.CharacterID = CharacterID
        RecordGraph.TrainRecord = TrainRecord
        RecordGraph.showDataIndex = dataIndex
        RecordGraph.setNeedsDisplay()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrainRecord.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Record", for: indexPath) as! RecordTableViewCell
        let index = indexPath.row
        
        cell.TrainNumber.text = "\(index + 1)"
        cell.Correctness.text = "\(TrainRecord[index].CorrectPercentage)"
        cell.Match.text = "\(TrainRecord[index].MatchCount)"
        cell.unMatch.text = "\(TrainRecord[index].NotMatchCount)"
        cell.Wrong.text = "\(TrainRecord[index].WrongCount)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataIndex = indexPath.row
        
        UpdateLineChart()
    }
    
    @IBAction func ShowTrainningRecord(_ sender: UIButton) {
        if let Msg = SearchCharacterField.text, SearchCharacterField.text != "" {
            CharacterID = CharacterVC.EncodindCharacter(char: Msg)
            
            if CharacterID != "" {
                ShowTrainningRecord(id: CharacterID)
            } else {
                print("Cannot find the record of \(Msg)")
            }
        } else {
            CharacterID = ""
            TrainRecord.removeAll()
            print("No Character Input!")
        }
        
        dataIndex = -1
        UpdateLineChart()
        RecordTable.reloadData()
    }
    
    @IBAction func ShowCorrectRecord(_ sender: UIButton) {
        showCorrect = !showCorrect
        
        if showCorrect { CorrectBtn.setImage(UIImage(named: "Show"), for: .normal) }
        else { CorrectBtn.setImage(UIImage(named: "notShow"), for: .normal) }
        
        UpdateLineChart()
    }
    
    @IBAction func ShowMatchRecord(_ sender: UIButton) {
        showMatch = !showMatch
        
        if showMatch { MatchBtn.setImage(UIImage(named: "Show"), for: .normal) }
        else { MatchBtn.setImage(UIImage(named: "notShow"), for: .normal) }
        
        UpdateLineChart()
    }
    
    @IBAction func ShowUnMatchRecord(_ sender: UIButton) {
        showUnMatch = !showUnMatch
        
        if showUnMatch { unMatchBtn.setImage(UIImage(named: "Show"), for: .normal) }
        else { unMatchBtn.setImage(UIImage(named: "notShow"), for: .normal) }
        
        UpdateLineChart()
    }
    
    @IBAction func ShowWrongRecord(_ sender: UIButton) {
        showWrong = !showWrong
        
        if showWrong { WrongBtn.setImage(UIImage(named: "Show"), for: .normal) }
        else { WrongBtn.setImage(UIImage(named: "notShow"), for: .normal) }
        
        UpdateLineChart()
    }
}
