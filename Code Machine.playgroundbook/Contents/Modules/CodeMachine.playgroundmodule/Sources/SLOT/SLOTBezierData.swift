//
//  SLOTBezierData.swift
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
import QuartzCore

class SLOTBezierData {
    private(set) var count : Int = 0
    private(set) var closed : Bool = false
    
    private var _vertices: UnsafeMutablePointer<CGPoint>
    private var _inTangents: UnsafeMutablePointer<CGPoint>
    private var _outTangents: UnsafeMutablePointer<CGPoint>
    
    init(data: Dictionary<String,Any>) {
        guard let pointsArray = data["v"] as? [[Double]], let inTangents = data["i"] as? [[Double]], let outTangents = data["o"] as? [[Double]] else { fatalError("Shape has no vertices, points, or tangents")}
        assert((pointsArray.count == inTangents.count) && (pointsArray.count == outTangents.count), "Lottie: Incorrect number of points and tangents")
        
        count = pointsArray.count
        _vertices = UnsafeMutablePointer<CGPoint>.allocate(capacity: count)
        _inTangents = UnsafeMutablePointer<CGPoint>.allocate(capacity: count)
        _outTangents = UnsafeMutablePointer<CGPoint>.allocate(capacity: count)
        
        if let closed = data["c"] as? Int {
            self.closed = (closed == 0) ? false : true
        }
        
        for i in 0..<pointsArray.count {
            let vertex = _vertex(index: i, in: pointsArray)
            let outTan = SLOT_PointAddedToPoint(vertex, _vertex(index: i, in: outTangents))
            let inTan = SLOT_PointAddedToPoint(vertex, _vertex(index: i, in: inTangents))
            _vertices[i] = vertex
            _inTangents[i] = inTan
            _outTangents[i] = outTan
        }
    }
    
    deinit {
        _vertices.deallocate()
        _inTangents.deallocate()
        _outTangents.deallocate()
    }
    
    func vertex(index: Int) -> CGPoint {
        return _vertices[index]
    }
    
    func inTangent(index: Int) -> CGPoint {
        return _inTangents[index]
    }
    
    func outTangent(index: Int) -> CGPoint {
        return _outTangents[index]
    }
    
    private func _vertex(index idx: Int, in points: [[Double]]) -> CGPoint {
        assert(idx < points.count, "Lottie: Vertex point out of bounds")
        
        let pointArray = points[idx]
        
        return CGPoint(x: pointArray[0], y: pointArray[1])
    }
}
