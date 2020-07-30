//
//  ChrarcterRecord+CoreDataProperties.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/4/10.
//  Copyright © 2020 Christian. All rights reserved.
//
//

import Foundation
import CoreData


extension ChrarcterRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChrarcterRecord> {
        return NSFetchRequest<ChrarcterRecord>(entityName: "ChrarcterRecord")
    }

    @NSManaged public var count: [Int]
    @NSManaged public var id: String
    @NSManaged public var record: [String]

}
