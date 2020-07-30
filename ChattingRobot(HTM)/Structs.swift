//
//  Structs.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/17.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation

struct Pair<T1:Equatable, T2:Equatable>: Equatable {
    var first: T1
    var second: T2
    
    init(first: T1, second: T2) {
        self.first = first
        self.second = second
    }
}

struct PreActiveCells {
    var coordinate: Pair<Int, Int>
    var index: Int
    
    init(coor: Pair<Int, Int>, index: Int) {
        coordinate = coor
        self.index = index
    }
}

struct DistalLink {
    var coordinate: Pair<Int, Int>
    var linkIndex: Int
    var info: Link
    
    init(coor: Pair<Int, Int>, index: Int, info: Link) {
        self.coordinate = coor
        self.linkIndex = index
        self.info = info
    }
}

struct CharacterData {
    var codeID: String
    var BBX_width: Int
    var BBX_height: Int
    var bitmap: [[Int]]
    
    init(id: String, w: Int, h: Int, map: [[Int]]) {
        codeID = id
        BBX_width = w
        BBX_height = h
        bitmap = map
    }
}

struct Correctness {
    var MatchCount: Int
    var NotMatchCount: Int
    var WrongCount: Int
    var CorrectPercentage: Int
    
    init(match: Int, notMatch: Int, wrong: Int, correct: Int) {
        MatchCount  = match
        NotMatchCount = notMatch
        WrongCount = wrong
        CorrectPercentage = correct
    }
    
}

struct CharacterTrainningRecord {
    var codeID: String
    var RecordCount: Int
    var FaultRecord: [Correctness]
    
    init(id: String, count: Int, record: [Correctness]) {
        codeID = id
        RecordCount = count
        FaultRecord = record
    }
}

struct RecordDetail {
    var LC: Int
    var CAT: Int
    var WCC: Int
    var Date: String
    
    init(lc: Int, cat: Int, wcc: Int, date: String) {
        LC = lc
        CAT = cat
        WCC = wcc
        Date = date
    }
}

struct TemperalPoolingCoefficient {
    var preWinnerCells: [miniCell]
    var preActiveCells: [miniCell]
    var preActiveDendrites: [miniDendrite]
    var preMatchingActiveDendrites: [miniDendrite]
    
    init(pwc: [miniCell], pac: [miniCell], pas: [miniDendrite], pma: [miniDendrite]) {
        self.preWinnerCells = pwc
        self.preActiveCells = pac
        self.preActiveDendrites = pas
        self.preMatchingActiveDendrites = pma
    }
}

struct LayerParameter {
    var ColumnsSize: Int
    var CellsCount: Int
    var LowerLinkPercentage: Float
    var LinkActiveThreshold: Float
    var FaultTolerance: Float
    var WinnerColumnsPercentage: Float
    var IncrementValue: Float
    var DecrementValue: Float
    
    init(cs: Int, llp: Float, cc: Int, lat: Float, ft: Float, wcc: Float, iv: Float, dv: Float) {
        self.ColumnsSize = cs
        self.LowerLinkPercentage = llp
        self.CellsCount = cc
        self.LinkActiveThreshold = lat
        self.FaultTolerance = ft
        self.WinnerColumnsPercentage = wcc
        self.IncrementValue = iv
        self.DecrementValue = dv
    }
}

struct LayerComponent {
    var layerParameters: LayerParameter
    var columns: [[miniColumn]]
    var tpCoefficient: TemperalPoolingCoefficient
    
    init(layerP: LayerParameter, columns: [[miniColumn]], coefficient: TemperalPoolingCoefficient) {
        self.layerParameters = layerP
        self.columns = columns
        self.tpCoefficient = coefficient
    }
}
