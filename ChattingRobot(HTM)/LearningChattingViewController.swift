//
//  LearningChattingViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/7.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class LearningChattingViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var SearchInput: UITextField!
    @IBOutlet weak var SearchBtn: UIButton!
    
    private let LearnCharacter = LearnCharacterViewController()
    private let Data = DataClassification()
    private let SpacialLearning = HTMSpacialPooling()
    private let TempertalLearning = HTMTemperalPooling()

    public var Cortex: [LayerComponent]? {
        didSet {
            // Since we just obsever the learning result from first layer, therefore, we don't need to care about other layers' condition
            CortexLayerSize = Cortex?[0].layerParameters.ColumnsSize
        }
    }
    
    public var InputLayer = LayerComponent(
                                    layerP: LayerParameter(cs: 24, llp: -1, cc: -1, lat: -1, ft: -1, wcc: -1, iv: -1, dv: -1),
                                    columns: [],
                                    coefficient: TemperalPoolingCoefficient(
                                        pwc: [],
                                        pac: [],
                                        pas: [],
                                        pma: []))
    
    private var CortexLayerSize: Int?
    
    private var OutputLayerSize = 24
    
    private var CortexGraph = [[CAShapeLayer]]()
    private var OutputGraph = [[CAShapeLayer]]()
    
    private var Characters = [CharacterData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Cortex == nil {
            print("[ERROR] There is no segue data from previous view!!!")
            
            SearchInput.isEnabled = false
            SearchBtn.isEnabled = false
        } else {
            UserInterfaceSetting()
            OutputGraphSetting()
            CortexGraphSetting()
            
            Cortex![0].tpCoefficient = TemperalPoolingCoefficient(pwc: [], pac: [], pas: [], pma: [])
            
            Characters = Data.scanBDFdata()
        }
    }
    
    // MARK: - User Interface Setting
    
    private func UserInterfaceSetting() {
        // Textfield setting
        SearchInput.layer.borderColor = UIColor.clear.cgColor
        SearchInput.delegate = self
        
        // Button setting
        SearchBtn.tintColor = .yellow
        SearchBtn.layer.borderColor = UIColor.yellow.cgColor
        SearchBtn.layer.borderWidth = 1.5
        SearchBtn.layer.cornerRadius = 10
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(SearchBtnControl))
        tap.minimumPressDuration = 0
        SearchBtn.addGestureRecognizer(tap)
        SearchBtn.isUserInteractionEnabled = true
    }
    
    @objc private func SearchBtnControl(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            SearchBtn.backgroundColor = .yellow
            SearchBtn.tintColor = .darkGray
        } else if gesture.state == .ended {
            SearchBtn.backgroundColor = .clear
            SearchBtn.tintColor = .yellow
            
            Predict()
        }
    }
    
    private func OutputGraphSetting() {
        let minX = self.view.frame.width * 0.1
        let maxX = self.view.frame.width * 0.9
        let minY = minX
        let interval = (maxX - minX) / CGFloat(OutputLayerSize - 1)
        
        for row in 0..<OutputLayerSize {
            var tempArray = [CAShapeLayer]()
            
            for col in 0..<OutputLayerSize {
                let center = CGPoint(x: minX + interval * CGFloat(col), y: minY + interval * CGFloat(row))
                let circlePath = UIBezierPath(
                    arcCenter: center,
                    radius: interval * 0.4,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = circlePath.cgPath
                
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = UIColor.gray.cgColor
                shapeLayer.lineWidth = 1.0
                
                tempArray.append(shapeLayer)
                self.view.layer.addSublayer(shapeLayer)
            }
            
            OutputGraph.append(tempArray)
        }
    }
    
    private func CortexGraphSetting() {
        let minX = self.view.frame.width * 0.05
        let maxX = self.view.frame.width * 0.95
        let minY = minX * 0.01 + self.view.frame.midY
        let interval = (maxX - minX) / CGFloat(CortexLayerSize! - 1)
        
        for row in 0..<CortexLayerSize! {
            var tempArray = [CAShapeLayer]()
            
            for col in 0..<CortexLayerSize! {
                let center = CGPoint(x: minX + interval * CGFloat(col), y: minY + interval * CGFloat(row))
                let circlePath = UIBezierPath(
                    arcCenter: center,
                    radius: interval * 0.4,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = circlePath.cgPath
                
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = UIColor.gray.cgColor
                shapeLayer.lineWidth = 1.0
                
                tempArray.append(shapeLayer)
                self.view.layer.addSublayer(shapeLayer)
            }
            
            CortexGraph.append(tempArray)
        }
    }
    
    
    // MARK: - Intents
    
    private func GenerateAnswerBitMap(id: String) {

        for i in Characters.indices {
            if i == Characters.count {
                print("Cannot find corresponding unicode!!!")
                break
            } else if Characters[i].codeID != id {
                continue
            } else {
                for row in 0..<OutputLayerSize {
                    for col in 0..<OutputLayerSize {
                        if row < Characters[i].BBX_height, col < Characters[i].BBX_width {
                            InputLayer.columns[row][col].isActiveForward = Characters[i].bitmap[row][col] == 1
                        } else {
                            InputLayer.columns[row][col].isActiveForward = false
                        }
                    }
                }
                
                return
            }
        }
    }
    
    private func Predict() {
        guard let character = SearchInput.text else { return }
        
        let stringID = LearnCharacter.EncodindCharacter(char: character)
        
        GenerateAnswerBitMap(id: stringID)
        
        let CurrentLayerSize = Cortex![0].layerParameters.ColumnsSize
        
        // Calculate the connected links' count for every column
        for row in 0..<CurrentLayerSize {
            for col in 0..<CurrentLayerSize {
                let threshold = Cortex![0].layerParameters.LinkActiveThreshold
                Cortex![0].columns[row][col].ForwardActivation(for: InputLayer.columns, with: threshold)
            }
        }
        
        // Find winner columns according to the inhibition radiuss
        let WinnerColumns = SpacialLearning.NeighborOverlap(for: Cortex![0].columns, with: CurrentLayerSize, radius: 5)
        
        // Replace current layer with winner columns
        Cortex![0].columns = WinnerColumns
                    
        // Temperal Pooler
        Cortex![0] = TempertalLearning.EvalauteActiveColumns(for: Cortex![0], trainCount: 2, enable_learning: true)

        let preactiveSegments = Cortex![0].tpCoefficient.preActiveDendrites
        
        var ColumnsGraph = Array(repeating: Array(repeating: false, count: CortexLayerSize!), count: CortexLayerSize!)
        
        for row in 0..<CortexLayerSize! {
            for col in 0..<CortexLayerSize! {
                if WinnerColumns[row][col].isActiveForward {
                    CortexGraph[row][col].fillColor = UIColor.orange.cgColor
                }
            }
        }
        
        print("preactiveSegments count is \(preactiveSegments.count)")
        
        if !preactiveSegments.isEmpty {
            for d in preactiveSegments {
                let x = d.Coordinate.first
                let y = d.Coordinate.second
                
                ColumnsGraph[y][x] = true
            }
            
            for row in 0..<CortexLayerSize! {
                for col in 0..<CortexLayerSize! {
                    if ColumnsGraph[row][col] {
                        
                        if WinnerColumns[row][col].isActiveForward {
                            CortexGraph[row][col].fillColor = UIColor.white.cgColor
                        } else {
                            CortexGraph[row][col].fillColor = UIColor.green.cgColor
                        }
                        
                        Cortex![0].columns[row][col].isActiveForward = true
                    } else {
                        
                        if WinnerColumns[row][col].isActiveForward {
                            CortexGraph[row][col].fillColor = UIColor.red.cgColor
                        }
                        
                        Cortex![0].columns[row][col].isActiveForward = false
                    }
                }
            }
        }
        
        
        for row in 0..<CortexLayerSize! {
            for col in 0..<CortexLayerSize! {
                let threshold = Cortex![0].layerParameters.LinkActiveThreshold
                
                InputLayer.columns = Cortex![0].columns[row][col].BackwardActivation(for: InputLayer.columns, with: threshold)
            }
        }
        
        for row in 0..<OutputLayerSize {
            for col in 0..<OutputLayerSize {
                InputLayer.columns[row][col].UpperToLowerActivated()
            }
        }
        
        for row in 0..<OutputLayerSize {
            for col in 0..<OutputLayerSize {
                if InputLayer.columns[row][col].isActiveBackward {
                    OutputGraph[row][col].fillColor = UIColor.orange.cgColor
                }
            }
        }
    }
}
