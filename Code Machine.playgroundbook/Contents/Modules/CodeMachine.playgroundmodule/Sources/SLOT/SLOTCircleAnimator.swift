//
//  SLOTCircleAnimator.swift
//
// The source code contained in this file originated from 'lottie-ios' has been modified by Apple. The original source code is licensed under the Apache 2.0 license, available here:
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// and the original source code for 'lottie-ios' is available for download here:
//
//      https://github.com/airbnb/lottie-ios
//
// Modifications made by Apple are licensed under the Swift Playgrounds Software License, located at the root of this playground document.
//
// Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

let kLOTEllipseControlPointPercentage = CGFloat(0.55228)

class SLOTCircleAnimator: SLOTAnimatorNode {

    private var centerInterpolator: SLOTPointInterpolator?
    private var sizeInterpolator: SLOTPointInterpolator?
    private var reversed = false
    
    init(inputNode: SLOTAnimatorNode?, shapeCircle circle: SLOTShapeCircle) {

        super.init(inputNode: inputNode, keyname: circle.keyname ?? "")
        
        if let keyframes = circle.position?.keyframes {
            centerInterpolator = SLOTPointInterpolator(keyframes: keyframes)
        }
        if let keyframes = circle.size?.keyframes {
            sizeInterpolator = SLOTPointInterpolator(keyframes: keyframes)
        }
        reversed = circle.reversed
    }
    
    override var valueInterpolators: [String : Any]? {
        get {
            var interpolators = [String : Any]()
            if let interpolator = sizeInterpolator {
                interpolators["Size"] = interpolator
            }
            if let interpolator = centerInterpolator {
                interpolators["Position"] = interpolator
            }
            return interpolators.isEmpty ? nil : interpolators
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return (sizeInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (centerInterpolator?.hasUpdate(frame: frame) ?? false)

    }
    
    override func performLocalUpdate() {
        guard let centerInterpolator = centerInterpolator,
            let sizeInterpolator = sizeInterpolator,
            let frame = currentFrame else { return }
        
        // Unfortunately we HAVE to manually build out the ellipse.
        // Every Apple method constructs from the 3 o-clock position
        // After effects contrsucts from the Noon position.
        // After effects does clockwise, but also has a flag for reversed.
        
        let center = centerInterpolator.pointValue(frame: frame)
        let size = sizeInterpolator.pointValue(frame: frame)
        
        var halfWidth = size.x / 2
        let halfHeight = size.y / 2
        
        if reversed {
            halfWidth = halfWidth * -1
        }
        
        let circleQ1 = CGPoint(x: center.x, y: center.y - halfHeight)
        let circleQ2 = CGPoint(x: center.x + halfWidth, y: center.y)
        let circleQ3 = CGPoint(x: center.x, y: center.y + halfHeight)
        let circleQ4 = CGPoint(x: center.x - halfWidth, y: center.y)
        
        let cpW = halfWidth * kLOTEllipseControlPointPercentage
        let cpH = halfHeight * kLOTEllipseControlPointPercentage
        
        let path = SLOTBezierPath()
        path.cacheLengths = pathShouldCacheLengths
        path.SLOT_move(to: circleQ1)
        path.SLOT_addCurve(to: circleQ2, controlPoint1: CGPoint(x: circleQ1.x + cpW, y: circleQ1.y), controlPoint2: CGPoint(x: circleQ2.x, y: circleQ2.y - cpH))
        path.SLOT_addCurve(to: circleQ3, controlPoint1: CGPoint(x: circleQ2.x, y: circleQ2.y + cpH), controlPoint2: CGPoint(x: circleQ3.x + cpW, y: circleQ3.y))
        path.SLOT_addCurve(to: circleQ4, controlPoint1: CGPoint(x: circleQ3.x - cpW, y: circleQ3.y), controlPoint2: CGPoint(x: circleQ4.x, y: circleQ4.y + cpH))
        path.SLOT_addCurve(to: circleQ1, controlPoint1: CGPoint(x: circleQ4.x, y: circleQ4.y - cpH), controlPoint2: CGPoint(x: circleQ1.x - cpW, y: circleQ1.y))
        localPath = path
    }
}
