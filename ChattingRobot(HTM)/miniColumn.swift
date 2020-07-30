//
//  miniColumn.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/7/14.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation


class miniColumn {
    var Coordinate = Pair<Int, Int>(first: -1, second: -1)
    var Links = [miniLink]()
    var Cells = [miniCell]()
    var PotentialConnectAreaValue = Pair<Int, Int>(first: -1, second: -1)
    var isActiveForward = false
    var isActiveBackward = false
    var BackwardActivatedValue = 0
    var ForwardActivatedValue: Float = 0
    var ActivatedDutyCycle: Float = 0
    var TimeAveragedActivation: Float = 0
    var BoostValue: Float = 1
    var CellsCount = 1
    
    // For column in cortex layer
    init(coordinate: Pair<Int, Int>, radius: Int, size_l: Int, size_u: Int, count: Int) {
        self.Coordinate = coordinate
        self.InitialLinks(for: radius, with: size_l, with: size_u)
        self.InitialCells(count: count)
    }
    
    // For column which is input
    init(coordinate: Pair<Int, Int>) {
        self.Coordinate = coordinate
    }
    
    // MARK: -Initial Links
    
    public func InitialLinks(for radius: Int, with size_l: Int, with size_u: Int) {
        var columnX = self.Coordinate.first
        var columnY = self.Coordinate.second
        
        let divident = Float(size_u) / Float(size_l)
                
        columnX = Int(Float(columnX) / divident)
        columnY = Int(Float(columnY) / divident)
        
        var minX = max(0, columnX - radius + 1)
        var minY = max(0, columnY - radius + 1)
        var maxX = min(size_l - 1, columnX + radius - 1)
        var maxY = min(size_l - 1, columnY + radius - 1)
        
        if minX == 0 { maxX = radius * 2 }
        if minY == 0 { maxY = radius * 2 }
        if maxX == size_l - 1 { minX = size_l - 1 - radius * 2 }
        if maxY == size_l - 1 { minY = size_l - 1 - radius * 2 }
        
        let min_potential_value = minY * size_l + minX
        let max_potential_value = maxY * size_l + maxX
        
        PotentialConnectAreaValue = Pair(first: min_potential_value, second: max_potential_value)
                
        var AvailableRangeIndex = [Int]()
        
        for y in minY...maxY {
            for x in minX...maxX {
                AvailableRangeIndex.append(x + y * size_l)
            }
        }
        
        guard AvailableRangeIndex.count > 0 else { return }
        
        let PotentialConnectsCount = Int(Float(AvailableRangeIndex.count) * 0.5)
                
        for _ in 0..<PotentialConnectsCount {
            if let RandomConnectValue = AvailableRangeIndex.randomElement() {
                AvailableRangeIndex.removeAll(where: { $0 == RandomConnectValue })
                let CoordinateX = RandomConnectValue % size_l
                let CoordinateY = RandomConnectValue / size_l
                let Weight = (Float.random(in: 0.1...0.9) * 100).rounded() / 100.0
                let NewLink = miniLink(permanence: Weight, coordinate: Pair(first: CoordinateX, second: CoordinateY))
                Links.append(NewLink)
            }
        }
    }
    
    // MARK: - Initial Cells
    
    private func InitialCells(count: Int) {
        for i in 0..<count {
            let cell = miniCell(index: i, coordinate: self.Coordinate, dendrites: [])
            Cells.append(cell)
        }
    }
    
    // MARK: - Intents (Links)
    
    // Calculating the number of the active links for current input
    public func ForwardActivation(for input: [[miniColumn]], with threshold: Float) {
        for link in Links {
            let x = link.ConnectedCoordinate.first
            let y = link.ConnectedCoordinate.second
            
            if input[y][x].isActiveForward, link.Permanence > threshold {
                ForwardActivatedValue += 1.0
            }
        }
        
        ForwardActivatedValue *= BoostValue    // Only need to check this value to compare and find out the winner columns
        
        isActiveForward = ForwardActivatedValue > 0
    }
    
    // If the columns is winner column, then activates the link whose permanence exceed the threshold and changes the connected input's newWorth
    public func BackwardActivation(for LowerLayer: [[miniColumn]], with threshold: Float) -> [[miniColumn]] {
        if !isActiveForward { return LowerLayer }
                
        for link in Links {
            let x = link.ConnectedCoordinate.first
            let y = link.ConnectedCoordinate.second
            
            if link.Permanence > threshold {
                LowerLayer[y][x].BackwardActivatedValue += 1
            } else {
                LowerLayer[y][x].BackwardActivatedValue -= 1
            }
        }
        
        return LowerLayer
    }
    
    // Activated the column if the backward column activation is over the threshold
    public func UpperToLowerActivated() {
        if BackwardActivatedValue > 0 {
            isActiveBackward = true
        }
    }
    
    // Dynamically update the links according to the activity frequency
    public func DiscardLink(for index: Int, for size: Int, FrequencyArray: [[Int]]) {
        var currentConnectLinksValue = [Int]()
        var validateLinksValue = [potentialGrid]()

        for link in Links {
            let x = link.ConnectedCoordinate.first
            let y = link.ConnectedCoordinate.second

            currentConnectLinksValue.append(y * size + x)
        }

        let minX = PotentialConnectAreaValue.first % size
        let minY = PotentialConnectAreaValue.first / size
        let maxX = PotentialConnectAreaValue.second % size
        let maxY = PotentialConnectAreaValue.second / size

        struct potentialGrid {
            var CoordinateValue: Int
            var Frequency: Int

            init(coordinate: Int, frequency: Int) {
                self.CoordinateValue = coordinate
                self.Frequency = frequency
            }
        }

        for x in minY...maxY {
            for y in minX...maxX {
                let value = y * size + x
                let frequency = FrequencyArray[y][x]

                if !currentConnectLinksValue.contains(value) {
                    let grid = potentialGrid(coordinate: value, frequency: frequency)
                    validateLinksValue.append(grid)
                }
            }
        }

//        validateLinksValue = validateLinksValue.sorted { $0.Frequency > $1.Frequency }
//
//        let maxLinkValue = validateLinksValue[0].Frequency
//        var potentialConnect = [Int]()
//
//        for index in 0..<validateLinksValue.count {
//            if validateLinksValue[index].Frequency == maxLinkValue {
//                potentialConnect.append(validateLinksValue[index].CoordinateValue)
//            }
//        }
//
//        guard potentialConnect.count > 0
//            else { print("Validate links is not existed!"); return }
                
        let _ = Links.remove(at: index)
        
        let newLinkValue = validateLinksValue.randomElement()!
        let CoordinateX = newLinkValue.CoordinateValue % size
        let CoordinateY = newLinkValue.CoordinateValue / size
        let Weight = (Float.random(in: 0.1...0.9) * 100).rounded() / 100.0
        let NewLink = miniLink(permanence: Weight, coordinate: Pair(first: CoordinateX, second: CoordinateY))
        
        print("new link coordinate: \(NewLink.ConnectedCoordinate) -> \(validateLinksValue[0].Frequency)")
        
        Links.append(NewLink)
        
    }
    
    public func ResetValue() {
        isActiveForward = false
        isActiveBackward = false
        ForwardActivatedValue = 0
        BackwardActivatedValue = 0
    }
    
    // MARK: - Intents (Cells)
    
    
    
}

// MARK: - Elements in the cortex

struct miniLink: Hashable {
    var Permanence: Float
    var ConnectedCoordinate: Pair<Int, Int>
    
    init(permanence: Float, coordinate: Pair<Int, Int>) {
        self.Permanence = permanence
        self.ConnectedCoordinate = coordinate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(Permanence)
        hasher.combine(ConnectedCoordinate.first)
        hasher.combine(ConnectedCoordinate.second)
    }
    
    static func ==(lhs: miniLink, rhs: miniLink) -> Bool {
        return lhs.ConnectedCoordinate == rhs.ConnectedCoordinate
    }
}


struct miniCell {
    var isActive: Bool = false
    var Coordinate: Pair<Int, Int>
    var index: Int
    var dendrites: [miniDendrite]
    
    init(index: Int, coordinate: Pair<Int, Int>, dendrites: [miniDendrite]) {
        self.Coordinate = coordinate
        self.index = index
        self.dendrites = dendrites
    }
}

struct miniDendrite: Hashable {
    var Coordinate: Pair<Int, Int>
    var belongingCellIndex: Int
    var numActivePotentialSynapses: Int = 0
    var synapses: [miniSynapse]
    var id: Int
    
    init(index: Int, coordinate: Pair<Int, Int>, syn: [miniSynapse], id: Int) {
        self.belongingCellIndex = index
        self.Coordinate = coordinate
        self.synapses = syn
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(numActivePotentialSynapses)
        hasher.combine(synapses.count)
    }
    
    static func == (lhs: miniDendrite, rhs: miniDendrite) -> Bool {
        return lhs.numActivePotentialSynapses == rhs.numActivePotentialSynapses
    }
}

struct miniSynapse: Hashable {
    var connectCellCoordinate: Pair<Int, Int>
    var connectCellIndex: Int
    var permenance: Float
    
    init(coordinate: Pair<Int, Int>, index: Int, permenance: Float) {
        self.connectCellCoordinate = coordinate
        self.connectCellIndex = index
        self.permenance = permenance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(permenance)
    }
    
    static func == (lhs: miniSynapse, rhs: miniSynapse) -> Bool {
        return lhs.connectCellCoordinate == rhs.connectCellCoordinate && lhs.permenance == rhs.permenance
    }
}
