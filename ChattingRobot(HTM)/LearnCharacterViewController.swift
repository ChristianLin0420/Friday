//
//  LearnCharacterViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/3.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class LearnCharacterViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var SaveColumnsData: UIButton!
    @IBOutlet weak var ShowParametersBtn: UIButton!
    @IBOutlet weak var InputField: UITextField!
    @IBOutlet weak var SearchWord: UIButton!
    @IBOutlet weak var ShowGraph: UIButton!
    @IBOutlet weak var SendMsg: UIButton!
    @IBOutlet weak var Match: UILabel!
    @IBOutlet weak var UnMatch: UILabel!
    @IBOutlet weak var Wrong: UILabel!
    @IBOutlet weak var CorrectRate: UILabel!
    @IBOutlet weak var TrainningCount: UILabel!
    @IBOutlet weak var TrainningSlider: UISlider!
    @IBOutlet weak var AutoTrainning: UISwitch!
    @IBOutlet weak var CurrentTrainingLeftCount: UILabel!
    
    @IBOutlet weak var SavingColumnsView: UIImageView!
    @IBOutlet weak var ConfirmLabel: UILabel!
    @IBOutlet weak var ConfirmBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    
    @IBOutlet weak var Loading: UIActivityIndicatorView!
    
    // View Constraint
    private var width: CGFloat = 0.0
    private var height: CGFloat = 0.0
    private var midX: CGFloat = 0.0
    private var midY: CGFloat = 0.0
    
    // Data file
    private let Data = DataClassification()
    private let SpacialLearning = HTMSpacialPooling()
    private let TempertalLearning = HTMTemperalPooling()
    private let CharRecord = CharacterRecord()
    private let trainRecord = Record()
    private let HTMUD = UserDefaults.standard
    
    // Dot Matrix parameters
    private var DotMatrix = [[CAShapeLayer]]()
    
    // Characters Data
    private var Characters = [CharacterData]()
    private var CharactersTrainningRecord = [CharacterTrainningRecord]()
    private var CommonlyUsedCharacters = [String]()
    private var CharactersBitMap = Array(repeating: Array(repeating: false, count: InputsSize), count: InputsSize)
    
    // Learning parameters
    public var LayerParameters = [LayerParameter]()
    private var ColumnsLayer = [[miniColumn]]()
    private var Cortex = [LayerComponent]()
    private var CortexLayerCount: Int = -1
    private var TrainCount = 5
    private var InhibitRadius = 5
    
    // Learning state
    private var isStop = false
    private var isAuto = false
    private var isAllCharacters: Bool {
        if let mode = HTMUD.object(forKey: "TrainningData") {
            return mode as! Bool
        } else {
            return false
        }
    }
    private var CodeID = ""
    
    // Trainning Timer
    private var timer = Timer()
    private var currentTrainCount = CurrentTrainIndex
    private var temp_trainCount = 0
    
    // Segue
    public var SegueName = "BackToLayerSetting"
    public var RecordIndex = -1
    
    // Original Input Layer
    private var InputLayer = LayerComponent(
                                layerP: LayerParameter(cs: 24, llp: -1, cc: -1, lat: -1, ft: -1, wcc: -1, iv: -1, dv: -1),
                                columns: [],
                                coefficient: TemperalPoolingCoefficient(
                                    pwc: [],
                                    pac: [],
                                    pas: [],
                                    pma: []))
    
    private var InputFrequencyArray = Array(repeating: Array(repeating: 0, count: 24), count: 24)
    private let OriginalInputSize: Int = 24
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        if SegueName == "BackToRecord" { ShowParametersBtn.isEnabled = true }
        
        width = self.view.frame.width
        height = self.view.frame.height
        midX = self.view.frame.midX
        midY = self.view.frame.midY
        
        InitialConfirmView()
        
        let _ = Data.ReadArticle()
        
        self.InputField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            self.Characters = self.Data.scanBDFdata()   // Preload the Bitmap of all characters
            self.CortexLayerCount = self.LayerParameters.count
            
            if self.SegueName == "BackToRecord", self.RecordIndex != -1 {   // From Training record tableview to this view, therefore, preloading coredata
                print("It's loading \(self.RecordIndex)-th record!")
                //self.Cortex = self.trainRecord.FetchOldRecord(RecordIndex: self.RecordIndex)
                self.CharactersTrainningRecord = self.CharRecord.FetchCharactersRecord(index: self.RecordIndex)
            } else {
                print("It's creating new Columns!")
                self.InitialCortex()
            }
            
            if !self.isAllCharacters {
                let charactersChart = self.Data.ReadChart()
                self.CommonlyUsedCharacters = Array(charactersChart[0..<100])
                self.CommonlyUsedCharacters = self.PreloadPartCharacters()
            }
            
            self.InitialDotGraph()
            
            if self.SegueName == "BackToRecord", self.RecordIndex != -1 {
                for row in 0..<self.OriginalInputSize {
                    var tempRow_input = [miniColumn]()
                    for col in 0..<self.OriginalInputSize {
                        let unit = miniColumn(coordinate: Pair(first: col, second: row))
                        tempRow_input.append(unit)
                    }
                    //self.InputLayer.columns.append(tempRow_input)
                }
            }
            
            group.leave()
        }
                
        group.notify(queue: .main) {
            print("All objects have been loaded!!")
            print("Cortex count is \(self.Cortex.count)")
            self.Loading.stopAnimating()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowGraph":
            let vc = segue.destination as! LearningGraphViewController
            vc.CharactersTrainningRecord = self.CharactersTrainningRecord
//        case "goToChat":
//            let vc = segue.destination as! LearningChattingViewController
//            vc.ColumnOne = ColumnsLayer
        default:
            print("Segue is Back mode!")
        }
    }
    
    private func InitialConfirmView() {
        SavingColumnsView.alpha = 0.0
        SavingColumnsView.frame = CGRect(x: 0, y: 0, width: width * 0.95, height: height * 0.1)
        SavingColumnsView.center = CGPoint(x: midX , y: 0)
        
        ConfirmLabel.alpha = 0.0
        ConfirmLabel.frame = CGRect(x: 0, y: 0, width: width * 0.8, height: height * 0.05)
        ConfirmLabel.center = CGPoint(x: midX * 0.9 , y: 0)
        
        ConfirmBtn.alpha = 0.0
        ConfirmBtn.frame = CGRect(x: 0, y: 0, width: width * 0.2, height: height * 0.04)
        ConfirmBtn.center = CGPoint(x: midX * 1.3 , y: midY * 0.05)
        
        CancelBtn.alpha = 0.0
        CancelBtn.frame = CGRect(x: 0, y: 0, width: width * 0.2, height: height * 0.04)
        CancelBtn.center = CGPoint(x: midX * 1.7 , y: midY * 0.05)
    }
    
    private func SavingColumnsView(isHidden: Bool) {
        if !isHidden {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1.0,
                delay: 0.0,
                options: [],
                animations: {
                    self.SavingColumnsView.alpha = 1.0
                    self.SavingColumnsView.frame = CGRect(x: 0, y: 0, width: self.width * 0.95, height: self.height * 0.09)
                    self.SavingColumnsView.center = CGPoint(x: self.midX , y: self.midY * 0.27)
                    
                    self.ConfirmLabel.alpha = 1.0
                    self.ConfirmLabel.frame = CGRect(x: 0, y: 0, width: self.width * 0.8, height: self.height * 0.08)
                    self.ConfirmLabel.center = CGPoint(x: self.midX * 0.9 , y: self.midY * 0.25)
                    
                    self.ConfirmBtn.alpha = 1.0
                    self.ConfirmBtn.frame = CGRect(x: 0, y: 0, width: self.width * 0.3, height: self.height * 0.04)
                    self.ConfirmBtn.center = CGPoint(x: self.midX * 1.3 , y: self.midY * 0.32)
                    
                    self.CancelBtn.alpha = 1.0
                    self.CancelBtn.frame = CGRect(x: 0, y: 0, width: self.width * 0.3, height: self.height * 0.04)
                    self.CancelBtn.center = CGPoint(x: self.midX * 1.7 , y: self.midY * 0.32)
                },
                completion: nil)
        } else {
            InitialConfirmView()
        }
    }
    
    public func EncodindCharacter(char: String) -> String {
        let str = char
        let dataenc = str.data(using: String.Encoding.nonLossyASCII)
        
        if let  encodevalue = String(data: dataenc!, encoding: String.Encoding.utf8) {
            let removeCharaters = ["u"]
        
            if encodevalue.contains("u") {
                var temp = encodevalue
                
                if let i = encodevalue.firstIndex(of: Character(removeCharaters[0])) { temp.remove(at: i) }
                
                let result = temp.dropFirst().uppercased()

                return result
            }
            return ""
        } else {
            return ""
        }
    }
    
    private func InitialCortex() {
        if CortexLayerCount == -1 {
            print("[InitialCortex] Layer count is not correct!")
        } else {
            for layerIndex in 0..<CortexLayerCount {
                let layerColumnCellsCount = LayerParameters[layerIndex].CellsCount
                let layerColumnSize = LayerParameters[layerIndex].ColumnsSize
                let newLayerParameters = LayerParameters[layerIndex]
                var newLayerColumns: [[miniColumn]] = []
                var newLayer = LayerComponent(layerP: newLayerParameters,
                                              columns: [[]],
                                              coefficient: TemperalPoolingCoefficient(
                                                                            pwc: [],
                                                                            pac: [],
                                                                            pas: [],
                                                                            pma: []))
                
                print("layerColumnSize is \(layerColumnSize)")
                print("layerCellsCount is \(layerColumnCellsCount)")
                
                // Initial layer's columns according to the given parameters
                for row in 0..<layerColumnSize {
                    var tempRowColumn = [miniColumn]()
                    for col in 0..<layerColumnSize {
                        let lowerSize = (layerIndex == 0) ? OriginalInputSize : LayerParameters[layerIndex - 1].ColumnsSize
                        let upperSize = LayerParameters[layerIndex].ColumnsSize
                        
                        let column = miniColumn(coordinate: Pair(first: col, second: row),
                                                radius: InhibitRadius,
                                                size_l: lowerSize,
                                                size_u: upperSize,
                                                count: layerColumnCellsCount)
                        
                        if layerIndex < 0 {
                            print("[InitialCortex] Layer index is out of bound!")
                        }
                                                
                        tempRowColumn.append(column)
                    }
                    newLayerColumns.append(tempRowColumn)
                }
                
                newLayer.columns = newLayerColumns                
                Cortex.append(newLayer)
            }
                        
            // Initial original input layer
            for row in 0..<OriginalInputSize {
                var tempRow_input = [miniColumn]()
                for col in 0..<OriginalInputSize {
                    let unit = miniColumn(coordinate: Pair(first: col, second: row))
                    tempRow_input.append(unit)
                }
                self.InputLayer.columns.append(tempRow_input)
            }
        }
    }
    
    private func InitialDotGraph() {
        let H_safeWidth = self.view.frame.width * 0.04
        let V_safeHeight = InputField.frame.minY * 0.03
        
        for row in 0..<InputsSize {
            var OneDimenstionalDotArray = [CAShapeLayer]()
            for col in 0..<InputsSize {
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.frame.midX * 0.1 + H_safeWidth * CGFloat(col),y: self.view.frame.midY * 0.25 + V_safeHeight * CGFloat(row)), radius: CGFloat(5), startAngle: CGFloat(0), endAngle: CGFloat(Float.pi * 2), clockwise: true)

                let shapeLayer = CAShapeLayer()
                shapeLayer.path = circlePath.cgPath

                shapeLayer.fillColor =  UIColor.clear.cgColor
                shapeLayer.strokeColor = CGColor.init(srgbRed: 1, green: 1, blue: 1, alpha: 0.5)
                shapeLayer.lineWidth = 1.0
                
                OneDimenstionalDotArray.append(shapeLayer)
                view.layer.addSublayer(shapeLayer)
            }
            DotMatrix.append(OneDimenstionalDotArray)
        }
    }
    
    private func PreloadPartCharacters() -> [String] {
        var result = [String]()

//        let ChineseWords = ["我", "的", "名", "字", "是", "林", "柏", "均", "今", "年", "二", "十", "歲"]
        let Phrase = ["立", "刻"]

        for i in 0..<Phrase.count {
            let str = EncodindCharacter(char: Phrase[i])
            result.append(str)
        }

        return result
    }
    
    private func GenerateAnswerBitMap(characterID: String) {
        for row in 0..<OriginalInputSize {
            for col in 0..<OriginalInputSize {
                DotMatrix[row][col].fillColor = UIColor.clear.cgColor
                InputLayer.columns[row][col].ResetValue()
            }
        }
        
        for i in 0...Characters.count {
            if i == Characters.count {
                print("Cannot find corresponding unicode!!!")
                break
            } else if Characters[i].codeID != characterID {
                continue
            } else {
                for row in 0..<OriginalInputSize {
                    for col in 0..<OriginalInputSize {
                        if row < Characters[i].BBX_height, col < Characters[i].BBX_width {
                            CharactersBitMap[row][col] = Characters[i].bitmap[row][col] == 1
                            InputLayer.columns[row][col].isActiveForward = Characters[i].bitmap[row][col] == 1
                            InputFrequencyArray[row][col] = (Characters[i].bitmap[row][col] == 1) ? InputFrequencyArray[row][col] + 1 : InputFrequencyArray[row][col]
                        } else {
                            CharactersBitMap[row][col] = false
                            InputLayer.columns[row][col].isActiveForward = false
                        }
                    }
                }
                return
            }
        }
    }
    
    private func UISetting(isValid: Bool) {
        InputField.isEnabled = isValid
        SearchWord.isEnabled = isValid
        AutoTrainning.isEnabled = isValid
        TrainningSlider.isEnabled = isValid
        ShowGraph.isEnabled = isValid
        SaveColumnsData.isEnabled = isValid
    }
    
    @objc private func AutoTrain() {
        if temp_trainCount == 0 { StopTrainning() }
        
        if isAuto {
            CurrentTrainingLeftCount.text = "\(temp_trainCount)"
            CurrentTrainingLeftCount.isHidden = false
            if isAllCharacters {
                GenerateAnswerBitMap(characterID: Characters[currentTrainCount].codeID)
                Trainning(mode: "Train", id: Characters[currentTrainCount].codeID)
                currentTrainCount = (currentTrainCount == Characters.count - 1) ? 0 : (currentTrainCount + 1)
            } else {
                if currentTrainCount >= CommonlyUsedCharacters.count {
                    currentTrainCount = currentTrainCount % (CommonlyUsedCharacters.count)
                }
                GenerateAnswerBitMap(characterID: CommonlyUsedCharacters[currentTrainCount])
                Trainning(mode: "Train", id: CommonlyUsedCharacters[currentTrainCount])
                currentTrainCount = (currentTrainCount == CommonlyUsedCharacters.count - 1) ? 0 : (currentTrainCount + 1)
            }
            
            if currentTrainCount == 0 { temp_trainCount -= 1 }
        } else {
            if temp_trainCount > 0 {
                GenerateAnswerBitMap(characterID: CodeID)
                Trainning(mode: "Train", id: CodeID)
                temp_trainCount -= 1
                CurrentTrainingLeftCount.text = "\(temp_trainCount)"
                CurrentTrainingLeftCount.isHidden = false
            }
        }
    }
    
    private func StopTrainning() {
        timer.invalidate()
        HTMUD.set(currentTrainCount + 1, forKey: "CurrentTrainIndex")
        temp_trainCount = 0
        CodeID = ""
        UISetting(isValid: true)
        SendMsg.setTitle("Start Learning", for: .normal)
        SendMsg.titleLabel?.textColor = UIColor.blue
        CurrentTrainingLeftCount.isHidden = true
    }
    
    private func Trainning(mode: String, id: String) {
        let LayersCount: Int = Cortex.count
        var CorrectInput: [[[Bool]]] = []
        
        // Forward direction learning (Low -> High)
        for LayerIndex in 0..<LayersCount {
            let LowerLayerColumns = (LayerIndex == 0) ? InputLayer.columns : Cortex[LayerIndex - 1].columns
            let CurrentLayerSize = Cortex[LayerIndex].layerParameters.ColumnsSize
            
            // Calculate the connected links' count for every column
            for row in 0..<CurrentLayerSize {
                for col in 0..<CurrentLayerSize {
                    let threshold = Cortex[LayerIndex].layerParameters.LinkActiveThreshold
                    Cortex[LayerIndex].columns[row][col].ForwardActivation(for: LowerLayerColumns, with: threshold)
                }
            }
            
            // Find winner columns according to the inhibition radiuss
            let WinnerColumns = SpacialLearning.NeighborOverlap(for: Cortex[LayerIndex].columns, with: CurrentLayerSize, radius: InhibitRadius)
            
            // Replace current layer with winner columns
            Cortex[LayerIndex].columns = WinnerColumns
                        
            // Temperal Pooler
            Cortex[LayerIndex] = TempertalLearning.EvalauteActiveColumns(for: Cortex[LayerIndex], trainCount: CommonlyUsedCharacters.count, enable_learning: true)

            if LayerIndex == 0 {
                CorrectInput.append(CharactersBitMap)
            } else if LayerIndex > 0 {
                let currentLowerColumnSize = LayerParameters[LayerIndex - 1].ColumnsSize
                var answer = Array(repeating: Array(repeating: false, count: currentLowerColumnSize), count: currentLowerColumnSize)
                
                // Record winner columns as current trained answer for weight update
                for row in 0..<currentLowerColumnSize {
                    for col in 0..<currentLowerColumnSize {
                        if Cortex[LayerIndex - 1].columns[row][col].isActiveForward {
                            answer[row][col] = true
                        }
                    }
                }
                
                CorrectInput.append(answer)
            }
        }
        
        // Clean all activation record for every column except top layer
        for layerIndex in 0..<LayersCount {
            let layerSize = (layerIndex == 0) ? OriginalInputSize : Cortex[layerIndex - 1].layerParameters.ColumnsSize
                        
            for row in 0..<layerSize {
                for col in 0..<layerSize {
                    if layerIndex == 0 {
                        InputLayer.columns[row][col].isActiveForward = false
                        InputLayer.columns[row][col].ForwardActivatedValue = 0
                    } else {
                        Cortex[layerIndex - 1].columns[row][col].isActiveForward = false
                        Cortex[layerIndex - 1].columns[row][col].ForwardActivatedValue = 0
                    }
                }
            }
        }
        
        // Backward direction learning (High -> Low)
        for layerIndex in stride(from: LayersCount - 1, through: 0, by: -1) {
            let LayerSize = Cortex[layerIndex].layerParameters.ColumnsSize
            let lowerLayerSize = (layerIndex == 0) ? OriginalInputSize : Cortex[layerIndex - 1].layerParameters.ColumnsSize
            
            // Propagate weight to the lower layer
            for row in 0..<LayerSize {
                for col in 0..<LayerSize {
                    let threshold = Cortex[layerIndex].layerParameters.LinkActiveThreshold
                    
                    if layerIndex == 0 {
                        InputLayer.columns = Cortex[layerIndex].columns[row][col].BackwardActivation(for: InputLayer.columns, with: threshold)
                    } else {
                        Cortex[layerIndex - 1].columns = Cortex[layerIndex].columns[row][col].BackwardActivation(for: Cortex[layerIndex - 1].columns, with: threshold)
                    }
                }
            }
            
            var count = 0
            
            for row in 0..<lowerLayerSize {
                for col in 0..<lowerLayerSize {
                    if layerIndex == 0 {
                        if InputLayer.columns[row][col].BackwardActivatedValue > 0 { count += 1 }
                    } else {
                        if Cortex[layerIndex - 1].columns[row][col].BackwardActivatedValue > 0 {
                            count += 1
                            Cortex[layerIndex - 1].columns[row][col].isActiveForward = true
                        }
                    }
                }
            }
            
            if layerIndex == 0 {
                print("activated input layer has \(count) columns")
                print("------------------------------------------------")
            } else {
                print("activated lower layer has \(count) columns")
            }
                        
            // Activate columns whose activatedCount is greater than 0
            for row in 0..<lowerLayerSize {
                for col in 0..<lowerLayerSize {
                    if layerIndex == 0 {
                        InputLayer.columns[row][col].UpperToLowerActivated()
                    } else {
                        Cortex[layerIndex - 1].columns[row][col].UpperToLowerActivated()
                    }
                }
            }
        }

        // Display temperal trainning result on screen
        var match = 0
        var unmatch = 0
        var wrong = 0
        var PresentCount = 0

        for row in 0..<OriginalInputSize {
            for col in 0..<OriginalInputSize {
                if CharactersBitMap[row][col] {
                    if InputLayer.columns[row][col].isActiveBackward {
                        DotMatrix[row][col].fillColor = UIColor.green.cgColor
                        match += 1
                        PresentCount += 1
                    } else {
                        DotMatrix[row][col].fillColor = UIColor.red.cgColor
                        unmatch += 1
                        PresentCount += 1
                    }
                } else {
                    if InputLayer.columns[row][col].isActiveBackward {
                        DotMatrix[row][col].fillColor = UIColor.orange.cgColor
                        wrong += 1
                        PresentCount += 1
                    } else {
                        match += 1
                    }
                }
            }
        }

        // Update information for this trainning's result
        let correctrate = Int(Float(match * 100) / Float(OriginalInputSize * OriginalInputSize))

        Match.text = "\(match)"
        UnMatch.text = "\(unmatch)"
        Wrong.text = "\(wrong)"
        CorrectRate.text = "\(correctrate)"

        // Change the weight among layers' links
        if mode == "Train" {
            for layerIndex in stride(from: LayersCount - 1, through: 0, by: -1) {                
                // Update links' weight accordint to current winner columns
                if layerIndex == 0 {
                    Cortex[layerIndex].columns = SpacialLearning.UpdateLinksWeight(originalInput: CharactersBitMap, frequencyArray: InputFrequencyArray, outputLayer: InputLayer.columns, upperLayer: Cortex[layerIndex].columns, with: Cortex[layerIndex].columns.count)
                } else {
                    Cortex[layerIndex].columns = SpacialLearning.UpdateLinksWeight(originalInput: CorrectInput[layerIndex], frequencyArray: InputFrequencyArray, outputLayer: Cortex[layerIndex - 1].columns, upperLayer: Cortex[layerIndex].columns, with: Cortex[layerIndex].columns.count)
                }
                
                // Update BoostFactor
                Cortex[layerIndex].columns = SpacialLearning.UpdateBoostFactor(for: Cortex[layerIndex].columns, with: Cortex[layerIndex].columns.count)
            }
            
            // Update Characters' trainning record
            if CharactersTrainningRecord.count == 0 {
                let correctness = Correctness(match: match, notMatch: unmatch, wrong: wrong, correct: correctrate)
                let record = CharacterTrainningRecord(id: id, count: 1, record: [correctness])
                CharactersTrainningRecord.append(record)
            } else {
                for i in 0...CharactersTrainningRecord.count {
                    
                    // New character should be added in the record list
                    if i == CharactersTrainningRecord.count {
                        let correctness = Correctness(match: match, notMatch: unmatch, wrong: wrong, correct: correctrate)
                        let record = CharacterTrainningRecord(id: id, count: 1, record: [correctness])
                        CharactersTrainningRecord.append(record)
                        break
                    }
                    
                    // Update existed record for current character
                    if id == CharactersTrainningRecord[i].codeID {
                        let correctness = Correctness(match: match, notMatch: unmatch, wrong: wrong, correct: correctrate)
                        CharactersTrainningRecord[i].FaultRecord.append(correctness)
                        CharactersTrainningRecord[i].RecordCount += 1
                        break
                    }
                }
            }
        }

        // Clean all parameters for next trainning
        for layerIndex in 0..<Cortex.count {
            for row in 0..<Cortex[layerIndex].layerParameters.ColumnsSize {
                for col in 0..<Cortex[layerIndex].layerParameters.ColumnsSize {
                    Cortex[layerIndex].columns[row][col].ResetValue()
                }
            }
        }
    }
    
    private func cleanMemory() {
        Characters.removeAll()
        CharactersTrainningRecord.removeAll()
        CommonlyUsedCharacters.removeAll()
        CharactersBitMap.removeAll()
        InputLayer.columns.removeAll()
        ColumnsLayer.removeAll()
        if timer.isValid { timer.invalidate() }
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func ConfirmSavingColumns(_ sender: UIButton) {
        if SegueName != "BackToRecord" {
            print("Confirmed Saving Columns Data!!")
            SegueName = "BackToRecord"
            
            var layers: [[[miniColumn]]] = []
            var parameters: [LayerParameter] = []
            
            for index in 0..<Cortex.count {
                layers.append(Cortex[index].columns)
                parameters.append(Cortex[index].layerParameters)
            }
            
            trainRecord.InsertNewRecord(cortex: layers, LayerParameters: parameters)
            CharRecord.InsertCharactersData(Data: CharactersTrainningRecord)
            RecordIndex = trainRecord.getCurrentTrainRecordCount() - 1
        } else {
            if RecordIndex != -1 {
                print("Confirmed Updating Columns Data(\(RecordIndex))!!")
                trainRecord.UpdateRecord(RecordIndex: RecordIndex, newCortex: Cortex)
                CharRecord.UpdataCharactersData(Data: CharactersTrainningRecord, index: RecordIndex)
            } else {
                print("Current RecordIndex is incorrect!")
            }
        }
        
        ShowParametersBtn.isEnabled = true
        SavingColumnsView(isHidden: true)
    }
    
    @IBAction func CaccelSavingColumns(_ sender: UIButton) {
        print("Canceled Saving Columns Data!!")
        SavingColumnsView(isHidden: true)
    }
    
    @IBAction func SaveColumns(_ sender: UIButton) {
        self.view.addSubview(SavingColumnsView)
        self.view.addSubview(ConfirmLabel)
        self.view.addSubview(ConfirmBtn)
        self.view.addSubview(CancelBtn)
        SavingColumnsView(isHidden: false)
    }
    
    @IBAction func AutoTrainning(_ sender: UISwitch) {
        isAuto = sender.isOn
        InputField.isHidden = (isAuto) ? true : false
    }
    
    @IBAction func startChatting(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChat", sender: self)
    }
    
    @IBAction func TrainningPeriod(_ sender: UISlider) {
        sender.value.round()
        TrainningCount.text = "\(Int(sender.value) * 5)"
        TrainCount = Int(sender.value) * 5
    }
    
    @IBAction func StartLearn(_ sender: UIButton) {
        if isStop {
            SendMsg.setTitle("Start Learning", for: .normal)
            SendMsg.titleLabel?.textColor = UIColor.blue
            StopTrainning()
        } else {
            if InputField.text == "", !isAuto { return }
            
            UISetting(isValid: false)
            
            SendMsg.setTitle("Stop Learning", for: .normal)
            SendMsg.titleLabel?.textColor = UIColor.red
            
            if !isAuto {
                if let Msg = InputField.text {
                    CodeID = EncodindCharacter(char: Msg)
                } else {
                    print("Msg sending is incorrect!")
                }
            }
            
            temp_trainCount = TrainCount
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(AutoTrain), userInfo: nil, repeats: true)
            InputField.text = ""
        }
        
        isStop = (isStop == true) ? false : true
    }
    
    @IBAction func ShowCharacter(_ sender: UIButton) {
        if let Msg = InputField.text {
            CodeID = EncodindCharacter(char: Msg)
        } else {
            print("Msg sending is incorrect!")
        }
        GenerateAnswerBitMap(characterID: CodeID)
        Trainning(mode: "Search", id: CodeID)
    }
    
    @IBAction func Back(_ sender: UIButton) {
        cleanMemory()
        performSegue(withIdentifier: SegueName, sender: self)
    }
}
