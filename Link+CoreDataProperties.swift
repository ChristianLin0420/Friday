//
//  Link+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
//
//

import Foundation
import CoreData


extension Link {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Link> {
        return NSFetchRequest<Link>(entityName: "Link")
    }

    @NSManaged public var connectedX: Int16
    @NSManaged public var connectedY: Int16
    @NSManaged public var permanence: Float
    @NSManaged public var column: Column

}
