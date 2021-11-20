//
//  SLOTKeyframe.swift
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

import Foundation
import CoreGraphics
import UIKit

class SLOTKeyframe: Equatable {
    var keyframeTime : Double = 0.0
    var isHold : Bool = false
    var inTangent : CGPoint = .zero
    var outTangent : CGPoint = .zero
    var spatialInTangent : CGPoint = .zero
    var spatialOutTangent : CGPoint = .zero
    var floatValue : CGFloat?
    var pointValue : CGPoint?
    var sizeValue : CGSize?
    var colorValue : UIColor?
    var pathData : SLOTBezierData?
    var arrayValue : Array<Any>?
    
    init(keyframe: Dictionary<String,Any>) {
        
        switch keyframe["t"] {
        case let v as Double:
            keyframeTime = v
        case let v as Int:
            keyframeTime = Double(v)
        default:
            break
        }
        
        if let timingOutTangent = keyframe["o"] as? [String: Any] {
            outTangent = point(values: timingOutTangent)
        }
        
        if let timingInTangent = keyframe["i"] as? [String: Any] {
            inTangent = point(values: timingInTangent)
        }
        
        if let _ = keyframe["h"] as? Bool {
            isHold = true
        }
        
        if let to = keyframe["to"] as? [Double] {
            spatialOutTangent = point(values: to)
        }
        
        if let ti = keyframe["ti"] as? [Double] {
            spatialInTangent = point(values: ti)
        }
        
        if let data = keyframe["s"] {
            setupOutput(data: data)
        }
    }
    
    init(value: Any) {
        keyframeTime = 0
        isHold = true
        setupOutput(data: value)
    }
    
    init(keyframe: SLOTKeyframe) {
        self.keyframeTime = keyframe.keyframeTime
        self.inTangent = keyframe.inTangent
        self.outTangent = keyframe.outTangent
        self.spatialInTangent = keyframe.spatialInTangent
        self.spatialOutTangent = keyframe.spatialOutTangent
        self.isHold = keyframe.isHold
    }
    
    func setupOutput(data: Any) {
        switch data {
        case let v as Double:
            floatValue = CGFloat(v)
        case let v as Array<Double>:
            if v.count > 0 {
                floatValue = CGFloat(v[0])
            }
            if v.count > 1 {
                floatValue = CGFloat(v[1])
                pointValue = CGPoint(x: CGFloat(v[0]), y: CGFloat(v[1]))
                sizeValue = CGSize(width: pointValue!.x, height: pointValue!.y)
            }
            if v.count > 3 {
                colorValue = colorValue(from: v)
            }
            arrayValue = v
        case let v as Array<Dictionary<String,Any>>:
            if let firstObject = v.first {
                pathData = SLOTBezierData.init(data: firstObject)
            }
        case let v as Dictionary<String,Any>:
            pathData = SLOTBezierData.init(data: v)
        default:
            fatalError("SLOTKeyframe setOutput unhandled data = \(data)")
        }
    }
    
    private func colorValue(from a: Array<Double>) -> UIColor? {
        if a.count == 4 {
            var divisor = 1.0
            if let _ = a.first(where: {$0 > 1.0}) {
                divisor = 255.0
            }
            
            let c = UIColor.init(red: CGFloat(a[0]/divisor), green: CGFloat(a[1]/divisor), blue: CGFloat(a[2]/divisor), alpha: CGFloat(a[3]/divisor))
            
            return c
        }
        return nil
    }
    
    private func point(values: [String: Any]) -> CGPoint {
        var xValue = 0.0
        var yValue = 0.0
        
        switch values["x"] {
        case let v as Double:
            xValue = v
        case let v as Int:
            xValue = Double(v)
        case let v as [Double]:
            xValue = v[0]
        default:
            break
        }
        
        switch values["y"] {
        case let v as Double:
            yValue = v
        case let v as Int:
            yValue = Double(v)
        case let v as [Double]:
            yValue = v[0]
        default:
            break
        }
        
        return CGPoint(x: xValue, y: yValue)
    }
    
    private func point(values: [Double]) -> CGPoint {
        var returnPoint: CGPoint = .zero
        
        if values.count > 1 {
            returnPoint.x = CGFloat(values[0])
            returnPoint.y = CGFloat(values[1])
        }
        
        return returnPoint
    }
    
    func remapValue(with remapBlock: (CGFloat) -> (CGFloat)) {
        if let fv = floatValue {
            floatValue = remapBlock(fv)
        }
        if let pv = pointValue {
            pointValue = CGPoint(x: remapBlock(pv.x), y: remapBlock(pv.y))
        }
        if let sv = sizeValue {
            sizeValue = CGSize(width: remapBlock(sv.width), height: remapBlock(sv.height))
        }
    }
    
    func copy(data: Any) -> SLOTKeyframe {
        let newFrame = SLOTKeyframe(keyframe: self)
        newFrame.set(data: data)
        return newFrame
    }
    
    func set(data: Any) {
        setupOutput(data: data)
    }
    
    // May not be quite right given that pathData is Any
    static func ==(lhs: SLOTKeyframe, rhs: SLOTKeyframe) -> Bool {
        
        let colorsEqual: Bool
        if let lhsColor = lhs.colorValue, let rhsColor = rhs.colorValue {
            colorsEqual = lhsColor.isEqual(rhsColor)
        } else if lhs.colorValue == nil && rhs.colorValue == nil {
            colorsEqual = true
        } else {
            colorsEqual = false
        }
        
        return lhs.keyframeTime == rhs.keyframeTime &&
        lhs.isHold == rhs.isHold &&
        lhs.inTangent == rhs.inTangent &&
        lhs.outTangent == rhs.outTangent &&
        lhs.spatialInTangent == rhs.spatialInTangent &&
        lhs.spatialOutTangent == rhs.spatialOutTangent &&
        lhs.floatValue == rhs.floatValue &&
        lhs.pointValue == rhs.pointValue &&
        lhs.sizeValue == rhs.sizeValue &&
        colorsEqual /*&&
        lhs.pathData == rhs.pathData &&
        lhs.arrayValue == rhs.arrayValue*/
    }
}
