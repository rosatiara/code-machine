//
//  CGGeometry-SLOTAdditions.swift
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

func SLOT_RemapValue(value: CGFloat, low1: CGFloat, high1: CGFloat, low2: CGFloat, high2: CGFloat ) -> CGFloat {
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

func SLOT_DegreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees * .pi / 180.0;
}

func SLOT_RectGetCenterPoint(_ rect: CGRect) -> CGPoint {
    return CGPoint(x: rect.midX, y: rect.midY)
}

func SLOT_CGPointIsZero(_ point: CGPoint) -> Bool {
    return __CGPointEqualToPoint(point, .zero)
}

func SLOT_Squared(_ f: CGFloat) -> CGFloat {
    return f * f
}

func SLOT_Cubed(_ f: CGFloat) -> CGFloat {
    return f * f * f
}

func SLOT_CubicRoot(_ f: CGFloat) -> CGFloat {
    return CGFloat(powf(Float(f), 1.0/3.0))
}

func SLOT_SolveQuadratic(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    
    var result = (-b + (SLOT_Squared(b) - 4 * a * c)) / (2 * a)
    if result >= 0 && result <= 1 { return result }
    
    result = (-b - (SLOT_Squared(b) - 4 * a * c)) / (2 * a)
    if result >= 0 && result <= 1 { return result }
    
    return -1
}

func SLOT_SolveCubic(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
    let a = a
    var b = b
    var c = c
    var d = d
    
    if a == 0 { return SLOT_SolveQuadratic(b, c, d) }
    if d == 0 { return 0 }
    
    b /= a
    c /= a
    d /= a
    
    var q = (3.0 * c - SLOT_Squared(b)) / 9.0
    let r = (-27.0 * d + b * (9.0 * c - 2.0 * SLOT_Squared(b))) / 54.0
    let disc = SLOT_Cubed(q) + SLOT_Squared(r)
    let term1 = b / 3.0
    
    if disc > 0 {
        var s = r + CGFloat(sqrtf(Float(disc)))
        s = (s < 0) ? (SLOT_CubicRoot(-s) * -1) : SLOT_CubicRoot(s)
        var t = r - CGFloat(sqrtf(Float(disc)))
        t = (t < 0) ? (SLOT_CubicRoot(-t) * -1) : SLOT_CubicRoot(t)
        
        let result = -term1 + s + t
        if result >= 0 && result <= 1 { return result }
    } else if disc == 0 {
        let r13 = (r < 0) ? (SLOT_CubicRoot(-r) * -1) : SLOT_CubicRoot(r)
        
        var result = -term1 + 2.0 * r13
        if result >= 0 && result <= 1 { return result }
        
        result = -(r13 + term1)
        if result >= 0 && result <= 1 { return result }
    } else {
        q = -q;
        var dum1 = q * q * q;
        dum1 = CGFloat(acosf(Float(r) / sqrtf(Float(dum1))))
        let r13 = CGFloat(2.0 * sqrtf(Float(q)))
        
        var result = -term1 + r13 * cos(dum1 / 3.0);
        if result >= 0 && result <= 1 { return result }
        
        result = -term1 + r13 * cos((dum1 + CGFloat(2.0 * .pi)) / 3.0)
        if result >= 0 && result <= 1 { return result }
        
        result = -term1 + r13 * cos((dum1 + CGFloat(4.0 * .pi)) / 3.0)
        if result >= 0 && result <= 1 { return result }
    }
    
    return -1
}

func SLOT_CubicBezierInterpolate(P0: CGPoint, P1: CGPoint, P2: CGPoint, P3: CGPoint, x: CGFloat) -> CGFloat {
    var t: CGFloat
    
    if x == P0.x {
        // Handle corner cases explicitly to prevent rounding errors
        t = 0
    } else if x == P3.x {
        t = 1
    } else {
        //Calculate t
        let a = -P0.x + 3 * P1.x - 3 * P2.x + P3.x
        let b = 3 * P0.x - 6 * P1.x + 3 * P2.x
        let c = -3 * P0.x + 3 * P1.x
        let d = P0.x - x
        let tTemp = SLOT_SolveCubic(a,b,c,d)
        if tTemp == -1 { return -1 }
        t = tTemp
    }
    
    return SLOT_Cubed(1 - t) * P0.y + 3 * t * SLOT_Squared(1 - t) * P1.y + 3 * SLOT_Squared(t) * (1 - t) * P2.y + SLOT_Cubed(t) * P3.y
}

func SLOT_PointDistanceFromPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    let xDist = point2.x - point1.x
    let yDist = point2.y - point1.y
    return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
}

func SLOT_CubicLengthWithPrecision(fromPoint: CGPoint, toPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint, iterations: CGFloat) -> CGFloat {
    var iterations = Float(iterations)
    var length: CGFloat = 0
    var previousPoint = fromPoint
    iterations = ceilf(iterations)
    
    for i in 1..<Int(iterations) {
        let s = Float(i) / iterations
        let p = SLOT_PointInCubicCurve(fromPoint, controlPoint1, controlPoint2, toPoint, CGFloat(s))
        
        length += SLOT_PointDistanceFromPoint(previousPoint, p)
        previousPoint = p
    }
    
    return length
}

// Should just be an extension on CGPoint, but...I’m just gonna follow what they do...
func SLOT_PointAddedToPoint(_ point1: CGPoint, _ point2: CGPoint) -> CGPoint {
    var returnPoint = point1
    returnPoint.x += point2.x
    returnPoint.y += point2.y
    return returnPoint
}

func SLOT_PointInLine(_ A: CGPoint, _ B: CGPoint, _ T: CGFloat) -> CGPoint {
    return CGPoint(x: A.x - ((A.x - B.x) * T), y: A.y - ((A.y - B.y) * T))
}

func SLOT_PointInCubicCurve(_ start: CGPoint, _ cp1: CGPoint, _ cp2: CGPoint, _ end: CGPoint, _ T: CGFloat) -> CGPoint {
    let A = SLOT_PointInLine(start, cp1, T)
    let B = SLOT_PointInLine(cp1, cp2, T)
    let C = SLOT_PointInLine(cp2, end, T)
    let D = SLOT_PointInLine(A, B, T)
    let E = SLOT_PointInLine(B, C, T)
    let F = SLOT_PointInLine(D, E, T)
    return F
}

