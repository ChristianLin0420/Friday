//
//  CortexParameters.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/5.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation

// UserDefault
private let HTMUD = UserDefaults.standard

// -------------------------------------------- Fundemental parameters setting -------------------------------------------- //

// Size of the Columns Layer
//public var ColumnsSize: Int {
//    if let count = HTMUD.object(forKey: "ColumnsSize") { return count as! Int }
//    else { return 50 }
//}

// Size of the Input Layer
public var InputsSize: Int {
    if let count = HTMUD.object(forKey: "InputsSize") { return count as! Int }
    else { return 24 }
}

// Number of the links that a column connected with input layer
//public var LinkCount: Int {
//    if let percent = HTMUD.object(forKey: "LinksCount") {
//        let count = Int(Float(percent as! Int) * Float(InputsSize * InputsSize) * 0.01)
//        return count
//    } else {
//        return 20
//    }
//}

// Number of Cells in a column
//public var CellsCount: Int {
//    if let count = HTMUD.object(forKey: "CellsCount") { return count as! Int }
//    else { return 6 }
//}

// Threshold of the Column to be activated
//public var ColumnActiveThershold: Float {
//    if let threshold = HTMUD.object(forKey: "CAT") {
//        let temp = threshold as! Float
//        return temp / Float(100)
//    } else {
//        return 0.25
//    }
//}

// Threshold of the link to be activated between column and input
//public var LinkActiveThershold: Float {
//    if let threshold = HTMUD.object(forKey: "LAT") {
//        let temp = threshold as! Float
//        return temp / Float(100)
//    } else {
//        return 0.05
//    }
//}

// What percentage of the columns in learning layer should be activated
//public var WinnerColumnsPercentage: Int {
//    if let count = HTMUD.object(forKey: "WCC") {
//        return count as! Int
//    } else {
//        return 2
//    }
//}

// Value to increment a activated link's permenance
//public var IncrementValue: Float {
//    if let threshold = HTMUD.object(forKey: "IncrementValue") {
//        let temp = threshold as! Float
//        return temp / Float(100)
//    } else {
//        return 0.05
//    }
//}

// Value to decrement a inactivated link's permenance
//public var DecrementValue: Float {
//    if let threshold = HTMUD.object(forKey: "DecrementValue") {
//        let temp = threshold as! Float
//        return temp / Float(100)
//    } else {
//        return 0.01
//    }
//}

// Percentage of learning's failure that we can tolerance
public var FaultTolerance: Float {
    if let threshold = HTMUD.object(forKey: "FaultTolerrance") {
        let temp = threshold as! Float
        return temp / Float(100)
    } else {
        return 0.05
    }
}

// A parameter for Boosting
public var TrainingStep: Int {
    if let factor = HTMUD.object(forKey: "TS") { return factor as! Int }
    else { return 1000 }
}

// Index of pattern that we are training right now
public var CurrentTrainIndex: Int {
    if let index = HTMUD.object(forKey: "CurrentTrainIndex") { return index as! Int }
    else { return 0 }
}

// -------------------------------------------- Spatial Pooling parameters -------------------------------------------- //

// Radius for a column to inhibit its neighbor columns' activation
public var InhibitionRadiu: Int {
    if let radius = HTMUD.object(forKey: "IR") { return radius as! Int }
    else { return 5 }
}

// Upper bound of Boost factor
public var MaxBoostBound: Float {
    if let factor = HTMUD.object(forKey: "MBF") { return factor as! Float }
    else { return 1.2 }
}

// Lower bound of Boost factor
public var MinBoostBound: Float {
    if let factor = HTMUD.object(forKey: "MiBF") { return factor as! Float }
    else { return 0.8 }
}

// How fast does Boost factor to update
public var BoostingStrength: Int {
    if let factor = HTMUD.object(forKey: "BS") { return factor as! Int }
    else { return 1000 }
}

// -------------------------------------------- Temperal Pooling parameters -------------------------------------------- //

// Number of segments on a cell
public var DendritesCount: Int {
    if let count = HTMUD.object(forKey: "SC") { return count as! Int }
    else { return 40 }
}

// Number of synapses in a segment
public var SynapsesCount: Int {
    if let count = HTMUD.object(forKey: "SyC") { return count as! Int }
    else { return 40 }
}

// Maximum count for a segment
public var MaxSynapseCountPerSegment: Int {
    if let count = HTMUD.object(forKey: "MSCPS") { return count as! Int }
    else { return 40 }
}

// Value to increment a active dendrite segment's permenance
public var PermanenceIncrement: Float {
    if let value = HTMUD.object(forKey: "PI") {
        let temp = value as! Float
        return temp / 100.0
    } else {
        return 0.1
    }
}

// Value to decrement a inactive dendrite segment's permenance
public var PermanenceDecrement: Float {
    if let value = HTMUD.object(forKey: "PD") {
        let temp = value as! Float
        return temp / 100.0
    } else {
        return 0.05
    }
}

public var SynapsesConnectedPermenace: Float {
    if let value = HTMUD.object(forKey: "SCP") {
        let temp = value as! Float
        return temp / 100.0
    } else {
        return 0.5
    }
}

// 
public var PredictedDecrement: Float {
    if let value = HTMUD.object(forKey: "PrD") { return value as! Float }
    else { return 0.05 }
}

public var ActivatedCellThreshold: Int {
    if let threshold = HTMUD.object(forKey: "ACeT") { return threshold as! Int }
    else { return 3 }
}

public var MatchingLearningThreshold: Int {
    if let threshold = HTMUD.object(forKey: "MLT") { return threshold as! Int }
    else { return 1 }
}
