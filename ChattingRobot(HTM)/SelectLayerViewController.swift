//
//  SelectLayerViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/7/3.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class SelectLayerViewController: UIViewController {
    
    @IBOutlet weak var CortexLayerCountLabel: UILabel!
    @IBOutlet weak var AddLayerBtn: UIButton!
    @IBOutlet weak var SubLayerBtn: UIButton!
    @IBOutlet var LayerButtonsCollection: [UIButton]!
    @IBOutlet weak var StartTrainBtn: UIButton!
    
    private static let defualt_parameter = LayerParameter(cs: 50, llp: 0.5, cc: 5, lat: 0.5, ft: 0.9, wcc: 0.02, iv: 0.1, dv: 0.02)
    
    public var parameters: [LayerParameter] = Array(repeating: defualt_parameter, count: 1)
    
    private var current_layer_count = 1 {
        didSet {
            CortexLayerCountLabel.text = "\(current_layer_count)"
            UpdateLayerButtons()
            
            HTMUD.set(current_layer_count, forKey: "setting_layer_index")
            HTMUD.synchronize()
        }
    }
    
    private let segue = "SetLayerParameters"
    private var HTMUD = UserDefaults.standard
    private var selected_layer_index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let index = HTMUD.object(forKey: "setting_layer_index") {
            current_layer_count = index as! Int
        } else {
            current_layer_count = 1
        }
    
        UserInterfaceSetting()
        
        // Check that the parameters array's count is correct
        if current_layer_count != parameters.count {
            if current_layer_count < parameters.count {
                var pop_count = parameters.count - current_layer_count
                
                while pop_count > 0 {
                    parameters.removeLast()
                    pop_count -= 1
                }
            } else {
                var add_count = current_layer_count - parameters.count
                
                while add_count > 0 {
                    parameters.append(SelectLayerViewController.defualt_parameter)
                    add_count -= 1
                }
            }
        }
                
        for p in parameters {
            print(p)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToLearning" {
            let vc = segue.destination as! LearnCharacterViewController
            vc.LayerParameters = parameters
        } else if segue.identifier == "SetLayerParameters" {
            let vc = segue.destination as! LayerParameterViewController
            vc.current_setting_layer_index = self.selected_layer_index + 1
            vc.parameters = self.parameters
        }
    }
    
    private func UserInterfaceSetting() {
        
        for i in 0..<LayerButtonsCollection.count {
            LayerButtonsCollection[i].layer.cornerRadius = 20
            LayerButtonsCollection[i].layer.borderWidth = 2
            
            var tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton0))
            
            switch i {
            case 0:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.3795632422, green: 0.6642895341, blue: 1, alpha: 1)
            case 1:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.4246346951, green: 0.9187822938, blue: 0.830417037, alpha: 1)
                tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton1))
            case 2:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.4625486732, green: 0.8722721934, blue: 0.1144724861, alpha: 1)
                tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton2))
            case 3:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.9647234082, green: 0.9083223939, blue: 0.01001283247, alpha: 1)
                tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton3))
            case 4:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.9351322055, green: 0.4400249124, blue: 0.3382074833, alpha: 1)
                tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton4))
            case 5:
                LayerButtonsCollection[i].layer.borderColor = #colorLiteral(red: 0.9173390269, green: 0.4065237343, blue: 0.7056174278, alpha: 1)
                tap = UILongPressGestureRecognizer(target: self, action: #selector(TapButton5))
            default:
                print("Index is out of range for setting button")
            }
            
            tap.minimumPressDuration = 0
            LayerButtonsCollection[i].addGestureRecognizer(tap)
            LayerButtonsCollection[i].isUserInteractionEnabled = true
        }
        
        StartTrainBtn.layer.cornerRadius = 15
        StartTrainBtn.layer.borderWidth = 2
        StartTrainBtn.layer.borderColor = CGColor(srgbRed: 235, green: 235, blue: 235, alpha: 1)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(TapStartTrain))
        tap.minimumPressDuration = 0
        StartTrainBtn.addGestureRecognizer(tap)
        StartTrainBtn.isUserInteractionEnabled = true
    }
    
    private func sendParameters() {
        
        if parameters.count != current_layer_count {
            print("Layer count is not corredspoing to the setting!")
            return
        }
        
        performSegue(withIdentifier: "GoToLearning", sender: self)
    }
    
    @objc private func TapButton0(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[0].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[0].backgroundColor = #colorLiteral(red: 0.3795632422, green: 0.6642895341, blue: 1, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[0].setTitleColor(#colorLiteral(red: 0.3795632422, green: 0.6642895341, blue: 1, alpha: 1), for: .normal)
            LayerButtonsCollection[0].backgroundColor = .clear
            selected_layer_index = 0
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapButton1(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[1].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[1].backgroundColor = #colorLiteral(red: 0.4246346951, green: 0.9187822938, blue: 0.830417037, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[1].setTitleColor(#colorLiteral(red: 0.4246346951, green: 0.9187822938, blue: 0.830417037, alpha: 1), for: .normal)
            LayerButtonsCollection[1].backgroundColor = .clear
            selected_layer_index = 1
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapButton2(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[2].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[2].backgroundColor = #colorLiteral(red: 0.4625486732, green: 0.8722721934, blue: 0.1144724861, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[2].setTitleColor(#colorLiteral(red: 0.4625486732, green: 0.8722721934, blue: 0.1144724861, alpha: 1), for: .normal)
            LayerButtonsCollection[2].backgroundColor = .clear
            selected_layer_index = 2
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapButton3(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[3].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[3].backgroundColor = #colorLiteral(red: 0.9647234082, green: 0.9083223939, blue: 0.01001283247, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[3].setTitleColor(#colorLiteral(red: 0.9647234082, green: 0.9083223939, blue: 0.01001283247, alpha: 1), for: .normal)
            LayerButtonsCollection[3].backgroundColor = .clear
            selected_layer_index = 3
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapButton4(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[4].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[4].backgroundColor = #colorLiteral(red: 0.9351322055, green: 0.4400249124, blue: 0.3382074833, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[4].setTitleColor(#colorLiteral(red: 0.9351322055, green: 0.4400249124, blue: 0.3382074833, alpha: 1), for: .normal)
            LayerButtonsCollection[4].backgroundColor = .clear
            selected_layer_index = 4
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapButton5(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            LayerButtonsCollection[5].setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            LayerButtonsCollection[5].backgroundColor = #colorLiteral(red: 0.9173390269, green: 0.4065237343, blue: 0.7056174278, alpha: 1)
        } else if gesture.state == .ended {
            LayerButtonsCollection[5].setTitleColor(#colorLiteral(red: 0.9173390269, green: 0.4065237343, blue: 0.7056174278, alpha: 1), for: .normal)
            LayerButtonsCollection[5].backgroundColor = .clear
            selected_layer_index = 5
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    @objc private func TapStartTrain(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            StartTrainBtn.setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1), for: .normal)
            StartTrainBtn.backgroundColor = UIColor.ParametersBorderColor
        } else if gesture.state == .ended {
            StartTrainBtn.setTitleColor(UIColor.ParametersBorderColor, for: .normal)
            StartTrainBtn.backgroundColor = .clear
            sendParameters()
        }
    }
    
    private func UpdateLayerButtons() {
        for index in 0..<6 {
            if index < current_layer_count {
                LayerButtonsCollection[index].isHidden = false
            } else {
                LayerButtonsCollection[index].isHidden = true
            }
        }
    }
    
    @IBAction func AddLayer(_ sender: UIButton) {
        current_layer_count = (current_layer_count == 6) ? 6 : current_layer_count + 1
        if current_layer_count < 6 {
            parameters.append(SelectLayerViewController.defualt_parameter)
        }
        
        print("after add layer, the layer count is \(parameters.count)")
    }
    
    @IBAction func SubLayer(_ sender: UIButton) {
        current_layer_count = (current_layer_count == 1) ? 1 : current_layer_count - 1
        if current_layer_count > 1 {
            parameters.removeLast()
        }
        
        print("after sub layer, the layer count is \(parameters.count)")
    }
    
    @IBAction func StartTrain(_ sender: UIButton) {
        HTMUD.set(1, forKey: "setting_layer_index")
        HTMUD.synchronize()
    }
}
