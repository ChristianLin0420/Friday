//
//  TrainRecord+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
//
//

import Foundation
import CoreData


extension TrainRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainRecord> {
        return NSFetchRequest<TrainRecord>(entityName: "TrainRecord")
    }

    @NSManaged public var date: String
    @NSManaged public var cortex: NSSet

}

// MARK: Generated accessors for cortex
extension TrainRecord {

    @objc(addCortexObject:)
    @NSManaged public func addToCortex(_ value: Layer)

    @objc(removeCortexObject:)
    @NSManaged public func removeFromCortex(_ value: Layer)

    @objc(addCortex:)
    @NSManaged public func addToCortex(_ values: NSSet)

    @objc(removeCortex:)
    @NSManaged public func removeFromCortex(_ values: NSSet)

}
