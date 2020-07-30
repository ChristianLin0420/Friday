//
//  LayerParameterViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/5/13.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

struct SettingParameter {
    var title: String
    var range: [Int]
    var record: Int
    
    init(title: String, range: [Int], record: Int) {
        self.title = title
        self.range = range
        self.record = record
    }
}

class LayerParameterViewController: UIViewController {
    
    @IBOutlet weak var CurrentValueLabel: UILabel!
    @IBOutlet weak var PercentLabel: UILabel!
    @IBOutlet weak var SettingTitleLabel: UILabel!
    @IBOutlet weak var ValueSlider: UISlider!
    @IBOutlet weak var SliderMinValueLabel: UILabel!
    @IBOutlet weak var SliderMaxValueLabel: UILabel!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet var SettingButtonCollections: [UIButton]!
    
    public var current_setting_layer_index = 0
    public var parameters: [LayerParameter] = []
    
    private var current_setting_index = 0
    private var UIparameters: [SettingParameter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        InitialParameters()
        UserInterfaceSetting()
        
        print("current_setting_layer_index = \(current_setting_layer_index)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BackToSelectLayer" {
            let vc = segue.destination as! SelectLayerViewController
            vc.parameters = self.parameters
        }
    }
    
    private func InitialParameters() {
        let titles = ["Columns Size", "Links Count Ratio", "Cells Count",
                      "Link Activated Threshold", "Fault Tolerrance", "Winner Column Ratio",
                      "Increment Value", "Decrement Value"]
        
        let ranges = [[1, 100], [1, 100], [1, 10], [1, 100], [1, 100], [1, 100], [1, 20], [1, 20]]
        
        for i in 0..<titles.count {
            var record = 0
            
            switch i {
            case 0: record = parameters[current_setting_layer_index - 1].ColumnsSize
            case 1: record = Int(parameters[current_setting_layer_index - 1].LowerLinkPercentage * 100)
            case 2: record = parameters[current_setting_layer_index - 1].CellsCount
            case 3: record = Int(parameters[current_setting_layer_index - 1].LinkActiveThreshold * 100)
            case 4: record = Int(parameters[current_setting_layer_index - 1].FaultTolerance * 100)
            case 5: record = Int(parameters[current_setting_layer_index - 1].WinnerColumnsPercentage * 100)
            case 6: record = Int(parameters[current_setting_layer_index - 1].IncrementValue * 100)
            case 7: record = Int(parameters[current_setting_layer_index - 1].DecrementValue * 100)
            default: print("Index is out of bound!!")
            }
            
            let parameter = SettingParameter(title: titles[i], range: ranges[i], record: record)
            UIparameters.append(parameter)
        }
    }
    
    private func UserInterfaceSetting() {
        for i in 0..<SettingButtonCollections.count {
            SettingButtonCollections[i].layer.cornerRadius = 20
            SettingButtonCollections[i].setTitleColor((i == 0) ? #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1) : #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1) , for: .normal)
            SettingButtonCollections[i].backgroundColor = (i == 0) ? #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            SettingButtonCollections[i].layer.borderWidth = 2
            SettingButtonCollections[i].layer.borderColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        }
        
        ConfirmBtn.layer.borderWidth = 2
        ConfirmBtn.layer.borderColor = CGColor(srgbRed: 235, green: 235, blue: 235, alpha: 1)
        ConfirmBtn.layer.cornerRadius = 20
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(ConfirmButtonGesture))
        tap.minimumPressDuration = 0
        ConfirmBtn.addGestureRecognizer(tap)
        ConfirmBtn.isUserInteractionEnabled = true
        
        UpdateSettingParameterLabels(index: current_setting_index)
    }
    
    @objc private func ConfirmButtonGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            ConfirmBtn.setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            ConfirmBtn.backgroundColor = UIColor.ParametersBorderColor
        } else if gesture.state == .ended {
            ConfirmBtn.setTitleColor(UIColor.ParametersBorderColor, for: .normal)
            ConfirmBtn.backgroundColor = UIColor.ParametersBackgroundColor
            updateLayerParametersSetting()
        }
    }
    
    private func UpdateSettingParameterLabels(index: Int) {
        for i in 0..<SettingButtonCollections.count {
            SettingButtonCollections[i].setTitleColor((i == index) ? #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1) : #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)  , for: .normal)
            SettingButtonCollections[i].backgroundColor = (i == index) ? #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        }
        
        PercentLabel.isHidden = (index != 0 && index != 2) ? false : true
        
        SettingTitleLabel.text = UIparameters[index].title
        CurrentValueLabel.text = "\(UIparameters[index].record)"
        SliderMinValueLabel.text = "\(UIparameters[index].range[0])"
        SliderMaxValueLabel.text = "\(UIparameters[index].range[1])"
        ValueSlider.minimumValue = Float(UIparameters[index].range[0])
        ValueSlider.maximumValue = Float(UIparameters[index].range[1])
        ValueSlider.value = Float(UIparameters[index].record)
    }
    
    private func updateLayerParametersSetting() {
        parameters[current_setting_layer_index - 1].ColumnsSize = UIparameters[0].record
        parameters[current_setting_layer_index - 1].LowerLinkPercentage = Float(UIparameters[1].record) / 100.0
        parameters[current_setting_layer_index - 1].CellsCount = UIparameters[2].record
        parameters[current_setting_layer_index - 1].LinkActiveThreshold = Float(UIparameters[3].record) / 100.0
        parameters[current_setting_layer_index - 1].FaultTolerance = Float(UIparameters[4].record) / 100.0
        parameters[current_setting_layer_index - 1].WinnerColumnsPercentage = Float(UIparameters[5].record) / 100.0
        parameters[current_setting_layer_index - 1].IncrementValue = Float(UIparameters[6].record) / 100.0
        parameters[current_setting_layer_index - 1].DecrementValue = Float(UIparameters[7].record) / 100.0
                
        performSegue(withIdentifier: "BackToSelectLayer", sender: self)
    }
    
    @IBAction func ParametersSetting(_ sender: UIButton) {
        
        for i in 0..<SettingButtonCollections.count {
            if SettingButtonCollections[i] == sender {
                current_setting_index = i
                break
            }
        }
                
        UpdateSettingParameterLabels(index: current_setting_index)
    }
    
    @IBAction func updateValue(_ sender: UISlider) {
        sender.value.round()
        let value = Int(sender.value)
                
        CurrentValueLabel.text = "\(value)"
        UIparameters[current_setting_index].record = value
    }
}


extension UIColor {
    static let ParametersBorderColor = UIColor(red: 235, green: 235, blue: 235, alpha: 1)
    static let ParametersBackgroundColor = UIColor(red: 20, green: 20, blue: 20, alpha: 1)
}
