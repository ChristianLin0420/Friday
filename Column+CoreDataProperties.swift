//
//  Column+CoreDataProperties.swift
//  
//
//  Created by Christian on 2020/4/22.
//
//

import Foundation
import CoreData


extension Column {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Column> {
        return NSFetchRequest<Column>(entityName: "Column")
    }

    @NSManaged public var activedutycycle: Float
    @NSManaged public var boostvalue: Float
    @NSManaged public var timeaverageactivation: Int16
    @NSManaged public var cells: NSSet
    @NSManaged public var links: NSSet
    @NSManaged public var record: Layer

}

// MARK: Generated accessors for cells
extension Column {

    @objc(addCellsObject:)
    @NSManaged public func addToCells(_ value: Cell)

    @objc(removeCellsObject:)
    @NSManaged public func removeFromCells(_ value: Cell)

    @objc(addCells:)
    @NSManaged public func addToCells(_ values: NSSet)

    @objc(removeCells:)
    @NSManaged public func removeFromCells(_ values: NSSet)

}

// MARK: Generated accessors for links
extension Column {

    @objc(addLinksObject:)
    @NSManaged public func addToLinks(_ value: Link)

    @objc(removeLinksObject:)
    @NSManaged public func removeFromLinks(_ value: Link)

    @objc(addLinks:)
    @NSManaged public func addToLinks(_ values: NSSet)

    @objc(removeLinks:)
    @NSManaged public func removeFromLinks(_ values: NSSet)

}
