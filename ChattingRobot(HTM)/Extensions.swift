//
//  Extensions.swift
//  CircleAnimationDemo
//
//  Created by Brian Voong on 11/19/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import CoreData

extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let LabelgradientUpperColor = UIColor.rgb(r: 0, g: 249, b: 0)
    static let LabelgradientLowerColor = UIColor.rgb(r: 0, g: 118, b: 186)
    static let outlineStrokeColor = UIColor.rgb(r: 48, g: 228, b: 71)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 88, g: 142, b: 106)
}


