//
//  MenuViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2019/9/5.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var LearningConditionTableView: UITableView!
    
    private var selectIndex = 0
    
    private let HTMuserdefaults = UserDefaults.standard
    private var DataCount = 0
    private var array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.LearningConditionTableView.rowHeight = 105

        if let bufferArray = HTMuserdefaults.object(forKey: "array") {
            array = bufferArray as! [String]
        } else {
            array = [""]
        }
        
        DataCount = array.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChattingHistoryTableViewCell
        
        var indicatorBackgroundColor = UIColor.lightGray
        
        switch indexPath.row % 2 {
        case 0: indicatorBackgroundColor = UIColor.rgb(r: 138, g: 242, b: 3)
        case 1: indicatorBackgroundColor = UIColor.rgb(r: 0, g: 162, b: 255)
        default : break
        }
        
//        cell.Indicator.backgroundColor = indicatorBackgroundColor
//        cell.Indicator.alpha = 0.5
        cell.Indicator.alpha = 0.0
        cell.AI_name.text = " Tzuyu"
        cell.AI_name.textColor = indicatorBackgroundColor
        cell.AI_name.alpha = 1.0
        cell.timeLabel.text = "7:24 PM"
        cell.LastComment.text = (indexPath.row % 2 == 0) ? "   Stay Hungry, Stay Foolish......." : "   One in a million, Tzuyu......."
        cell.AI_img.image = UIImage(named: array[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = AnimationFactory.makeSlideIn(duration: 0.3, delayFactor: 0.02)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChattingHistoryTableViewCell
        
        var indicatorBackgroundColor = UIColor.lightGray
        selectIndex = indexPath.row
        print("indexRow = \(indexPath.row)")
        
        HTMuserdefaults.set(selectIndex, forKey: "selectIndex")
        HTMuserdefaults.synchronize()
        
        switch indexPath.row % 2 {
        case 0: indicatorBackgroundColor = UIColor.rgb(r: 138, g: 242, b: 3)
        case 1: indicatorBackgroundColor = UIColor.rgb(r: 0, g: 162, b: 255)
        default : break
        }
        
        cell.Indicator.backgroundColor = indicatorBackgroundColor
        cell.Indicator.alpha = 0.8
        
        performSegue(withIdentifier: "chatlog", sender: self)
    }
}


// Animation
typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

final class Animator {
    private var hasAnimatedAllCells = false
    private let animation: Animation
    
    init(animation: @escaping Animation) {
        self.animation = animation
    }
    
    func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
        guard !hasAnimatedAllCells else {
            return
        }
        
        animation(cell, indexPath, tableView)
        
        hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
    }
}

extension UITableView {
    func isLastVisibleCell(at indexPath: IndexPath) -> Bool {
        guard let lastIndexPath = indexPathsForVisibleRows?.last else {
            return false
        }
        
        return lastIndexPath == indexPath
    }
}

enum AnimationFactory {
    
    static func makeFade(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, _ in
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                animations: {
                    cell.alpha = 1
            })
        }
    }
    
    static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.1,
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    static func makeSlideIn(duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
            })
        }
    }
    
    static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
        return { cell, indexPath, tableView in
            cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
            cell.alpha = 0
            
            UIView.animate(
                withDuration: duration,
                delay: delayFactor * Double(indexPath.row),
                options: [.curveEaseInOut],
                animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    cell.alpha = 1
            })
        }
    }
}

