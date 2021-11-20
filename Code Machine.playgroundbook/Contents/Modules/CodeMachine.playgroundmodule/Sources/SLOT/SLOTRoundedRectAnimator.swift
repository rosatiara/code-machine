//
//  SLOTRoundedRectAnimator.swift
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

class SLOTRoundedRectAnimator: SLOTAnimatorNode {
    
    private var centerInterpolator: SLOTPointInterpolator?
    private var sizeInterpolator: SLOTPointInterpolator?
    private var cornerRadiusInterpolator: SLOTNumberInterpolator?
    private var reversed = false
    
    init(inputNode: SLOTAnimatorNode?, shapeRectangle rectangle: SLOTShapeRectangle) {
        
        super.init(inputNode: inputNode, keyname: rectangle.keyname ?? "")
        
        if let keyframes = rectangle.position?.keyframes {
            centerInterpolator = SLOTPointInterpolator(keyframes: keyframes)
        }
        if let keyframes = rectangle.size?.keyframes {
            sizeInterpolator = SLOTPointInterpolator(keyframes: keyframes)
        }
        if let keyframes = rectangle.cornerRadius?.keyframes {
            cornerRadiusInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        reversed = rectangle.reversed
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
            if let interpolator = cornerRadiusInterpolator {
                interpolators["Roundness"] = interpolator
            }
            return interpolators.isEmpty ? nil : interpolators
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return (sizeInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (centerInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (cornerRadiusInterpolator?.hasUpdate(frame: frame) ?? false)
        
    }
    
    private func addCorner(_ cornerPoint: CGPoint, withRadius radius: CGFloat, toPath path: SLOTBezierPath, clockwise: Bool) {
        let currentPoint = path.currentPoint
        let ellipseControlPointPercentage = CGFloat(0.55228)
        
        if (cornerPoint.y == currentPoint.y) {
            // Moving east/west
            if (cornerPoint.x < currentPoint.x) {
                // Moving west
                let corner = CGPoint(x: cornerPoint.x + radius, y: currentPoint.y)
                path.SLOT_addLine(to: corner)
                if radius > 0 {
                    let curvePoint = clockwise ? CGPoint(x: cornerPoint.x, y: cornerPoint.y - radius) : CGPoint(x: cornerPoint.x, y: cornerPoint.y + radius)
                    let cp1 = CGPoint(x: corner.x - (radius * ellipseControlPointPercentage), y: corner.y)
                    let cp2 = clockwise ?
                        CGPoint(x: curvePoint.x, y: curvePoint.y + (radius * ellipseControlPointPercentage)) :
                        CGPoint(x: curvePoint.x, y: curvePoint.y - (radius * ellipseControlPointPercentage))
                    path.SLOT_addCurve(to: curvePoint, controlPoint1: cp1, controlPoint2: cp2)
                }
            } else {
                // Moving east
                let corner = CGPoint(x: cornerPoint.x - radius, y: currentPoint.y)
                path.SLOT_addLine(to: corner)
                if radius > 0 {
                    let curvePoint = clockwise ? CGPoint(x: cornerPoint.x, y: cornerPoint.y + radius) : CGPoint(x: cornerPoint.x, y: cornerPoint.y - radius)
                    let cp1 = CGPoint(x: corner.x + (radius * ellipseControlPointPercentage), y: corner.y)
                    let cp2 = clockwise ?
                        CGPoint(x: curvePoint.x, y: curvePoint.y - (radius * ellipseControlPointPercentage)) :
                        CGPoint(x: curvePoint.x, y: curvePoint.y + (radius * ellipseControlPointPercentage))
                    path.SLOT_addCurve(to: curvePoint, controlPoint1: cp1, controlPoint2: cp2)
                }
            }
        } else {
            // Moving North/South
            if (cornerPoint.y < currentPoint.y) {
                // Moving North
                let corner = CGPoint(x: currentPoint.x, y: cornerPoint.y + radius)
                path.SLOT_addLine(to: corner)
                if radius > 0 {
                    let curvePoint = clockwise ? CGPoint(x: cornerPoint.x + radius, y: cornerPoint.y) : CGPoint(x: cornerPoint.x - radius, y: cornerPoint.y)
                    let cp1 = CGPoint(x: corner.x, y: corner.y  - (radius * ellipseControlPointPercentage))
                    let cp2 = clockwise ?
                        CGPoint(x: curvePoint.x - (radius * ellipseControlPointPercentage), y: curvePoint.y) :
                        CGPoint(x: curvePoint.x + (radius * ellipseControlPointPercentage), y: curvePoint.y)
                    path.SLOT_addCurve(to: curvePoint, controlPoint1: cp1, controlPoint2: cp2)
                }
                
            } else {
                // moving south
                let corner = CGPoint(x: currentPoint.x, y: cornerPoint.y - radius)
                path.SLOT_addLine(to: corner)
                if radius > 0 {
                    let curvePoint = clockwise ? CGPoint(x: cornerPoint.x - radius, y: cornerPoint.y) : CGPoint(x: cornerPoint.x + radius, y: cornerPoint.y)
                    let cp1 = CGPoint(x: corner.x, y: corner.y  + (radius * ellipseControlPointPercentage))
                    let cp2 = clockwise ?
                        CGPoint(x: curvePoint.x + (radius * ellipseControlPointPercentage), y: curvePoint.y) :
                        CGPoint(x: curvePoint.x - (radius * ellipseControlPointPercentage), y: curvePoint.y)
                    path.SLOT_addCurve(to: curvePoint, controlPoint1: cp1, controlPoint2: cp2)
                }
            }
        }
    }
    
    override func performLocalUpdate() {
        guard let centerInterpolator = centerInterpolator,
            let sizeInterpolator = sizeInterpolator,
            let cornerRadiusInterpolator = cornerRadiusInterpolator,
            let frame = currentFrame else { return }
        
        let position = centerInterpolator.pointValue(frame: frame)
        let size = sizeInterpolator.pointValue(frame: frame)
        let cornerRadius = cornerRadiusInterpolator.floatValue(frame: frame)
        
        let halfWidth = size.x / 2
        let halfHeight = size.y / 2
        
        let rectFrame = CGRect(x: position.x - halfWidth, y: position.y - halfHeight, width: size.x, height: size.y)
        
        let topLeft = CGPoint(x: rectFrame.minX, y: rectFrame.minY)
        let topRight = CGPoint(x: rectFrame.maxX, y: rectFrame.minY)
        let bottomLeft = CGPoint(x: rectFrame.minX, y: rectFrame.maxY)
        let bottomRight = CGPoint(x: rectFrame.maxX, y: rectFrame.maxY)
        // UIBezierPath Draws rects from the top left corner, After Effects draws them from the top right.
        // Switching to manual drawing.
        
        let radius = min(min(halfWidth, halfHeight), cornerRadius)
        let clockWise = !reversed
        
        let path1 = SLOTBezierPath()
        path1.cacheLengths = pathShouldCacheLengths
        let startPoint = clockWise ?
        CGPoint(x: topRight.x, y: topRight.y + radius) :
        CGPoint(x: topRight.x - radius, y: topRight.y)
        path1.SLOT_move(to :startPoint)
        if (clockWise) {
            addCorner(bottomRight, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(bottomLeft, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(topLeft, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(topRight, withRadius: radius, toPath: path1, clockwise: clockWise)
        } else {
            addCorner(topLeft, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(bottomLeft, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(bottomRight, withRadius: radius, toPath: path1, clockwise: clockWise)
            addCorner(topRight, withRadius: radius, toPath: path1, clockwise: clockWise)
        }
        path1.SLOT_closePath()
        localPath = path1
    }
}
