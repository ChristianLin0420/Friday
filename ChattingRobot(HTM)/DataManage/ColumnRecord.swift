//
//  ColumnRecord.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/17.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TrainRecord {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private func GetCurrentTime() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    public func InsertNewRecord(cortex: [[[LearningColumn]]], LayerParameters: [LayerParameter]) {
        let context = appDelegate.persistentContainer.viewContext
        let record = NSEntityDescription.insertNewObject(forEntityName: "TrainRecord", into: context) as! TrainRecord
        let date = GetCurrentTime()
        
        record.setValue(date, forKey: "date")
        
        if cortex.count != LayerParameters.count {
            print("Cortex layer count is not corresponding to the count of the parameters count!!")
        } else {
            for layerIndex in 0..<cortex.count {
                let layer = NSEntityDescription.insertNewObject(forEntityName: "Layer", into: context) as! Layer
                
                layer.setValue(LayerParameters[layerIndex].ColumnsSize, forKey: "columnssize")
                layer.setValue(LayerParameters[layerIndex].LowerLinkPercentage, forKey: "lowerlinksratio")
                layer.setValue(LayerParameters[layerIndex].CellsCount, forKey: "cellscount")
                layer.setValue(LayerParameters[layerIndex].ColumnActiveThreshold, forKey: "columnactivethreshold")
                layer.setValue(LayerParameters[layerIndex].LinkActiveThreshold, forKey: "linkactivethreshold")
                layer.setValue(LayerParameters[layerIndex].FaultTolerance, forKey: "faulttolerance")
                layer.setValue(LayerParameters[layerIndex].WinnerColumnsPercentage, forKey: "winnercolumnsratio")
                layer.setValue(LayerParameters[layerIndex].IncrementValue, forKey: "incrementvalue")
                layer.setValue(Int(LayerParameters[layerIndex].DecrementValue * 100), forKey: "decrementvalue")
                layer.setValue(LayerParameters[layerIndex].CurrentTrainIndex, forKey: "currenttrainindex")
                
                for row in 0..<LayerParameters[layerIndex].ColumnsSize {
                    for col in 0..<LayerParameters[layerIndex].ColumnsSize {
                        let column = NSEntityDescription.insertNewObject(forEntityName: "Column", into: context) as! Column
                        
                        // Add links to column
                        for link in cortex[layerIndex][row][col].links {
                            let newLink = NSEntityDescription.insertNewObject(forEntityName: "Link", into: context) as! Link
                            newLink.permanence = link.Permanence
                            newLink.connectedX = Int16(link.connectedX)
                            newLink.connectedY = Int16(link.connectedY)
                            
                            column.addToLinks(newLink)
                        }
                        
                        // Add cells to column
                        for cell in cortex[layerIndex][row][col].Cells {
                            let newCell = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: context) as! Cell
                            
                            for segment in cell.segments {
                                let newSegment = NSEntityDescription.insertNewObject(forEntityName: "Segment", into: context) as! Segment
                                
                                for synapse in segment.synapse {
                                    let newSynapse = NSEntityDescription.insertNewObject(forEntityName: "Synapse", into: context) as! Synapse
                                    
                                    newSynapse.connectedX = Int16(synapse.connectCellCoordinate.first)
                                    newSynapse.connectedY = Int16(synapse.connectCellCoordinate.second)
                                    newSynapse.permanence = synapse.permenance
                                    
                                    newSegment.addToSynapses(newSynapse)
                                }
                                
                                newCell.addToSegments(newSegment)
                            }
                            
                            newCell.index = Int16(cell.IndexInColumn)
                            
                            column.addToCells(newCell)
                        }
                        
                        // Add parameters to column
                        column.activedutycycle = cortex[layerIndex][row][col].activeDutyCycle
                        column.boostvalue = cortex[layerIndex][row][col].boostValue
                        column.timeaverageactivation = Int16(cortex[layerIndex][row][col].timeAveragedActivation)
                        
                        layer.addToColumns(column)
                    }
                }
                
                record.addToCortex(layer)
            }
        }
        
        // Create a new record in CoreData and store all columns information in it
        do {
            try context.save()
        } catch {
            print("[InsertNewRecord] Cannot store new reocrd in CoreData!")
        }
    }
    
    public func FetchOldRecord(RecordIndex: Int) -> [LayerComponent] {
        var cortex = [LayerComponent]()
        
        let context = appDelegate.persistentContainer.viewContext
        let DateFetchRequest = NSFetchRequest<TrainRecord>(entityName: "TrainRecord")
        
        do {
            let result = try context.fetch(DateFetchRequest)
            
            var links: [LearningLink] = []
            var cells: [LearningCell] = []
            var segments: [LearningSegment] = []
            var synapses: [LearningSynapse] = []
            
            let CoreDataCortex = result[RecordIndex].cortex.allObjects as! [Layer]
            
            for layerIndex in 0..<CoreDataCortex.count {
                let CoreDataColumns = CoreDataCortex[layerIndex].columns.allObjects as! [Column]
                
                let CoreDataColumnSize: Int = Int(CoreDataCortex[layerIndex].columnssize)
                let CoreDataLinkCount: Int = Int(CoreDataCortex[layerIndex].linkscount)
                let CoreDataCellsCount: Int = Int(CoreDataCortex[layerIndex].cellscount)
                let CoreDataColumnActiveThreshold: Float = Float(CoreDataCortex[layerIndex].cat) / 100.0
                let CoreDataLinkActiveThreshold: Float = Float(CoreDataCortex[layerIndex].lat) / 100.0
                let CoreDataFaultTolerance: Float = Float(CoreDataCortex[layerIndex].faulttolerance) / 100.0
                let CoreDataWinnerColumnsPercentage: Int = Int(CoreDataCortex[layerIndex].wcc)
                let CoreDataIncrementValue: Float = Float(CoreDataCortex[layerIndex].incrementvalue) / 100.0
                let CoreDataDecrementValue: Float = Float(CoreDataCortex[layerIndex].decrementvalue) / 100.0
                let CoreDataCurrentTrainIndex: Int = Int(CoreDataCortex[layerIndex].cti)
                
                let CoreDataLayerParameters = LayerParameter(cs: CoreDataColumnSize, lc: CoreDataLinkCount, cc: CoreDataCellsCount,
                                                             cat: CoreDataColumnActiveThreshold, lat: CoreDataLinkActiveThreshold, ft: CoreDataFaultTolerance,
                                                             wcc: CoreDataWinnerColumnsPercentage, iv: CoreDataIncrementValue,
                                                             dv: CoreDataDecrementValue, cti: CoreDataCurrentTrainIndex)
                
                var columns = Array(repeating: Array(repeating: LearningColumn(x: -1, y: -1), count: CoreDataColumnSize), count: CoreDataColumnSize)
                
                for i in 0..<CoreDataColumns.count {
                    let CoreDataLinks = CoreDataColumns[i].links.allObjects as! [Link]
                    let CoreDataCells = CoreDataColumns[i].cells.allObjects as! [Cell]
                    
                    let columnX = i % CoreDataColumnSize
                    let columnY = i / CoreDataColumnSize
                    let fetchColumn = LearningColumn(x: columnX, y: columnY)
                    
                    // Fetch links data
                    for j in 0..<CoreDataLinks.count {
                        let newLink = LearningLink(P: CoreDataLinks[j].permanence, x: Int(CoreDataLinks[j].connectedX), y: Int(CoreDataLinks[j].connectedY))
                        links.append(newLink)
                    }
                    
                    // Fetch cells data
                    for j in 0..<CoreDataCells.count {
                        let CoreDataSegments = CoreDataCells[j].segments.allObjects as! [Segment]
                        
                        if CoreDataSegments.count != 0 {
                            for m in 0..<CoreDataSegments.count {
                                let CoreDataSynapses = CoreDataSegments[m].synapses.allObjects as! [Synapse]
                                
                                if CoreDataSynapses.count != 0 {
                                    for n in 0..<CoreDataSynapses.count {
                                        let connectedX = Int(CoreDataSynapses[n].connectedX)
                                        let connectedY = Int(CoreDataSynapses[n].connectedY)
                                        let newSynapse = LearningSynapse(coor: Pair(first: connectedX, second: connectedY), per: CoreDataSynapses[n].permanence)
                                        
                                        synapses.append(newSynapse)
                                    }
                                } else {
                                    print("[FetchColumns] CoreDataSynapses is empty!")
                                }
                                
                                let newSegment = LearningSegment(syn: synapses, coor: Pair(first: columnX, second: columnY), index: j, count: CoreDataSynapses.count)
                                
                                segments.append(newSegment)
                                synapses.removeAll()
                            }
                        } else {
                            print("[FetchColumns] CoreDataSegments is empty!")
                        }
                        
                        let newCell = LearningCell(index: j, cellcoor: Pair(first: columnX, second: columnY), segments: segments)
                        
                        cells.append(newCell)
                        segments.removeAll()
                    }
                    
                    fetchColumn.links = links
                    fetchColumn.Cells = cells
                    
                    columns[columnY][columnX] = fetchColumn
                    
                    links.removeAll()
                    cells.removeAll()
                }
                
                let Layer = LayerComponent(layerP: CoreDataLayerParameters, columns: columns)
                cortex.append(Layer)
            }
            
            /* MARK: print some elements to check the data is correct
             .
             .
             .
             .
            */
        } catch {
            print("[FetchColumns] Cannot fetch DATE!")
        }
        
        return cortex
    }
    
    public func UpdateRecord(RecordIndex: Int, newCortex: [LayerComponent]) {
        let currentDate = GetCurrentTime()
        
        let context = appDelegate.persistentContainer.viewContext
        let DateFetchRequest = NSFetchRequest<TrainRecord>(entityName: "TrainRecord")
        
        do {
            let records = try context.fetch(DateFetchRequest)
            
            if records.count < RecordIndex + 1 || records.isEmpty {
                records[RecordIndex].setValue(currentDate, forKey: "date")
                
                print("[Before Delete]Count of cortex in record is \(records[RecordIndex].cortex.count)")
                records[RecordIndex].removeFromCortex(records[RecordIndex].cortex)
                print("[After Delete]Count of cortex in record is \(records[RecordIndex].cortex.count)")
                
                if records[RecordIndex].cortex.count == 0 {
                    for layerIndex in 0..<newCortex.count {
                        let newColumns = newCortex[layerIndex].columns
                        let LayerColumnsSize = newCortex[layerIndex].layerParameters.ColumnsSize
                        
                        let layer = NSEntityDescription.insertNewObject(forEntityName: "Layer", into: context) as! Layer
                                                
                        layer.setValue(newCortex[layerIndex].layerParameters.ColumnsSize, forKey: "columnssize")
                        layer.setValue(newCortex[layerIndex].layerParameters.LinkCount, forKey: "linkscount")
                        layer.setValue(newCortex[layerIndex].layerParameters.CellsCount, forKey: "cellscount")
                        layer.setValue(Int(newCortex[layerIndex].layerParameters.ColumnActiveThreshold * 100), forKey: "cat")
                        layer.setValue(Int(newCortex[layerIndex].layerParameters.LinkActiveThreshold * 100), forKey: "lat")
                        layer.setValue(Int(newCortex[layerIndex].layerParameters.FaultTolerance * 100), forKey: "faulttolerance")
                        layer.setValue(newCortex[layerIndex].layerParameters.WinnerColumnsPercentage, forKey: "wcc")
                        layer.setValue(Int(newCortex[layerIndex].layerParameters.IncrementValue * 100), forKey: "incrementvalue")
                        layer.setValue(Int(newCortex[layerIndex].layerParameters.DecrementValue * 100), forKey: "decrementvalue")
                        layer.setValue(newCortex[layerIndex].layerParameters.CurrentTrainIndex, forKey: "cti")
                        
                        for row in 0..<LayerColumnsSize {
                            for col in 0..<LayerColumnsSize {
                                let column = NSEntityDescription.insertNewObject(forEntityName: "Column", into: context) as! Column
                                
                                // Add links to column
                                for link in newColumns[row][col].links {
                                    let newLink = NSEntityDescription.insertNewObject(forEntityName: "Link", into: context) as! Link
                                    newLink.permanence = link.Permanence
                                    newLink.connectedX = Int16(link.connectedX)
                                    newLink.connectedY = Int16(link.connectedY)
                                    
                                    column.addToLinks(newLink)
                                }
                                
                                // Add cells to column
                                for cell in newColumns[row][col].Cells {
                                    let newCell = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: context) as! Cell
                                    
                                    for segment in cell.segments {
                                        let newSegment = NSEntityDescription.insertNewObject(forEntityName: "Segment", into: context) as! Segment
                                        
                                        for synapse in segment.synapse {
                                            let newSynapse = NSEntityDescription.insertNewObject(forEntityName: "Synapse", into: context) as! Synapse
                                            
                                            newSynapse.connectedX = Int16(synapse.connectCellCoordinate.first)
                                            newSynapse.connectedY = Int16(synapse.connectCellCoordinate.second)
                                            newSynapse.permanence = synapse.permenance
                                            
                                            newSegment.addToSynapses(newSynapse)
                                        }
                                        
                                        newCell.addToSegments(newSegment)
                                    }
                                    
                                    newCell.index = Int16(cell.IndexInColumn)
                                    
                                    column.addToCells(newCell)
                                }
                                
                                // Add parameters to column
                                column.activedutycycle = newColumns[row][col].activeDutyCycle
                                column.boostvalue = newColumns[row][col].boostValue
                                column.timeaverageactivation = Int16(newColumns[row][col].timeAveragedActivation)
                                
                                layer.addToColumns(column)
                            }
                        }
                        
                        records[RecordIndex].addToCortex(layer)
                    }                    
                } else {
                    print("[UpdateRecord] This reocrd's columns have not been erased!")
                }
            } else {
                print("[UpdateRecord] CoreData count is incorrect!")
            }
        } catch {
            print("[UpdateRecord] Cannot fetch data from CoreData")
        }
    }
    
    public func getCurrentTrainRecordCount() -> Int {
        var count: Int = 0
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TrainRecord>(entityName: "TrainRecord")
        fetchRequest.propertiesToFetch = ["date"]
        
        do {
            let result = try context.fetch(fetchRequest)
            count = result.count
        } catch {
            print("[getCurrentTrainRecordCount] No data in CoreData!")
        }
        
        return count
    }
    
    public func GetTrainingRecordDetail() -> [RecordDetail] {
        var details = [RecordDetail]()
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TrainRecord>(entityName: "TrainRecord")
        fetchRequest.propertiesToFetch = ["linkscount", "cat", "wcc", "date"]
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                let lc = result.value(forKey: "linkscount") as! Int
                let cat = result.value(forKey: "cat") as! Int
                let wcc = result.value(forKey: "wcc") as! Int
                let date = result.value(forKey: "date") as! String
                let detail = RecordDetail(lc: lc, cat: cat, wcc: wcc, date: date)
                details.append(detail)
            }
        } catch {
            print("[GetTrainingRecordDetail] Cannot get records' detail!")
        }
        
        return details
    }
}
