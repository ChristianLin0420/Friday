//
//  LearningChattingViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/7.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class LearningChattingViewController: UIViewController, UITextFieldDelegate {
    
    private let LearnCharacter = LearnCharacterViewController()


    @IBOutlet weak var ChattingBlock: UITextView!
    @IBOutlet weak var SendMsgField: UITextField!
    @IBOutlet weak var SendMsgBtn: UIButton!
    @IBOutlet weak var ResponseMsgField: UITextField!
    @IBOutlet weak var ResponseMsgBtn: UIButton!
    
    @IBOutlet weak var AutoTrainBtn: UIButton!
    @IBOutlet weak var AutoModeSwitch: UISwitch!
    @IBOutlet weak var AutoTrainCountSlider: UISlider!
    @IBOutlet weak var AutoTrainCountLabel: UILabel!
    
    // Learning Columns
    public var Characters = [CharacterData]()
    
    private var TrainDatas = [String]()
    private var InputBitMap = Array(repeating: Array(repeating: false, count: InputsSize), count: InputsSize)
                                            
    // Auto Train Parameters
    private let TrainCharacters = ["你", "是", "誰",
                             "我", "是", "人", "工", "智", "慧"]
    private var AutoTrainCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.SendMsgField.delegate = self
        self.ResponseMsgField.delegate = self
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
//    
//    private func PreloadPartCharacters() -> [String] {
//        var result = [String]()
//
//        for i in 0..<TrainCharacters.count {
//            let str = LearnCharacter.EncodindCharacter(char: TrainCharacters[i])
//            result.append(str)
//        }
//
//        return result
//    }
//        
//    private func GenerateAnswerBitMap(characterID: String) {
//        for i in 0...Characters.count {
//            if i == Characters.count {
//                print("Cannot find corresponding unicode!!!")
//                break
//            } else if Characters[i].codeID != characterID {
//                continue
//            } else {
//                for row in 0..<InputsSize {
//                    for col in 0..<InputsSize {
//                        if row < Characters[i].BBX_height, col < Characters[i].BBX_width {
//                            InputBitMap[row][col] = (Characters[i].bitmap[row][col] == 1) ? true : false
//                        } else {
//                            InputBitMap[row][col] = false
//                        }
//                    }
//                }
//                return
//            }
//        }
//    }
//    
//    private func InitailOutput() {
//        for row in 0..<InputsSize {
//            var tempRow_input = [LearningColumn]()
//            for col in 0..<InputsSize {
//                let unit = LearningColumn(x: col, y: row)
//                tempRow_input.append(unit)
//            }
//            self.OutputLayer.append(tempRow_input)
//        }
//    }
//    
//    private func AutoTrain() {
//        var TrainCount: Int = 0
//        
//        while TrainCount > 0 {
//            
//            // Calculate the connected link' count for every column
//            for row in 0..<ColumnsSize {
//                for col in 0..<ColumnsSize {
//                    ColumnOne[row][col].ColumnNetWeight(input: OutputLayer)
//                }
//            }
//            
//            // Find out winner columns
//            let WinnerColumns = SpatialLearning.FindWinningColumns(Columns: ColumnOne)
//            
//            // Activated output layer
//            for row in 0..<ColumnsSize {
//                for col in 0..<ColumnsSize {
//                    if ColumnOne[row][col].Activated() {
//                        OutputLayer = WinnerColumns[row][col].ActivateLinks(LowestLayer: OutputLayer)
//                    }
//                }
//            }
//            
//            for row in 0..<InputsSize {
//                for col in 0..<InputsSize {
//                    OutputLayer[row][col].Activated()
//                }
//            }
//            
//            // Change links' weight and Update boost factor for every winner column
//            ColumnOne = SpatialLearning.WeightChange(Answer: InputBitMap, OutputLayer: OutputLayer, UpperLayer: ColumnOne)
//            ColumnOne = SpatialLearning.UpdateBoostFactor(UpperLayer: ColumnOne)
//            
//            // Temperal Pooling Algorithm
//            (ColumnOne, TPcoeffiecient) = TemperalLearning.EvaluateActiveColumns(layer: ColumnOne, TPcoefficient: TPcoeffiecient)
//            
//            // Reset all training parameters
//            ResetTrain()
//            
//            TrainCount -= 1
//        }
//    }
//    
//    private func ResetTrain() {
//        TPcoeffiecient = TemperalPoolingCoefficient(pwc: [], pac: [],
//                                                    pas: [], pma: [])
//        
//        for row in 0..<InputsSize {
//            for col in 0..<InputsSize {
//                OutputLayer[row][col].Reset()
//            }
//        }
//    }
    
    // ------------------ UI functions ------------------ //
    
    // User trains the columns in person
    @IBAction func SendMsg(_ sender: UIButton) {
        if SendMsgField.text != "" {
            ChattingBlock.text += "Tzuyu: " + SendMsgField.text! + "\n"
            SendMsgField.text = ""
        }
    }
    
    @IBAction func ResponseMsg(_ sender: UIButton) {
        if ResponseMsgField.text != "" {
            ChattingBlock.text += "AI: " + ResponseMsgField.text! + "\n"
            ResponseMsgField.text = ""
        }
    }
    
    // Auto training mode
    @IBAction func AutoTrain(_ sender: UIButton) {
        AutoTrainCount = Int(AutoTrainCountSlider.value)
//        AutoTrain()
    }
    
    @IBAction func AutoTrainMode(_ sender: UISwitch) {
        AutoTrainBtn.isEnabled = AutoModeSwitch.isOn
        AutoTrainCountSlider.isEnabled = AutoModeSwitch.isOn
    }
    
    @IBAction func AutoTrainCountSetting(_ sender: UISlider) {
        sender.value.round()
        AutoTrainCountLabel.text = "\(Int(sender.value))"
    }
}
