//
//  Cell+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
//
//

import Foundation
import CoreData


extension Cell {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cell> {
        return NSFetchRequest<Cell>(entityName: "Cell")
    }

    @NSManaged public var index: Int16
    @NSManaged public var column: Column
    @NSManaged public var segments: NSSet

}

// MARK: Generated accessors for segments
extension Cell {

    @objc(addSegmentsObject:)
    @NSManaged public func addToSegments(_ value: Segment)

    @objc(removeSegmentsObject:)
    @NSManaged public func removeFromSegments(_ value: Segment)

    @objc(addSegments:)
    @NSManaged public func addToSegments(_ values: NSSet)

    @objc(removeSegments:)
    @NSManaged public func removeFromSegments(_ values: NSSet)

}
