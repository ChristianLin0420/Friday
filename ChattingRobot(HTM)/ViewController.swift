//
//  ViewController.swift
//  ChattingRobot(HTM)
//
//  Created by Christian on 2019/8/2.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit

@IBDesignable

class ViewController: UIViewController {
    
    private var tempTimer = Timer()
    private var TimerCount = 0
    
    private var shapeLayer: CAShapeLayer!
    private var pulsatingLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    
    private let HTMuserdefaults = UserDefaults.standard
    private var HTM_array = ["Tzuyu1", "Tzuyu2", "Tzuyu3", "Tzuyu4", "Tzuyu5", "Tzuyu6", "Tzuyu7", "Tzuyu8", "Tzuyu9", "Tzuyu10", "Tzuyu11", "Tzuyu12", "Tzuyu13", "Tzuyu14", "Tzuyu15"]
    
    private let Data = DataClassification()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    private let finishLabel: UILabel = {
        let label = UILabel()
        label.text = "Finished"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return label
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .NSExtensionHostWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = view.center
        return layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        reloadingCoreData()
        setupNotificationObservers()
        setupCircleLayers()
        setupPercentageLabel()
        titleViewSetting()
        tempTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in self.animationCountDown()}
    }
    
    private func reloadingCoreData() {
        HTMuserdefaults.set(HTM_array, forKey: "array")
        HTMuserdefaults.synchronize()
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.4
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func titleViewSetting() {
        let gradientView = UIView()
        gradientView.frame = CGRect(x: 0, y: self.view.frame.height  * 0.12, width: self.view.frame.width, height: self.view.frame.height * 0.1)
        let gradient = CAGradientLayer()
        
        gradient.colors = [UIColor.LabelgradientUpperColor.cgColor, UIColor.LabelgradientLowerColor.cgColor]
        
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        
        let label = UILabel(frame: gradientView.bounds)
        label.text = "Friday"
        label.font = UIFont(name: "TimeBurner", size: 72.0)
         
        label.textAlignment = .center
        gradientView.addSubview(label)
        gradientView.mask = label
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    private func handleTap() {
        tempTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in self.animationCountDown()}
    }
    
    @objc private func animationCountDown() {
        percentageLabel.text = "\(TimerCount)"
        if TimerCount < 100 {
            TimerCount += 1
            percentageLabel.isUserInteractionEnabled = false
            shapeLayer.strokeEnd = CGFloat(TimerCount) / CGFloat(100)
        } else {
            tempTimer.invalidate()
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: [],
                animations: {
                    self.percentageLabel.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY - 10)
                    self.percentageLabel.font = UIFont.systemFont(ofSize: 36)
                },
                completion: { position in
                    self.view.addSubview(self.finishLabel)
                    self.finishLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
                    self.finishLabel.center = CGPoint(x: self.view.frame.midX, y: self.percentageLabel.frame.midY + 30)
                    
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.4,
                        delay: 1.0,
                        options: [],
                        animations: {
                            self.view.alpha = 0
                        },
                        completion: { position in
                            self.performSegue(withIdentifier: "GoToSelect", sender: self)
                    })
            })
        }
    }
}

