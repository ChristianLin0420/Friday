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

class Record {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private func GetCurrentTime() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date = Date()
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    public func InsertNewRecord(cortex: [[[miniColumn]]], LayerParameters: [LayerParameter]) {
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
                layer.setValue(LayerParameters[layerIndex].LinkActiveThreshold, forKey: "linkactivethreshold")
                layer.setValue(LayerParameters[layerIndex].FaultTolerance, forKey: "faulttolerance")
                layer.setValue(LayerParameters[layerIndex].WinnerColumnsPercentage, forKey: "winnercolumnsratio")
                layer.setValue(LayerParameters[layerIndex].IncrementValue, forKey: "incrementvalue")
                layer.setValue(LayerParameters[layerIndex].DecrementValue, forKey: "decrementvalue")
                
                for row in 0..<LayerParameters[layerIndex].ColumnsSize {
                    for col in 0..<LayerParameters[layerIndex].ColumnsSize {
                        let column = NSEntityDescription.insertNewObject(forEntityName: "Column", into: context) as! Column
                        
                        // Add links to column
                        for link in cortex[layerIndex][row][col].Links {
                            let newLink = NSEntityDescription.insertNewObject(forEntityName: "Link", into: context) as! Link
                            newLink.permanence = link.Permanence
                            newLink.connectedX = Int16(link.ConnectedCoordinate.first)
                            newLink.connectedY = Int16(link.ConnectedCoordinate.second)
                            
                            column.addToLinks(newLink)
                        }
                        
                        // Add cells to column
                        for cell in cortex[layerIndex][row][col].Cells {
                            let newCell = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: context) as! Cell
                            
                            for segment in cell.dendrites {
                                let newSegment = NSEntityDescription.insertNewObject(forEntityName: "Segment", into: context) as! Segment
                                
                                for synapse in segment.synapses {
                                    let newSynapse = NSEntityDescription.insertNewObject(forEntityName: "Synapse", into: context) as! Synapse
                                    
                                    newSynapse.connectedX = Int16(synapse.connectCellCoordinate.first)
                                    newSynapse.connectedY = Int16(synapse.connectCellCoordinate.second)
                                    newSynapse.permanence = synapse.permenance
                                    
                                    newSegment.addToSynapses(newSynapse)
                                }
                                
                                newCell.addToSegments(newSegment)
                            }
                            
                            column.addToCells(newCell)
                        }
                        
                        // Add parameters to column
                        column.activedutycycle = cortex[layerIndex][row][col].ActivatedDutyCycle
                        column.boostvalue = cortex[layerIndex][row][col].BoostValue
                        column.timeaverageactivation = Int16(cortex[layerIndex][row][col].TimeAveragedActivation)
                        
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
            
            var links: [miniLink] = []
            var cells: [miniCell] = []
            var segments: [miniDendrite] = []
            var synapses: [miniSynapse] = []
            
            let CoreDataCortex = result[RecordIndex].cortex.allObjects as! [Layer]
            
            for layerIndex in 0..<CoreDataCortex.count {
                let CoreDataColumns = CoreDataCortex[layerIndex].columns.allObjects as! [Column]
                
                let CoreDataColumnSize: Int = Int(CoreDataCortex[layerIndex].columnssize)
                let CoreDataLinkCount: Float = CoreDataCortex[layerIndex].lowerlinksratio
                let CoreDataCellsCount: Int = Int(CoreDataCortex[layerIndex].cellscount)
                let CoreDataLinkActiveThreshold: Float = CoreDataCortex[layerIndex].linkactivethreshold
                let CoreDataFaultTolerance: Float = CoreDataCortex[layerIndex].faulttolerance
                let CoreDataWinnerColumnsPercentage: Float = CoreDataCortex[layerIndex].winnercolumnsratio
                let CoreDataIncrementValue: Float = CoreDataCortex[layerIndex].incrementvalue
                let CoreDataDecrementValue: Float = CoreDataCortex[layerIndex].decrementvalue
                
                let CoreDataLayerParameters = LayerParameter(cs: CoreDataColumnSize, llp: CoreDataLinkCount,
                                                             cc: CoreDataCellsCount, lat: CoreDataLinkActiveThreshold,
                                                             ft: CoreDataFaultTolerance, wcc: CoreDataWinnerColumnsPercentage,
                                                             iv: CoreDataIncrementValue, dv: CoreDataDecrementValue)
                
                var columns = Array(repeating: Array(repeating: miniColumn(coordinate: Pair(first: -1, second: -1)), count: CoreDataColumnSize), count: CoreDataColumnSize)
                
                for i in 0..<CoreDataColumns.count {
                    let CoreDataLinks = CoreDataColumns[i].links.allObjects as! [Link]
                    let CoreDataCells = CoreDataColumns[i].cells.allObjects as! [Cell]
                    
                    let columnX = i % CoreDataColumnSize
                    let columnY = i / CoreDataColumnSize
                    let fetchColumn = miniColumn(coordinate: Pair(first: columnX, second: columnY))
                    
                    // Fetch links data
                    for j in 0..<CoreDataLinks.count {
                        let Coordinate = Pair(first: Int(CoreDataLinks[j].connectedX), second: Int(CoreDataLinks[j].connectedY))
                        let newLink = miniLink(permanence: CoreDataLinks[j].permanence, coordinate: Coordinate)
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
                                        let newSynapse = miniSynapse(coordinate: Pair(first: connectedX, second: connectedY), index: n, permenance: CoreDataSynapses[n].permanence)
                                        
                                        synapses.append(newSynapse)
                                    }
                                } else {
                                    print("[FetchColumns] CoreDataSynapses is empty!")
                                }
                                
                                let newSegment = miniDendrite(index: j, coordinate: Pair(first: columnX, second: columnY), syn: synapses, id: m)
                                
                                segments.append(newSegment)
                                synapses.removeAll()
                            }
                        } else {
                            print("[FetchColumns] CoreDataSegments is empty!")
                        }
                        
                        let newCell = miniCell(index: j, coordinate: Pair(first: columnX, second: columnY), dendrites: segments)
                        
                        cells.append(newCell)
                        segments.removeAll()
                    }
                    
                    fetchColumn.Links = links
                    fetchColumn.Cells = cells
                    
                    columns[columnY][columnX] = fetchColumn
                    
                    links.removeAll()
                    cells.removeAll()
                }
                
                let Layer = LayerComponent(
                                layerP: CoreDataLayerParameters,
                                columns: columns,
                                coefficient: TemperalPoolingCoefficient(
                                    pwc: [],
                                    pac: [],
                                    pas: [],
                                    pma: []))
                
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
            
            if records.count > RecordIndex && !records.isEmpty {
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
                        layer.setValue(newCortex[layerIndex].layerParameters.LowerLinkPercentage, forKey: "lowerlinksratio")
                        layer.setValue(newCortex[layerIndex].layerParameters.CellsCount, forKey: "cellscount")
                        layer.setValue(newCortex[layerIndex].layerParameters.LinkActiveThreshold, forKey: "linkactivethreshold")
                        layer.setValue(newCortex[layerIndex].layerParameters.FaultTolerance, forKey: "faulttolerance")
                        layer.setValue(newCortex[layerIndex].layerParameters.WinnerColumnsPercentage, forKey: "winnercolumnsratio")
                        layer.setValue(newCortex[layerIndex].layerParameters.IncrementValue, forKey: "incrementvalue")
                        layer.setValue(newCortex[layerIndex].layerParameters.DecrementValue, forKey: "decrementvalue")
                        
                        for row in 0..<LayerColumnsSize {
                            for col in 0..<LayerColumnsSize {
                                let column = NSEntityDescription.insertNewObject(forEntityName: "Column", into: context) as! Column
                                
                                // Add links to column
//                                for link in newColumns[row][col].links {
//                                    let newLink = NSEntityDescription.insertNewObject(forEntityName: "Link", into: context) as! Link
//                                    newLink.permanence = link.Permanence
//                                    newLink.connectedX = Int16(link.connectedX)
//                                    newLink.connectedY = Int16(link.connectedY)
//                                    
//                                    column.addToLinks(newLink)
//                                }
                                
                                // Add cells to column
                                for cell in newColumns[row][col].Cells {
                                    let newCell = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: context) as! Cell
                                    
                                    for segment in cell.dendrites {
                                        let newSegment = NSEntityDescription.insertNewObject(forEntityName: "Segment", into: context) as! Segment
                                        
                                        for synapse in segment.synapses {
                                            let newSynapse = NSEntityDescription.insertNewObject(forEntityName: "Synapse", into: context) as! Synapse
                                            
                                            newSynapse.connectedX = Int16(synapse.connectCellCoordinate.first)
                                            newSynapse.connectedY = Int16(synapse.connectCellCoordinate.second)
                                            newSynapse.permanence = synapse.permenance
                                            
                                            newSegment.addToSynapses(newSynapse)
                                        }
                                        
                                        newCell.addToSegments(newSegment)
                                    }
                                                                        
                                    column.addToCells(newCell)
                                }
                                
                                // Add parameters to column
//                                column.activedutycycle = newColumns[row][col].activeDutyCycle
//                                column.boostvalue = newColumns[row][col].boostValue
//                                column.timeaverageactivation = Int16(newColumns[row][col].timeAveragedActivation)
                                
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
