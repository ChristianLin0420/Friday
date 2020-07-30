//
//  Synapse+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
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
    @NSManaged public var segment: Segment

}
