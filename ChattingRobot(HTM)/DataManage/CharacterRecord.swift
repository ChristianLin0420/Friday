//
//  CharacterRecord.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/17.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CharacterRecord {
    
    private let EntityName = "ChrarcterRecord"
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private func ConvertIntArrayIntoString(Data: [Int]) -> String {
        var result = ""
        
        for i in 0..<Data.count {
            var string = ""
            if Data[i] == 100 {
                string = String(format: "%3d", Data[i])
            } else if Data[i] < 100, Data[i] >= 10 {
                string = String(format: "0%2d", Data[i])
            } else {
                string = String(format: "0%1d", Data[i])
            }
            result += string
        }
        
        return result
    }
    
    private func ConvertStringIntoIntArray(string: String, count: Int) -> [Int] {
        let subDataLength = 3
        var result = [Int]()
        
        for i in 0..<count {
            let lowerBound = string.index(string.startIndex, offsetBy: i * subDataLength)
            let upperBound = string.index(string.startIndex, offsetBy: (i + 1) * subDataLength)
            let subString = String(string[lowerBound..<upperBound])
            result.append(Int(subString)!)
        }
              
        return result
    }
    
    private func getString(number: Int) -> String {
        var result = ""
        
        if number < 10 {
            result = String(format: "00%1d", number)
        } else if number < 100, number >= 10 {
            result = String(format: "0%2d", number)
        } else {
            result = String(format: "%3d", number)
        }
        
        return result
    }
    
    private func convertCorrectToString(correct: [Correctness]) -> String {
        var result = ""
        
        for i in 0..<correct.count {
            let match = getString(number: correct[i].MatchCount)
            let unmatch = getString(number: correct[i].NotMatchCount)
            let wrong = getString(number: correct[i].WrongCount)
            let percentage = getString(number: correct[i].CorrectPercentage)
            let string = match + unmatch + wrong + percentage
                        
            result += string
        }
        
        return result
    }
    
    private func convertStringtoCorrect(string: String, count : Int) -> [Correctness] {
        var results = [Correctness]()
        let recordCount = string.count / 12
        
        for i in 0..<recordCount {
            let lowerBound = string.index(string.startIndex, offsetBy: i * 12)
            let upperBound = string.index(string.startIndex, offsetBy: (i + 1) * 12)
            let subString = String(string[lowerBound..<upperBound])
            var numbers = [Int]()
            
            for j in 0..<4 {
                let lower = subString.index(subString.startIndex, offsetBy: j * 3)
                let upper = subString.index(subString.startIndex, offsetBy: (j + 1) * 3)
                let s = String(subString[lower..<upper])
                numbers.append(Int(s)!)
            }
            
            let result = Correctness(match: numbers[0], notMatch: numbers[1], wrong: numbers[2], correct: numbers[3])
                        
            results.append(result)
        }
        
        return results
    }
    
    public func InsertCharactersData(Data: [CharacterTrainningRecord]) {
        var Id = ""
        var Record = [String]()
        var count = [Int]()
        
        for i in 0..<Data.count {
            Id += Data[i].codeID
            let string = convertCorrectToString(correct: Data[i].FaultRecord)
            Record.append(string)
            count.append(Data[i].RecordCount)
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let columns = NSEntityDescription.insertNewObject(forEntityName: EntityName, into: context)
        
        columns.setValue(Id, forKey: "id")
        columns.setValue(Record, forKey: "record")
        columns.setValue(count, forKey: "count")
        
        do {
            try context.save()
        } catch {
            print("Failed to insert new Record!")
        }
    }
    
    public func UpdataCharactersData(Data: [CharacterTrainningRecord], index: Int) {
        var Id = ""
        var Record = [String]()
        var count = [Int]()
    
        for i in 0..<Data.count {
            Id += Data[i].codeID
            let string = convertCorrectToString(correct: Data[i].FaultRecord)
            Record.append(string)
            count.append(Data[i].RecordCount)
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        
        do {
            let result = try context.fetch(fetchRequest) as? [NSManagedObject]
            if result!.count != 0 {
                result![index].setValue(Id, forKey: "id")
                result![index].setValue(Record, forKey: "record")
                result![index].setValue(count, forKey: "count")
                do {
                    try context.save()
                } catch {
                    print("Failed to update new Record!(1)")
                }
            } else {
                print("(Update) Result count is 0, cannot fetch any resquest!")
            }
        } catch {
            print("Failed to update new Record!(2)")
        }
        
    }
    
    public func FetchCharactersRecord(index: Int) -> [CharacterTrainningRecord] {
        var result = [CharacterTrainningRecord]()
        var id = ""
        var id_set = [String]()
        var records = [String]()
        var count = [Int]()
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        
        do {
            let result = try context.fetch(fetchRequest) as? [NSManagedObject]
            id = result![index].value(forKey: "id") as! String
            records = result![index].value(forKey: "record") as! [String]
            count = result![index].value(forKey: "count") as! [Int]
        } catch {
            print("Failed to fetch Record!")
        }
        
        if id.count > 0 {
            let subStringCount = id.count / 4
            
            for i in 0..<subStringCount {
                let lowerBound = id.index(id.startIndex, offsetBy: i * 4)
                let upperBound = id.index(id.startIndex, offsetBy: (i + 1) * 4)
                let subString = String(id[lowerBound..<upperBound])
                id_set.append(subString)
            }
        }
        
        if records.count == count.count {
            for i in 0..<records.count {
                let record = convertStringtoCorrect(string: records[i], count : count[i])
                let characterRecord = CharacterTrainningRecord(id: id_set[i], count: count[i], record: record)
                result.append(characterRecord)
            }
        } else {
            print("Fetched data count is not right!")
        }
                
        return result
    }
    
    public func DeleteCharactersRecord(index: Int) {
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName)
        
        do {
            let results = try context.fetch(fetchRequest) as? [NSManagedObject]
            
            if results!.count != 0 {
                context.delete(results![index])
            }
            
            try context.save()
        } catch {
            print("Failed to delete Column!")
        }
    }
}
