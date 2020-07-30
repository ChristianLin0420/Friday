//
//  LearningParameterSettingViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/5.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class LearningParameterSettingViewController: UIViewController {

    @IBOutlet weak var LinksCountSlider: UISlider!
    @IBOutlet weak var LinksCountLabel: UILabel!
    @IBOutlet weak var CellsCountSlider: UISlider!
    @IBOutlet weak var CellsCountLabel: UILabel!
    @IBOutlet weak var ColumnActivatedThresholdSlider: UISlider!
    @IBOutlet weak var ColumnActivatedThresholdLabel: UILabel!
    @IBOutlet weak var LinkActivatedThresholdSlider: UISlider!
    @IBOutlet weak var LinkActivatedThresholdLabel: UILabel!
    @IBOutlet weak var FaultTolerranceSlider: UISlider!
    @IBOutlet weak var FaultTolerranceLabel: UILabel!
    @IBOutlet weak var WinnerColumnsCountSlider: UISlider!
    @IBOutlet weak var WinnerColumnsCountLabel: UILabel!
    @IBOutlet weak var IncrementValueSlider: UISlider!
    @IBOutlet weak var IncrementValueLabel: UILabel!
    @IBOutlet weak var DecrementValueSlider: UISlider!
    @IBOutlet weak var DecrementValueLabel: UILabel!
    @IBOutlet weak var TrainningDataMode: UISwitch!

    public var SettingLayerIndex: Int = -1
    public var BackSegue: String = "BackToLayerSetting"
    
    private let HTMUD = UserDefaults.standard
    private var LinksCount = 20
    private var CellsCount = 6
    private var ColumnActivatedThreshold = 25
    private var LinkActivatedThreshold = 50
    private var FaultTolerrance = 5
    private var WinnerColumnsCount = 20
    private var IncrementValue = 5
    private var DecrementValue = 1
    private var TrainningData = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PreloadParameters()
    }
    
    private func PreloadParameters() {
        if let count = HTMUD.object(forKey: "LinksCount") { LinksCount = count as! Int }
        if let count = HTMUD.object(forKey: "CellsCount") { CellsCount = count as! Int }
        if let threshold = HTMUD.object(forKey: "CAT") { ColumnActivatedThreshold = threshold as! Int }
        if let threshold = HTMUD.object(forKey: "LAT") { LinkActivatedThreshold = threshold as! Int }
        if let tolerrance = HTMUD.object(forKey: "FaultTolerrance") { FaultTolerrance = tolerrance as! Int }
        if let data = HTMUD.object(forKey: "TrainningData") { TrainningData = data as! Bool }
        if let count = HTMUD.object(forKey: "WCC") { WinnerColumnsCount = count as! Int }
        if let count = HTMUD.object(forKey: "IncrementValue") { IncrementValue = count as! Int }
        if let count = HTMUD.object(forKey: "DecrementValue") { DecrementValue = count as! Int }
        
        LinksCountLabel.text = "\(LinksCount)"
        CellsCountLabel.text = "\(CellsCount)"
        ColumnActivatedThresholdLabel.text = "\(ColumnActivatedThreshold)"
        LinkActivatedThresholdLabel.text = "\(LinkActivatedThreshold)"
        FaultTolerranceLabel.text = "\(FaultTolerrance)"
        WinnerColumnsCountLabel.text = "\(WinnerColumnsCount)"
        IncrementValueLabel.text = "\(IncrementValue)"
        DecrementValueLabel.text = "\(DecrementValue)"
        
        LinksCountSlider.value = Float(LinksCount)
        CellsCountSlider.value = Float(CellsCount)
        ColumnActivatedThresholdSlider.value = Float(ColumnActivatedThreshold)
        LinkActivatedThresholdSlider.value = Float(LinkActivatedThreshold)
        FaultTolerranceSlider.value = Float(FaultTolerrance)
        WinnerColumnsCountSlider.value = Float(WinnerColumnsCount)
        IncrementValueSlider.value = Float(IncrementValue)
        DecrementValueSlider.value = Float(DecrementValue)
        TrainningDataMode.isOn = TrainningData
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "GoToLearning":
            let vc = segue.destination as! LearnCharacterViewController
            vc.SegueName = "BackToPS"
            break
        default:
            break
        }
    }
    
    @IBAction func LinksCount(_ sender: UISlider) {
        sender.value.round()
        LinksCount = Int(sender.value)
        LinksCountLabel.text = Int(sender.value).description
    }
    
    @IBAction func CellsCount(_ sender: UISlider) {
        sender.value.round()
        CellsCount = Int(sender.value)
        CellsCountLabel.text = Int(sender.value).description
    }
    
    @IBAction func ColumnActivatedThreshold(_ sender: UISlider) {
        sender.value.round()
        ColumnActivatedThreshold = Int(sender.value)
        ColumnActivatedThresholdLabel.text = Int(sender.value).description
    }
    
    @IBAction func LinkAcrivatedThreshold(_ sender: UISlider) {
        sender.value.round()
        LinkActivatedThreshold = Int(sender.value)
        LinkActivatedThresholdLabel.text = Int(sender.value).description
    }
    
    @IBAction func FaultTolerrance(_ sender: UISlider) {
        sender.value.round()
        FaultTolerrance = Int(sender.value)
        FaultTolerranceLabel.text = Int(sender.value).description
    }
    
    @IBAction func WinnerColumnsCount(_ sender: UISlider) {
        sender.value.round()
        WinnerColumnsCount = Int(sender.value)
        WinnerColumnsCountLabel.text = Int(sender.value).description
    }
    
    @IBAction func IncrementValue(_ sender: UISlider) {
        sender.value.round()
        IncrementValue = Int(sender.value)
        IncrementValueLabel.text = Int(sender.value).description
    }
    
    @IBAction func DecrementValue(_ sender: UISlider) {
        sender.value.round()
        DecrementValue = Int(sender.value)
        DecrementValueLabel.text = Int(sender.value).description
    }
    
    @IBAction func TrainnningDataMode(_ sender: UISwitch) {
        TrainningData = sender.isOn
    }
    
    @IBAction func GoToLearning(_ sender: UIButton) {
        HTMUD.set(LinksCount, forKey: "LinksCount")
        HTMUD.set(CellsCount, forKey: "CellsCount")
        HTMUD.set(ColumnActivatedThreshold, forKey: "CAT")
        HTMUD.set(LinkActivatedThreshold, forKey: "LAT")
        HTMUD.set(FaultTolerrance, forKey: "FaultTolerrance")
        HTMUD.set(TrainningData, forKey: "TrainningData")
        HTMUD.set(WinnerColumnsCount, forKey: "WCC")
        HTMUD.set(IncrementValue, forKey: "IncrementValue")
        HTMUD.set(DecrementValue, forKey: "DecrementValue")
        HTMUD.set(0, forKey: "CurrentTrainIndex")
        HTMUD.synchronize()
        
        performSegue(withIdentifier: "GoToLearning", sender: self)
    }
    
    @IBAction func Back(_ sender: UIButton) {
        performSegue(withIdentifier: BackSegue, sender: self)
    }
}
