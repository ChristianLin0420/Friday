//
//  ShowResult.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2020/2/27.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit

class ShowResult: UIView {
    
    let patternWidth: CGFloat = 366
    let patternHeight: CGFloat = 259
    
    private let LearnCharacterVC = LearnCharacterViewController()
    private let GraphVC = LearningGraphViewController()
    private let Data = DataClassification()
    
    public var showCorrect = false
    public var showMatch = false
    public var showUnMatch = false
    public var showWrong = false
    public var showDataIndex = -1
    public var CharacterID = "xxxx"
    public var TrainRecord = [Correctness]()
    public var LineWidth: CGFloat = 500
    
    private var dataDotsCollect = [CAShapeLayer]()
    
    private var ShiftInterval: CGFloat = 1

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        let rulerYaxisY = patternHeight * 0.05
        let rulerOriginalX = patternWidth * 0.05
        let rulerOriginalY = patternHeight * 0.95
        let rulerXaxisX = patternWidth * 0.95
        
        let rulerPath = UIBezierPath()
        rulerPath.move(to: CGPoint(x: rulerOriginalX, y: rulerYaxisY))
        rulerPath.addLine(to: CGPoint(x: rulerOriginalX, y: rulerOriginalY))
        rulerPath.addLine(to: CGPoint(x: rulerXaxisX, y: rulerOriginalY))
        
        rulerPath.move(to: CGPoint(x: rulerOriginalX * 0.5, y: rulerYaxisY * 1.8))
        rulerPath.addLine(to: CGPoint(x: rulerOriginalX, y: rulerYaxisY))
        rulerPath.addLine(to: CGPoint(x: rulerOriginalX * 1.5, y: rulerYaxisY * 1.8))
        
        rulerPath.move(to: CGPoint(x: rulerXaxisX * 0.97, y: rulerOriginalY * 0.97))
        rulerPath.addLine(to: CGPoint(x: rulerXaxisX, y: rulerOriginalY))
        rulerPath.addLine(to: CGPoint(x: rulerXaxisX * 0.97, y: rulerOriginalY * 1.03))
        
        UIColor.lightGray.setStroke()
        rulerPath.stroke()
        rulerPath.lineWidth = 30
        
        if CharacterID == "" { return }
        if TrainRecord.isEmpty { return }
        
        let maxDots = InputsSize * InputsSize
        let CharmaxDots = getCharacterDotsCount(id: CharacterID)
        let widthInterval: CGFloat = 0.9 * patternWidth / CGFloat(TrainRecord.count)
        
        // Clean all dots on the line chart, and avoid memory issue
        for layer in dataDotsCollect { layer.removeFromSuperlayer() }
        dataDotsCollect.removeAll()
        
        // Draw match line
        if showMatch {
            let matchPath = UIBezierPath()
            
            let heightRatio: CGFloat = 0.9 * patternHeight / CGFloat(maxDots)
            let x0: CGFloat = rulerOriginalX + ShiftInterval
            let y0: CGFloat = CGFloat(maxDots - TrainRecord[0].MatchCount) * heightRatio + rulerYaxisY
            
            matchPath.move(to: CGPoint(x: x0, y: y0))
            
            for i in 1..<TrainRecord.count {
                matchPath.addLine(to: CGPoint(x: x0 + CGFloat(i) * widthInterval, y: CGFloat(maxDots - TrainRecord[i].MatchCount) * heightRatio + rulerYaxisY))
            }
            
            UIColor.green.setStroke()
            matchPath.stroke()
            matchPath.lineWidth = LineWidth
            
            if showDataIndex != -1 {
                let center = CGPoint(x: x0 + CGFloat(showDataIndex) * widthInterval, y: CGFloat(maxDots - TrainRecord[showDataIndex].MatchCount) * heightRatio + rulerYaxisY)
                let dataCircle = UIBezierPath(arcCenter: center, radius: 3.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = dataCircle.cgPath

                shapeLayer.fillColor = UIColor.green.cgColor
                shapeLayer.strokeColor = UIColor.green.cgColor
                shapeLayer.lineWidth = 3.0
                
                dataDotsCollect.append(shapeLayer)
                self.layer.addSublayer(shapeLayer)
            }
        }
        
        // Draw unmatch line
        if showUnMatch {
            let unMatchPath = UIBezierPath()
            
            let unmatchheightRatio: CGFloat = 0.9 * patternHeight / CGFloat(CharmaxDots)
            let p0: CGFloat = rulerOriginalX + ShiftInterval
            let q0: CGFloat = CGFloat(CharmaxDots - TrainRecord[0].NotMatchCount) * unmatchheightRatio + rulerYaxisY
            
            unMatchPath.move(to: CGPoint(x: p0, y: q0))
            
            for i in 1..<TrainRecord.count {
                unMatchPath.addLine(to: CGPoint(x: p0 + CGFloat(i) * widthInterval, y: CGFloat(CharmaxDots - TrainRecord[i].NotMatchCount) * unmatchheightRatio + rulerYaxisY))
            }
            
            UIColor.red.setStroke()
            unMatchPath.stroke()
            unMatchPath.lineWidth = LineWidth
            
            if showDataIndex != -1 {
                let center = CGPoint(x: p0 + CGFloat(showDataIndex) * widthInterval, y: CGFloat(CharmaxDots - TrainRecord[showDataIndex].NotMatchCount) * unmatchheightRatio + rulerYaxisY)
                let dataCircle = UIBezierPath(arcCenter: center, radius: 3.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = dataCircle.cgPath

                shapeLayer.fillColor = UIColor.red.cgColor
                shapeLayer.strokeColor = UIColor.red.cgColor
                shapeLayer.lineWidth = 3.0
                
                dataDotsCollect.append(shapeLayer)
                self.layer.addSublayer(shapeLayer)
            }
        }
        
        // Draw wrong line
        if showWrong {
            let wrongPath = UIBezierPath()
            
            let wrongMaxDots = maxDots - CharmaxDots
            let wrongHeightRatio: CGFloat = 0.9 * patternHeight / CGFloat(wrongMaxDots)
            let r0: CGFloat = rulerOriginalX + ShiftInterval
            let s0: CGFloat = CGFloat(wrongMaxDots - TrainRecord[0].WrongCount) * wrongHeightRatio + rulerYaxisY
            
            wrongPath.move(to: CGPoint(x: r0, y: s0))
            
            for i in 1..<TrainRecord.count {
                wrongPath.addLine(to: CGPoint(x: r0 + CGFloat(i) * widthInterval, y: CGFloat(wrongMaxDots - TrainRecord[i].WrongCount) * wrongHeightRatio + rulerYaxisY))
            }
            
            UIColor.orange.setStroke()
            wrongPath.stroke()
            wrongPath.lineWidth = LineWidth
            
            if showDataIndex != -1 {
                let center = CGPoint(x: r0 + CGFloat(showDataIndex) * widthInterval, y: CGFloat(wrongMaxDots - TrainRecord[showDataIndex].WrongCount) * wrongHeightRatio + rulerYaxisY)
                let dataCircle = UIBezierPath(arcCenter: center, radius: 3.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = dataCircle.cgPath

                shapeLayer.fillColor = UIColor.orange.cgColor
                shapeLayer.strokeColor = UIColor.orange.cgColor
                shapeLayer.lineWidth = 3.0
                
                dataDotsCollect.append(shapeLayer)
                self.layer.addSublayer(shapeLayer)
            }
        }
        
        // Draw percentage line
        if showCorrect {
            let percentagePath = UIBezierPath()
            
            let percentageMax = 100
            let percentageHeightRatio: CGFloat = 0.9 * patternHeight / CGFloat(percentageMax)
            let m0: CGFloat = rulerOriginalX + ShiftInterval
            let n0: CGFloat = CGFloat(percentageMax - TrainRecord[0].CorrectPercentage) * percentageHeightRatio + rulerYaxisY
            
            percentagePath.move(to: CGPoint(x: m0, y: n0))
            
            for i in 1..<TrainRecord.count {
                percentagePath.addLine(to: CGPoint(x: m0 + CGFloat(i) * widthInterval, y: CGFloat(percentageMax - TrainRecord[i].CorrectPercentage) * percentageHeightRatio + rulerYaxisY))
            }
            
            UIColor.white.setStroke()
            percentagePath.stroke()
            percentagePath.lineWidth = LineWidth
            
            if showDataIndex != -1 {
                let center = CGPoint(x: m0 + CGFloat(showDataIndex) * widthInterval, y: CGFloat(percentageMax - TrainRecord[showDataIndex].CorrectPercentage) * percentageHeightRatio + rulerYaxisY)
                let dataCircle = UIBezierPath(arcCenter: center, radius: 3.0, startAngle: 0.0, endAngle: CGFloat.pi * 2.0, clockwise: true)
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = dataCircle.cgPath

                shapeLayer.fillColor = UIColor.white.cgColor
                shapeLayer.strokeColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 3.0
                
                dataDotsCollect.append(shapeLayer)
                self.layer.addSublayer(shapeLayer)
            }
        }
    }

    private func getCharacterDotsCount(id: String) -> Int {
        let charactersRecord = Data.scanBDFdata()
        
        for i in 0..<charactersRecord.count {
            if id == charactersRecord[i].codeID {
                var count = 0
                
                for row in 0..<charactersRecord[i].BBX_height {
                    for col in 0..<charactersRecord[i].BBX_width {
                        if charactersRecord[i].bitmap[row][col] == 1 {
                            count += 1
                        }
                    }
                }
                
                return count
            }
        }
        
        return 0
    }
}
