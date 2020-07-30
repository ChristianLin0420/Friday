//
//  Segment+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
//
//

import Foundation
import CoreData


extension Segment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Segment> {
        return NSFetchRequest<Segment>(entityName: "Segment")
    }

    @NSManaged public var cell: Cell
    @NSManaged public var synapses: NSSet

}

// MARK: Generated accessors for synapses
extension Segment {

    @objc(addSynapsesObject:)
    @NSManaged public func addToSynapses(_ value: Synapse)

    @objc(removeSynapsesObject:)
    @NSManaged public func removeFromSynapses(_ value: Synapse)

    @objc(addSynapses:)
    @NSManaged public func addToSynapses(_ values: NSSet)

    @objc(removeSynapses:)
    @NSManaged public func removeFromSynapses(_ values: NSSet)

}
