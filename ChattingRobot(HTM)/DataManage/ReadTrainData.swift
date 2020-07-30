//
//  ReadTrainData.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/3/17.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation

class DataClassification {
    public func scanBDFdata() -> [CharacterData] {
        let BDFfileURL = Bundle.main.url(forResource: "HanWangMingLight-24", withExtension: "bdf")
        var currentDataIndex = 0
        var stringToSave = [String]()
        var string = ""
        var Characters = [CharacterData]()
        
        do {
            string = try String(contentsOf: BDFfileURL!, encoding: .ascii)
        } catch {
            print("Cannot read the midi file!!!")
        }
        
        stringToSave = string.components(separatedBy: [" ", "\n"])
        
        while currentDataIndex < stringToSave.count {
            if stringToSave[currentDataIndex] == "STARTCHAR" {
                var code_id_temp = stringToSave[currentDataIndex + 1]
                var isChinese = false
                let removeCharaters = ["u", "n", "i"]
                
                if code_id_temp.contains("uni") {
                    isChinese = true
                    for index in 0...2 {
                        if let i = code_id_temp.firstIndex(of: Character(removeCharaters[index])) {
                            code_id_temp.remove(at: i)
                        }
                    }
                }
                
                let code_id: String = code_id_temp
                var width: Int = 0
                var height: Int = 0
                var Bitmap: [[Int]] = [[0]]
                                
                currentDataIndex += 2
                
                while stringToSave[currentDataIndex] != "ENDCHAR" {
                    switch stringToSave[currentDataIndex] {
                    case "ENCODING":
                        currentDataIndex += 2
                    case "SWIDTH":
                        currentDataIndex += 3
                    case "DWIDTH":
                        currentDataIndex += 3
                    case "BBX" :
                        width = Int(stringToSave[currentDataIndex + 1], radix: 10)!
                        height = Int(stringToSave[currentDataIndex + 2], radix: 10)!
                        currentDataIndex += 5
                    case "BITMAP" :
                        Bitmap.removeAll()
                        for index in 1...height {
                            Bitmap.append(stringToOctal(EncodeString: stringToSave[currentDataIndex + index], pixelCount: ((width / 8) + 1) * 8))
                        }
                        currentDataIndex += (height + 1)
                    default:
                        currentDataIndex += 1
                    }
                }
                                
                let data = CharacterData(id: code_id, w: width, h: height, map: Bitmap)
                
                if isChinese, code_id.count == 4 {
                    Characters.append(data)
                }
            } else {
                currentDataIndex += 1
            }
        }

        return Characters
    }
    
    private func interger2binary(input: Int, pixelCount: Int) -> [Int] {
        var binaryArray = Array(repeating: 0, count: pixelCount)
        var val = input
        var currentIndex = pixelCount - 1
        
        while val > 0 {
            binaryArray[currentIndex] = val % 2
            val /= 2
            currentIndex -= 1
        }
        
        return binaryArray
    }
    
    private func stringToOctal(EncodeString: String, pixelCount: Int) -> [Int] {
        let OctalValue = Int(EncodeString, radix: 16)
        let oneDimensionPixelArray = interger2binary(input: OctalValue!, pixelCount: pixelCount)
        
        return oneDimensionPixelArray
    }
    
    // Read Characters Chart
    public func ReadChart() -> [String] {
        var result = [String]()
        let filename = "ChineseCharactersChart.txt"
        
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let textCount = text.count
                
                if textCount > 0 {
                    for i in 0..<textCount {
                        let lowerBound = text.index(text.startIndex, offsetBy: i)
                        let upperBound = text.index(text.startIndex, offsetBy: i + 1)
                        let subString = String(text[lowerBound..<upperBound])
                        
                        if subString.count == 1, subString != "\n" {
                            result.append(subString)
                        }
                    }
                }
            } catch {
                print("Failed to read text from \(filename)")
            }
        } else {
            print("Failed to load file from app bundle \(filename)")
        }
        
        return result
    }
    
    // Read Article
    public func ReadArticle() -> [String] {
        var result = [String]()
        let filename = "Article_1.txt"
        
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                let textCount = text.count
                
                if textCount > 0 {
                    for i in 0..<textCount {
                        let lowerBound = text.index(text.startIndex, offsetBy: i)
                        let upperBound = text.index(text.startIndex, offsetBy: i + 1)
                        let subString = String(text[lowerBound..<upperBound])
                        
                        if subString.count == 1, subString != "\n" {
                            result.append(subString)
                        }
                    }
                }
            } catch {
                print("Failed to read text from \(filename)")
            }
        } else {
            print("Failed to load file from app bundle \(filename)")
        }
        
        print("Article contents: \(result)")
        
        return result
    }
}
