//
//  UIView+extensions.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit


extension UIView {
    
    func frameFor(normalizedRect: CGRect) -> CGRect {
        return CGRect(x: normalizedRect.origin.x * self.bounds.width, y: normalizedRect.origin.y * self.bounds.height,
                      width: normalizedRect.width * self.bounds.width, height: normalizedRect.height * self.bounds.height)
    }
    
    func toRadians(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
    
    func wobbleAndShake(speed: Speed = .normal) {
        let numberOfRepeats = speed.isFast ? 3 : 5
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = speed.isFast ? 0.1 : 0.2
        shakeAnimation.repeatCount = Float(numberOfRepeats)
        shakeAnimation.autoreverses = true
        let amplitude: Float = 5.0
        let from = CGPoint(x: self.center.x + CGFloat(Float.random(from: -amplitude, to: +amplitude)),
                                                      y: self.center.y + CGFloat(Float.random(from: -amplitude, to: +amplitude)))
        let to = CGPoint(x: self.center.x + CGFloat(Float.random(from: -amplitude, to: +amplitude)),
                           y: self.center.y + CGFloat(Float.random(from: -amplitude, to: +amplitude)))
        shakeAnimation.fromValue = from
        shakeAnimation.toValue = to
        layer.add(shakeAnimation, forKey: "wobbleAndShakePosition")
        
        let degrees: CGFloat = 3.0
        let wobbleAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobbleAnimation.duration = speed.isFast ? 0.15 : 0.25
        wobbleAnimation.isCumulative = true
        wobbleAnimation.repeatCount = Float(numberOfRepeats)
        wobbleAnimation.values = [0.0,
                            toRadians(-degrees) * 0.25,
                            0.0,
                            toRadians(degrees) * 0.5,
                            0.0,
                            toRadians(-degrees),
                            0.0,
                            toRadians(degrees),
                            0.0,
                            toRadians(-degrees) * 0.5,
                            0.0,
                            toRadians(degrees) * 0.25,
                            0.0]
        wobbleAnimation.fillMode = .forwards
        wobbleAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        wobbleAnimation.isRemovedOnCompletion = true
        layer.add(wobbleAnimation, forKey: "wobbleAndShakeTransform")
    }
    
    func jiggle(enabled: Bool) {
        if !enabled {
            layer.removeAnimation(forKey: "jigglePosition")
            layer.removeAnimation(forKey: "jiggleTransform")
            return
        }
        let numberOfRepeats = Float.greatestFiniteMagnitude
        
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.5
        shakeAnimation.repeatCount = numberOfRepeats
        shakeAnimation.autoreverses = true
        shakeAnimation.byValue = CGPoint(x: 0.20, y: 5.0)
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shakeAnimation.isRemovedOnCompletion = true
        layer.add(shakeAnimation, forKey: "jigglePosition")
        
        let degrees: CGFloat = 0.20
        let wobbleAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobbleAnimation.duration = 0.3
        wobbleAnimation.repeatCount = numberOfRepeats
        wobbleAnimation.values = [0.0,
        toRadians(-degrees) * 0.25,
        0.0,
        toRadians(degrees) * 0.5,
        0.0,
        toRadians(-degrees),
        0.0,
        toRadians(degrees),
        0.0,
        toRadians(-degrees) * 0.5,
        0.0,
        toRadians(degrees) * 0.25,
        0.0]
        wobbleAnimation.fillMode = .forwards
        wobbleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        wobbleAnimation.isRemovedOnCompletion = true
        layer.add(wobbleAnimation, forKey: "jiggleTransform")
    }
}
