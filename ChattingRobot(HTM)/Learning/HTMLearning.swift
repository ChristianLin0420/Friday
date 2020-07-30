//
//  HTMLearning.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/7/15.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation

class HTMSpacialPooling {
    public func NeighborOverlap(for columns: [[miniColumn]], with size: Int, radius: Int) -> [[miniColumn]] {
        for row in 0..<size {
            for col in 0..<size {
                
                if columns[row][col].ForwardActivatedValue > 0 {
                    let minX = max(0, col - radius)
                    let minY = max(0, row - radius)
                    let maxX = min(size - 1, col + radius)
                    let maxY = min(size - 1, row + radius)
                    
                    let width = maxX - minX + 1
                    let height = maxY - minY + 1
                    let areaSize = width * height
                    let range = Int(Float(areaSize) * 0.02)
                    var potentialColumns = [miniColumn]()
                    
                    if range == 0 { continue }
                                        
                    for i in minY...maxY {
                        for j in minX...maxX {
                            if columns[i][j].ForwardActivatedValue > 0 {
                                let delta_x_power = pow(Double(col - j), 2)
                                let delta_y_power = pow(Double(row - i), 2)
                                let distance = sqrt(delta_x_power + delta_y_power)
                                                                
                                if distance > Double(radius) {
                                    continue
                                } else {
                                    potentialColumns.append(columns[i][j])
                                }
                            }
                        }
                    }
                    
                    var isWinner = false
                    potentialColumns = potentialColumns.sorted { $0.ForwardActivatedValue > $1.ForwardActivatedValue }
                    
                    for i in 0..<range {
                        let x = potentialColumns[i].Coordinate.first
                        let y = potentialColumns[i].Coordinate.second
                        
                        if x == col, y == row {
                            isWinner = true
                            break
                        }
                    }
                                        
                    if !isWinner {
                        columns[row][col].ForwardActivatedValue = 0
                        columns[row][col].isActiveForward = false
                    } else {
                        if range < potentialColumns.count {
                            for i in range..<potentialColumns.count {
                                let x = potentialColumns[i].Coordinate.first
                                let y = potentialColumns[i].Coordinate.second
                                
                                columns[y][x].ForwardActivatedValue = 0
                                columns[y][x].isActiveForward = false
                            }
                        }
                    }
                }
            }
        }
        
//        var PotentialWinnerColumnsCount = 0
//        
//        for row in 0..<size {
//            for col in 0..<size {
//                if columns[row][col].ForwardActivatedValue > 0 {
//                    PotentialWinnerColumnsCount += 1
//                }
//            }
//        }
        
//        print("Accordint to the original activation principle, the total potential winner columns count is \(PotentialWinnerColumnsCount)")
        
        return columns
    }
    
    public func FindWinnerColumns(for columns: [[miniColumn]], with size: Int) -> [[miniColumn]] {
        var ActivatedColumns = [miniColumn]()
        
        // Inhibit certain radius of columns
        let SubColumnsCount = 6
        let SubColumnsSize = columns.count / SubColumnsCount
                
        for i in 0..<SubColumnsCount {
            for j in 0..<SubColumnsCount {
                for row in 0..<SubColumnsSize {
                    for col in 0..<SubColumnsSize {
                        let x = i * SubColumnsSize + col
                        let y = j * SubColumnsSize + row
                                                
                        if columns[y][x].ForwardActivatedValue > 0 {
                            ActivatedColumns.append(columns[y][x])
                        }
                    }
                }
                
                if ActivatedColumns.count  == 0 { continue }
                
                ActivatedColumns = ActivatedColumns.sorted { $0.ForwardActivatedValue > $1.ForwardActivatedValue }
                
                let ActivatedColumnsCount = ActivatedColumns[0].ForwardActivatedValue
                var potentialActivatedColumns = [miniColumn]()
                
                for index in 0..<ActivatedColumns.count {
                    if ActivatedColumns[index].ForwardActivatedValue == ActivatedColumnsCount {
                        potentialActivatedColumns.append(ActivatedColumns[index])
                    } else {
                        break
                    }
                }
                                                
                for index in 1..<ActivatedColumns.count {
                    let x = ActivatedColumns[index].Coordinate.first
                    let y = ActivatedColumns[index].Coordinate.second
                    
                    columns[y][x].ForwardActivatedValue = 0
                    columns[y][x].isActiveForward = false
                }
                
                ActivatedColumns.removeAll()
            }
        }
        
        return columns
    }
    
    public func UpdateLinksWeight(originalInput: [[Bool]], frequencyArray: [[Int]], outputLayer: [[miniColumn]], upperLayer: [[miniColumn]], with size: Int) -> [[miniColumn]] {
        
        for row in 0..<size {
            for col in 0..<size {
                if upperLayer[row][col].isActiveForward {
                    let originalLinksCount = upperLayer[row][col].Links.count
                    
                    for i in 0..<upperLayer[row][col].Links.count {
                        let x = upperLayer[row][col].Links[i].ConnectedCoordinate.first
                        let y = upperLayer[row][col].Links[i].ConnectedCoordinate.second

                        if originalInput[y][x] {
                            if outputLayer[y][x].isActiveBackward {
                                upperLayer[row][col].Links[i].Permanence = min(upperLayer[row][col].Links[i].Permanence + 0.1, 1)
                            } else {
                                upperLayer[row][col].Links[i].Permanence = min(upperLayer[row][col].Links[i].Permanence + 0.05, 1)
                            }
                        } else {
                            if outputLayer[y][x].isActiveBackward {
                                upperLayer[row][col].Links[i].Permanence -= 0.05
                            }
                        }
                    }
                    
                    // Dynamically update the links condition, if the connection is not necessary, then we discard it and add new one
                    for index in 0..<upperLayer[row][col].Links.count {
                        if index < upperLayer[row][col].Links.count { break }
                        if upperLayer[row][col].Links[index].Permanence == 0.0 {
                            upperLayer[row][col].DiscardLink(for: index, for: size, FrequencyArray: frequencyArray)
                        }
                    }

                    if upperLayer[row][col].Links.count != originalLinksCount {
                        print("original count  = \(originalLinksCount)")
                        print(upperLayer[row][col].Links.count)
                        print("[ERROR] column link count is not correct!!!")
                    }

                    upperLayer[row][col].ActivatedDutyCycle += 0.001
                }
            }
        }
        
        return upperLayer
    }
    
    public func UpdateBoostFactor(for columns: [[miniColumn]], with size: Int) -> [[miniColumn]] {
        for row in 0..<size {
            for col in 0..<size {
                columns[row][col].TimeAveragedActivation = (Float(TrainingStep - 1) * columns[row][col].TimeAveragedActivation + Float(columns[row][col].ActivatedDutyCycle)) / Float(TrainingStep)
                
                let minX = max(0, col - InhibitionRadiu)
                let minY = max(0, row - InhibitionRadiu)
                let maxX = min(size, col + InhibitionRadiu)
                let maxY = min(size, row + InhibitionRadiu)
                
                var ActivitySum: Float = 0
                var NeighborCount: Float = 0
                var ReferenceActivation: Float = 0
                
                for i in minY..<maxY {
                    for j in minX..<maxX {
                        if row != i && col != j {
                            ActivitySum += columns[i][j].ActivatedDutyCycle
                            NeighborCount += 1
                        }
                    }
                }
                
                ReferenceActivation = ActivitySum / NeighborCount
                
                // Calculating new boosting factor
                let exp: Float = 2.7182818284
                let Delta = Float(-BoostingStrength) * (columns[row][col].TimeAveragedActivation - ReferenceActivation)
                var newBoostFactor = powf(exp, Delta)
                
                if newBoostFactor > 1.04 {
                    newBoostFactor = 1.04
                } else if newBoostFactor < 0.75 {
                    newBoostFactor = 0.75
                }
                
                columns[row][col].BoostValue = newBoostFactor
            }
        }
        
        
        return columns
    }
}


class HTMTemperalPooling {
    
    var previousWinnerCells: [miniCell] = []
    var previousActiveCells: [miniCell] = []
    var currentWinnerCells: [miniCell] = []
    var currentActiveCells: [miniCell] = []
    var previousActiveDendrites: [miniDendrite] = []
    var currentActiveDendrites: [miniDendrite] = []
    var previousMatchedActiveDendrites: [miniDendrite] = []
    var currentMatchedActiveDendrites: [miniDendrite] = []
    
    var LEARNING_ENABLE = false
    var SAMPLE_SIZE = 0
    
    var IncrementValue: Float = 0.1
    var DecrementValue: Float = 0.02
    
    public func EvalauteActiveColumns(for input: LayerComponent, trainCount: Int, enable_learning: Bool) -> LayerComponent {
        
        var layer = input
        var columns = layer.columns
        
        let TPcoefficient = layer.tpCoefficient
        
        self.previousActiveCells = TPcoefficient.preActiveCells
        self.previousWinnerCells = TPcoefficient.preWinnerCells
        self.previousActiveDendrites = TPcoefficient.preActiveDendrites
        self.previousMatchedActiveDendrites = TPcoefficient.preMatchingActiveDendrites
        self.LEARNING_ENABLE = enable_learning
        self.SAMPLE_SIZE = trainCount
        
        self.IncrementValue = layer.layerParameters.IncrementValue
        self.DecrementValue = layer.layerParameters.DecrementValue
        
        let layerSize = layer.layerParameters.ColumnsSize
        let cellCount = layer.layerParameters.CellsCount
        
        for row in 0..<layerSize {
            for col in 0..<layerSize {
                if columns[row][col].isActiveForward {
                    let activeDendrites = MatchingDendrites(column: layer.columns[row][col], activeDendrites: previousActiveDendrites)
                    
                    if !activeDendrites.isEmpty {
                        columns[row][col] = ActivatePredictedColumn(column: layer.columns[row][col], dendrites: activeDendrites)
                    } else {
                        columns[row][col] = BurstColumn(column: layer.columns[row][col])
                    }
                } else {
                    let dendrites = MatchingDendrites(column: layer.columns[row][col], activeDendrites: previousMatchedActiveDendrites)
                    
                    if !dendrites.isEmpty {
                        columns[row][col] = PunishPredictedColumn(column: columns[row][col], dendrites: dendrites)
                    }
                }
            }
        }
        
        for row in 0..<layerSize {
            for col in 0..<layerSize {
                for i in 0..<cellCount {
                    if !columns[row][col].Cells[i].dendrites.isEmpty {
                        for j in 0..<columns[row][col].Cells[i].dendrites.count {
                            var numActiveConnected = 0
                            var numActivePotential = 0
                            var isPotentialSegment = false
                            
                            for s in columns[row][col].Cells[i].dendrites[j].synapses {
                                
                                // Check whether the segment has chance to connect with the active cell
                                for c in currentActiveCells {
                                    if s.connectCellCoordinate == c.Coordinate {
                                        isPotentialSegment = true
                                        break
                                    }
                                }
                                
                                if isPotentialSegment {
                                    if s.permenance >= SynapsesConnectedPermenace {
                                        numActiveConnected += 1
                                    }
                                    
                                    if s.permenance >= 0 {
                                        numActivePotential += 1
                                    }
                                }
                            }
                            
                            print("numActiveConnected: \(numActiveConnected), numActivePotential = \(numActivePotential)")
                            
                            if numActiveConnected >= ActivatedCellThreshold {
                                currentActiveDendrites.append(columns[row][col].Cells[i].dendrites[j])
                            }
                            
                            if numActivePotential >= MatchingLearningThreshold {
                                currentMatchedActiveDendrites.append(columns[row][col].Cells[i].dendrites[j])
                            }
                            
                            columns[row][col].Cells[i].dendrites[j].numActivePotentialSynapses = numActivePotential
                        }
                    }
                }
            }
        }
        
        previousActiveCells.removeAll()
        previousWinnerCells.removeAll()
        previousActiveDendrites.removeAll()
        previousMatchedActiveDendrites.removeAll()
        
        let CurrentTPcoefficient = TemperalPoolingCoefficient(
                                                pwc: currentWinnerCells,
                                                pac: currentActiveCells,
                                                pas: currentActiveDendrites,
                                                pma: currentMatchedActiveDendrites)
        
        currentWinnerCells.removeAll()
        currentActiveCells.removeAll()
        currentActiveDendrites.removeAll()
        currentMatchedActiveDendrites.removeAll()
        
        layer.columns = columns
        layer.tpCoefficient = CurrentTPcoefficient
        
        return layer
    }
    
    private func ExistInPreviousCells(targetCoordinate: Pair<Int, Int>, index: Int, cells: [miniCell]) -> Bool {
        
        if !cells.isEmpty {
            for c in cells {
                if c.Coordinate == targetCoordinate && c.index == index {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func MatchingDendrites(column: miniColumn, activeDendrites: [miniDendrite]) -> [miniDendrite] {
        var dendrites: [miniDendrite] = []
        
        if !activeDendrites.isEmpty {
            for d in activeDendrites {
                if d.Coordinate == column.Coordinate {
                    dendrites.append(d)
                }
            }
        }
        
        return dendrites
    }
    
    private func ActivatePredictedColumn(column: miniColumn, dendrites: [miniDendrite]) -> miniColumn {
                        
        for i in 0..<dendrites.count {
            let d = dendrites[i]
            let cellIndex = d.belongingCellIndex
            let dendriteIndex = d.id
            
            currentActiveCells.append(column.Cells[cellIndex])
            currentWinnerCells.append(column.Cells[cellIndex])
            
            if LEARNING_ENABLE, !d.synapses.isEmpty {
                for j in 0..<d.synapses.count {
                    var synapse = d.synapses[j]
                    let isExist = ExistInPreviousCells(targetCoordinate: synapse.connectCellCoordinate, index: synapse.connectCellIndex, cells: previousActiveCells)
                    
                    if isExist {
                        synapse.permenance += self.IncrementValue
                        synapse.permenance = min(synapse.permenance, 1.0)
                    } else {
                        synapse.permenance -= self.DecrementValue
                        synapse.permenance = max(synapse.permenance, 0.0)
                    }
                }
                
                let newSynapseCount = SynapsesCount - dendrites[i].synapses.count
                column.Cells[cellIndex].dendrites[dendriteIndex] = GrowSynapse(newSynapsesCount: newSynapseCount, dendrite: column.Cells[cellIndex].dendrites[dendriteIndex])
            }
        }
        
        return column
    }
    
    private func PunishPredictedColumn(column: miniColumn, dendrites: [miniDendrite]) -> miniColumn {
        if LEARNING_ENABLE, !dendrites.isEmpty {
            for i in 0..<dendrites.count {
                let cellIndex = dendrites[i].belongingCellIndex
                let dendriteIndex = dendrites[i].id
                
                for j in 0..<dendrites[i].synapses.count {
                    for c in previousActiveCells {
                        if dendrites[i].synapses[j].connectCellCoordinate == c.Coordinate {
                            column.Cells[cellIndex].dendrites[dendriteIndex].synapses[j].permenance -= Float(PredictedDecrement)
                            break
                        }
                    }
                }
            }
        }
        
        return column
    }
    
    private func BurstColumn(column: miniColumn) -> miniColumn {
        if column.Cells.count > 0 {
            for cell in column.Cells {
                currentActiveCells.append(cell)
            }
        }
        
        let dendrites = MatchingDendrites(column: column, activeDendrites: previousMatchedActiveDendrites)
        var LearningDendritesIndex = -1
        var WinnerCell = miniCell(index: -1, coordinate: Pair(first: -1, second: -1), dendrites: [])
        var cellIndex = -1
        
        if dendrites.count > 0 {
            (cellIndex, LearningDendritesIndex) = BestMatchingDendrite(column: column)
            WinnerCell = column.Cells[cellIndex]
        } else {
            WinnerCell = LeastUsedCellIndex(column: column)
            cellIndex = WinnerCell.index
            if LEARNING_ENABLE {
                (WinnerCell, LearningDendritesIndex) = GrowNewDendrite(cell: WinnerCell)
                column.Cells[WinnerCell.index] = WinnerCell
            }
        }
        
        currentWinnerCells.append(WinnerCell)
        
        if column.Cells[cellIndex].dendrites[LearningDendritesIndex].synapses.count == 0 {
            print("synapse count is zero")
        }
        
        let synapses = column.Cells[cellIndex].dendrites[LearningDendritesIndex].synapses
                
        if LEARNING_ENABLE {
            for i in 0..<synapses.count {
                let isExist = ExistInPreviousCells(targetCoordinate: synapses[i].connectCellCoordinate, index: synapses[i].connectCellIndex, cells: previousActiveCells)
                var temp = synapses[i]
                
                if isExist {
                    temp.permenance += self.IncrementValue
                } else {
                    temp.permenance -= self.DecrementValue
                }
                
                column.Cells[WinnerCell.index].dendrites[LearningDendritesIndex].synapses[i].permenance = temp.permenance
            }
            
            let newSynapseCount = SAMPLE_SIZE - column.Cells[WinnerCell.index].dendrites[LearningDendritesIndex].numActivePotentialSynapses
            
            column.Cells[cellIndex].dendrites[LearningDendritesIndex] = GrowSynapse(newSynapsesCount: newSynapseCount, dendrite: column.Cells[cellIndex].dendrites[LearningDendritesIndex])
        }
        
        return column
    }
    
    private func PunishPredictedColumn(column: miniColumn) -> miniColumn {
        let dendrites = MatchingDendrites(column: column, activeDendrites: previousActiveDendrites)
        
        for i in 0..<dendrites.count {
            let cellIndex = dendrites[i].belongingCellIndex
            
            for j in 0..<dendrites[i].synapses.count {
                var synapse = dendrites[i].synapses[j]
                let isExist = ExistInPreviousCells(targetCoordinate: synapse.connectCellCoordinate, index: synapse.connectCellIndex, cells: previousActiveCells)
                
                if isExist {
                    synapse.permenance -= self.DecrementValue
                }
                
                column.Cells[cellIndex].dendrites[i].synapses[j].permenance = synapse.permenance
            }
        }
        
        return column
    }
    
    private func LeastUsedCellIndex(column: miniColumn) -> miniCell {
        var candidteCells: [miniCell] = []
        var minDendritesCount = 1000
        
        for c in column.Cells {
            if c.dendrites.count < minDendritesCount {
                minDendritesCount = c.dendrites.count
                candidteCells.removeAll()
                candidteCells.append(c)
            } else if c.dendrites.count == minDendritesCount {
                candidteCells.append(c)
            }
        }
        
        let randomIndex = Int.random(in: 0..<candidteCells.count)
        
        return candidteCells[randomIndex]
    }
    
    private func BestMatchingDendrite(column: miniColumn) -> (Int, Int) {
        var bestMatchingDendriteIndex = -1
        var cellIndex = -1
        var bestScore = -1
        let dendrites = MatchingDendrites(column: column, activeDendrites: previousMatchedActiveDendrites)
        
        for i in 0..<dendrites.count {
            if dendrites[i].numActivePotentialSynapses > bestScore {
                bestScore = dendrites[i].numActivePotentialSynapses
                cellIndex = dendrites[i].belongingCellIndex
                bestMatchingDendriteIndex = i
            }
        }
        
        return (cellIndex, bestMatchingDendriteIndex)
    }
    
    private func GrowNewDendrite(cell: miniCell) -> (miniCell, Int) {
        var c = cell
        let newDendrite = miniDendrite(index: cell.index, coordinate: cell.Coordinate, syn: [], id: cell.dendrites.count)
        c.dendrites.append(newDendrite)
        
        return (c, c.dendrites.count - 1)
    }
    
    private func CreateSynapse(targetCellCoordinate: Pair<Int, Int>, index: Int) -> miniSynapse {
        let newSynapse = miniSynapse(coordinate: targetCellCoordinate, index: index, permenance: 0.25)
        
        return newSynapse
    }
    
    private func GrowSynapse(newSynapsesCount: Int, dendrite: miniDendrite) -> miniDendrite {
        var newDendrite = dendrite
        var tempWinnerCells = currentWinnerCells
        var count = newSynapsesCount
        
        while !tempWinnerCells.isEmpty && count > 0 {
            let index = Int.random(in: 0..<tempWinnerCells.count)
            let cell = tempWinnerCells.remove(at: index)
            var isConnected = false
            
            for s in dendrite.synapses {
                if s.connectCellCoordinate == cell.Coordinate {
                    isConnected = true
                    break
                }
            }
            
            if !isConnected {
                newDendrite.synapses.append(CreateSynapse(targetCellCoordinate: cell.Coordinate, index: cell.index))
                count -= 1
            }
        }
        
        return newDendrite
    }
}





























