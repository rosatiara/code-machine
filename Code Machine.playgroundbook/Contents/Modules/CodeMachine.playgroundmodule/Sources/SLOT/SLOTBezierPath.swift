//
//  SLOTBezierPath.swift
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

enum Subpath {
    case none
    indirect case some(SLOT_SubPath)
}

// It was a struct in the ObjC version, but then they typically grabbed a pointer to it. Leaving as struct for now...
struct SLOT_SubPath {
    var type: CGPathElementType
    var length: CGFloat
    var endPoint: CGPoint
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint
    var nextSubpath: Subpath = .none
}

class SLOTBezierPath: Copyable {
    
    var cacheLengths: Bool = false
    
    var length: CGFloat = 0
    
    var CGPath: CGPath {
        return path
    }
    
    var currentPoint: CGPoint {
        return (tailSubpath != nil) ? tailSubpath!.endPoint : .zero
    }
    
    var lineWidth: CGFloat = 1
    var lineCapStyle: CGLineCap = .butt
    var lineJoinStyle: CGLineJoin = .miter
    var miterLimit: CGFloat = 10
    var flatness: CGFloat = 0.6
    var usesEvenOddFillRule: Bool = false
    
    var isEmpty: Bool {
        return path.isEmpty
    }
    var bounds: CGRect {
        return path.boundingBox
    }
    
    var headSubpath: SLOT_SubPath?
    private var tailSubpath: SLOT_SubPath?
    private var subpathStartPoint: CGPoint!
    private var lineDashPattern: CGFloat?
    private var lineDashCount: Int = 0
    private var lineDashPhase: CGFloat = 0
    private var path: CGMutablePath = CGMutablePath()
    
    class func newPath() -> SLOTBezierPath {
        return SLOTBezierPath()
    }
    
    deinit {
        removeAllSubpaths()
    }
    
    required init(other: SLOTBezierPath) {
        self.cacheLengths = other.cacheLengths
        self.length = other.length
        self.lineWidth = other.lineWidth
        self.lineCapStyle = other.lineCapStyle
        self.miterLimit = other.miterLimit
        self.flatness = other.flatness
        self.usesEvenOddFillRule = other.usesEvenOddFillRule
        self.headSubpath = other.headSubpath
        self.tailSubpath = other.tailSubpath
        self.subpathStartPoint = other.subpathStartPoint
        self.lineDashPattern = other.lineDashPattern
        self.lineDashCount = other.lineDashCount
        self.lineDashPhase = other.lineDashPhase
        self.path = other.path
    }
    
    init() {
        
    }
    
    private func removeAllSubpaths() {
        var node = headSubpath
        while node != nil {
            let nextNode = node!.nextSubpath
            node!.nextSubpath = .none
            switch nextNode {
            case .none:
                node = nil
            case .some(let value):
                node = value
            }
        }
        headSubpath = nil
        tailSubpath = nil
    }
    
    private func addSubpath(type: CGPathElementType, length: CGFloat, endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        let subPath = SLOT_SubPath(type: type, length: length, endPoint: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2, nextSubpath: .none)
        
        if tailSubpath == nil {
            headSubpath = subPath
            tailSubpath = subPath
        } else {
            tailSubpath?.nextSubpath = .some(subPath)
            tailSubpath = subPath
        }
    }
    
    func SLOT_move(to point: CGPoint) {
        subpathStartPoint = point
        addSubpath(type: .moveToPoint, length: 0, endPoint: point, controlPoint1: .zero, controlPoint2: .zero)
        path.move(to: point)
    }
    
    func SLOT_addLine(to point: CGPoint) {
        var length: CGFloat = 0
        if cacheLengths {
            length = SLOT_PointDistanceFromPoint(currentPoint, point)
            self.length += length
        }
        addSubpath(type: .addLineToPoint, length: length, endPoint: point, controlPoint1: .zero, controlPoint2: .zero)
        path.addLine(to: point)
    }
    
    func SLOT_addCurve(to point: CGPoint, controlPoint1 cp1: CGPoint, controlPoint2 cp2: CGPoint) {
        var length: CGFloat = 0
        if cacheLengths {
            length = SLOT_CubicLengthWithPrecision(fromPoint: self.currentPoint, toPoint: point, controlPoint1: cp1, controlPoint2: cp2, iterations: 5)
            self.length += length
        }
        addSubpath(type: .addCurveToPoint, length: length, endPoint: point, controlPoint1: cp1, controlPoint2: cp2)
        path.addCurve(to: point, control1: cp1, control2: cp2)
    }
    
    func SLOT_closePath() {
        var length: CGFloat = 0
        if cacheLengths {
            length = SLOT_PointDistanceFromPoint(self.currentPoint, subpathStartPoint)
            self.length += length
        }
        addSubpath(type: .closeSubpath, length: length, endPoint: subpathStartPoint, controlPoint1: .zero, controlPoint2: .zero)
        path.closeSubpath()
    }
    
    private func clearPathData() {
        length = 0
        subpathStartPoint = .zero
        path = CGMutablePath()
    }
    
    func SLOT_removeAllPoints() {
        removeAllSubpaths()
        clearPathData()
    }
    
    func contains(point: CGPoint) -> Bool {
        return path.contains(point, using: usesEvenOddFillRule ? .evenOdd : .winding, transform: .identity)
    }
    
    func SLOT_apply(transform: CGAffineTransform) {
        let mutablePath = CGMutablePath()
        mutablePath.addPath(path, transform: transform)
        path = mutablePath
    }
    
    func SLOT_append(bezierPath: SLOTBezierPath) {
        path.addPath(bezierPath.CGPath)
        var nextSubpath = bezierPath.headSubpath
        while nextSubpath != nil {
            var length: CGFloat = 0
            if cacheLengths {
                if bezierPath.cacheLengths {
                    length = nextSubpath!.length
                } else {
                    if nextSubpath!.type == .addLineToPoint {
                        length = SLOT_PointDistanceFromPoint(self.currentPoint, nextSubpath!.endPoint)
                    } else if nextSubpath!.type == .addCurveToPoint {
                        length = SLOT_CubicLengthWithPrecision(fromPoint: self.currentPoint, toPoint: nextSubpath!.endPoint, controlPoint1: nextSubpath!.controlPoint1, controlPoint2: nextSubpath!.controlPoint2, iterations: 5)
                    } else if nextSubpath!.type == .closeSubpath {
                        length = SLOT_PointDistanceFromPoint(self.currentPoint, nextSubpath!.endPoint)
                    }
                }
            }
            self.length += length
            addSubpath(type: nextSubpath!.type, length: length, endPoint: nextSubpath!.endPoint, controlPoint1: nextSubpath!.controlPoint1, controlPoint2: nextSubpath!.controlPoint2)
            switch nextSubpath!.nextSubpath {
            case .none:
                nextSubpath = nil
            case .some(let value):
                nextSubpath = value
            }
        }
    }
    
    func trimPath(fromT: CGFloat, toT: CGFloat, offset: CGFloat) {
        var fromT = fromT
        var toT = toT
        var offset = offset
        if fromT > toT {
            let to = fromT
            fromT = toT
            toT = to
        }
        
        offset = offset - floor(offset)
        var fromLength = fromT + offset
        var toLength = toT + offset
        
        if toT - fromT == 1 {
            return
        }
        
        if fromLength == toLength {
            SLOT_removeAllPoints()
            return
        }
        
        if fromLength >= 1 {
            fromLength -= floor(fromLength)
        }
        if toLength > 1 {
            toLength -= floor(toLength)
        }
        
        if fromLength == 0 && toLength == 1 {
            return
        }
        
        if fromLength == toLength {
            SLOT_removeAllPoints()
        }
        
        let totalLength = self.length
        clearPathData()
        
        var subpath = headSubpath
        headSubpath = nil
        tailSubpath = nil
        
        fromLength *= totalLength
        toLength *= totalLength
        
        var currentStartLength = (fromLength < toLength) ? fromLength : 0
        var currentEndLength = toLength
        
        var subpathBeginningLength: CGFloat = 0
        var currentPoint: CGPoint = .zero
        
        while subpath != nil {
            var pathLength = subpath!.length
            if !cacheLengths {
                if subpath!.type == .addLineToPoint {
                    pathLength = SLOT_PointDistanceFromPoint(currentPoint, subpath!.endPoint)
                } else if subpath!.type == .addCurveToPoint {
                    pathLength = SLOT_CubicLengthWithPrecision(fromPoint: currentPoint, toPoint: subpath!.endPoint, controlPoint1: subpath!.controlPoint1, controlPoint2: subpath!.controlPoint2, iterations: 5)
                } else if subpath!.type == .closeSubpath {
                    pathLength = SLOT_PointDistanceFromPoint(currentPoint, subpath!.endPoint)
                }
            }
            let subpathEndLength = subpathBeginningLength + pathLength
            if subpath!.type != .moveToPoint && subpathEndLength > currentStartLength {
                let currentSpanStartT = SLOT_RemapValue(value: currentStartLength, low1: subpathBeginningLength, high1: subpathEndLength, low2: 0, high2: 1)
                var currentSpanEndT = SLOT_RemapValue(value: currentEndLength, low1: subpathBeginningLength, high1: subpathEndLength, low2: 0, high2: 1)
                
                if subpath!.type == .addLineToPoint {
                    if currentSpanStartT >= 0 {
                        if currentSpanStartT > 0 {
                            currentPoint = SLOT_PointInLine(currentPoint, subpath!.endPoint, currentSpanStartT)
                        }
                        SLOT_move(to: currentPoint)
                    }
                    var toPoint = subpath!.endPoint
                    if currentSpanEndT < 1 {
                        toPoint = SLOT_PointInLine(currentPoint, subpath!.endPoint, currentSpanEndT)
                    }
                    SLOT_addLine(to: toPoint)
                    currentPoint = toPoint
                } else if subpath!.type == .addCurveToPoint {
                    var cp1 = subpath!.controlPoint1
                    var cp2 = subpath!.controlPoint2
                    var end = subpath!.endPoint
                    
                    if currentSpanStartT >= 0 {
                        if currentSpanStartT > 0 {
                            let A = SLOT_PointInLine(currentPoint, cp1, currentSpanStartT)
                            let B = SLOT_PointInLine(cp1, cp2, currentSpanStartT)
                            let C = SLOT_PointInLine(cp2, end, currentSpanStartT)
                            let D = SLOT_PointInLine(A, B, currentSpanStartT)
                            let E = SLOT_PointInLine(B, C, currentSpanStartT)
                            let F = SLOT_PointInLine(D, E, currentSpanStartT)
                            currentPoint = F
                            cp1 = E
                            cp2 = C
                            currentSpanEndT = SLOT_RemapValue(value: currentSpanEndT, low1: currentSpanStartT, high1: 1, low2: 0, high2: 1)
                        }
                        SLOT_move(to: currentPoint)
                    }
                    
                    if currentSpanEndT < 1 {
                        let A = SLOT_PointInLine(currentPoint, cp1, currentSpanEndT)
                        let B = SLOT_PointInLine(cp1, cp2, currentSpanEndT)
                        let C = SLOT_PointInLine(cp2, end, currentSpanEndT)
                        let D = SLOT_PointInLine(A, B, currentSpanEndT)
                        let E = SLOT_PointInLine(B, C, currentSpanEndT)
                        let F = SLOT_PointInLine(D, E, currentSpanEndT)
                        cp1 = A;
                        cp2 = D;
                        end = F;
                    }
                    SLOT_addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
                }
                
                if currentSpanEndT <= 1 {
                    if fromLength < toLength {
                        while subpath != nil {
                            let nextNode = subpath!.nextSubpath
                            subpath!.nextSubpath = .none
                            switch nextNode {
                            case .none:
                                subpath = nil
                            case .some(let value):
                                subpath = value
                            }
                        }
                        break
                    } else {
                        currentStartLength = fromLength
                        currentEndLength = totalLength
                    }
                }
            }
            currentPoint = subpath!.endPoint
            subpathBeginningLength = subpathEndLength
            
            let nextNode = subpath!.nextSubpath
            subpath!.nextSubpath = .none
            switch nextNode {
            case .none:
                subpath = nil
            case .some(let value):
                subpath = value
            }
        }
    }
}
