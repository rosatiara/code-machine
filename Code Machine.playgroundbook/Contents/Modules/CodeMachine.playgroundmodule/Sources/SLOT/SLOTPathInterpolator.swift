//
//  SLOTPathInterpolator.swift
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

import CoreGraphics

class SLOTPathInterpolator : SLOTValueInterpolator {
    public func path(frame: Double, cacheLengths: Bool) -> SLOTBezierPath {
        let progress = self.progress(frame: frame)
        
        let returnPath = SLOTBezierPath()
        returnPath.cacheLengths = cacheLengths
        let leadingData = self.leadingKeyframe?.pathData
        let trailingData = self.trailingKeyframe?.pathData
        var vertexCount = 0
        var closePath = false
        if let ld = leadingData, ld.count > 0 {
            vertexCount = ld.count
            closePath = ld.closed
        }
        else if let td = trailingData, td.count > 0 {
            vertexCount = td.count
            closePath = td.closed
        }
        var cp1 = CGPoint.zero
        var cp2 = CGPoint.zero
        var p1 = CGPoint.zero
        var cp3 = CGPoint.zero
        var startPoint = CGPoint.zero
        var startInTangent = CGPoint.zero
        for i in 0..<vertexCount {
            if (progress == 0) {
                if let ld = leadingData {
                    cp2 = ld.inTangent(index: i)
                    p1 = ld.vertex(index: i)
                    cp3 = ld.outTangent(index: i)
                }
            } else if (progress == 1) {
                if let td = trailingData {
                    cp2 = td.inTangent(index: i)
                    p1 = td.vertex(index: i)
                    cp3 = td.outTangent(index: i)
                }
            } else {
                if let ld = leadingData, let td = trailingData {
                    cp2 = SLOT_PointInLine(ld.inTangent(index: i), td.inTangent(index: i), progress)
                    p1 = SLOT_PointInLine(ld.vertex(index: i), td.vertex(index: i), progress)
                    cp3 = SLOT_PointInLine(ld.outTangent(index: i), td.outTangent(index: i), progress)
                }
            }
            if i == 0 {
                startPoint = p1
                startInTangent = cp2
                returnPath.SLOT_move(to: p1)
            } else {
                returnPath.SLOT_addCurve(to: p1, controlPoint1: cp1, controlPoint2: cp2)
            }
            cp1 = cp3
        }
        
        if closePath {
            returnPath.SLOT_addCurve(to: startPoint, controlPoint1: cp3, controlPoint2: startInTangent)
            returnPath.SLOT_closePath()
        }
        
        return returnPath
    }
}
