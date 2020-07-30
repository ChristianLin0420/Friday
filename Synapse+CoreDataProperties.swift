//
//  Synapse+CoreDataProperties.swift
//  
//
//  Created by Christian on 2020/7/30.
//
//

import Foundation
import CoreData


extension Synapse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Synapse> {
        return NSFetchRequest<Synapse>(entityName: "Synapse")
    }

    @NSManaged public var connectedX: Int16
    @NSManaged public var connectedY: Int16
    @NSManaged public var permanence: Float
    @NSManaged public var connectCellIndex: Int16
    @NSManaged public var segment: Segment?

}
