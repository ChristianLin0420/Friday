//
//  Layer+CoreDataProperties.swift
//  
//
//  Created by Christian on 2020/4/22.
//
//

import Foundation
import CoreData


extension Layer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Layer> {
        return NSFetchRequest<Layer>(entityName: "Layer")
    }

    @NSManaged public var cellscount: Int16
    @NSManaged public var columnactivethreshold: Float
    @NSManaged public var columnssize: Int16
    @NSManaged public var currenttrainindex: Int16
    @NSManaged public var decrementvalue: Float
    @NSManaged public var faulttolerance: Float
    @NSManaged public var incrementvalue: Float
    @NSManaged public var linkactivethreshold: Float
    @NSManaged public var lowerlinksratio: Float
    @NSManaged public var winnercolumnsratio: Float
    @NSManaged public var columns: NSSet
    @NSManaged public var record: TrainRecord

}

// MARK: Generated accessors for columns
extension Layer {

    @objc(addColumnsObject:)
    @NSManaged public func addToColumns(_ value: Column)

    @objc(removeColumnsObject:)
    @NSManaged public func removeFromColumns(_ value: Column)

    @objc(addColumns:)
    @NSManaged public func addToColumns(_ values: NSSet)

    @objc(removeColumns:)
    @NSManaged public func removeFromColumns(_ values: NSSet)

}
