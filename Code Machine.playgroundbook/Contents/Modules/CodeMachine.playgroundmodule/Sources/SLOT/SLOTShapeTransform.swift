//
//  SLOTShapeTransform.swift
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


class SLOTShapeTransform {

    var keyname: String?
    var position: SLOTKeyframeGroup?
    var anchor: SLOTKeyframeGroup?
    var scale: SLOTKeyframeGroup?
    var rotation: SLOTKeyframeGroup?
    var opacity: SLOTKeyframeGroup?
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let data = json["p"] as? [String: Any] {
            position = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["a"] as? [String: Any] {
            anchor = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["s"] as? [String: Any] {
            scale = SLOTKeyframeGroup(data: data)
            scale?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        if let data = json["r"] as? [String: Any] {
            rotation = SLOTKeyframeGroup.init(data: data)
            rotation?.remapKeyframes { (inValue) in
                return SLOT_DegreesToRadians(inValue)
            }
        }
        
        if let data = json["o"] as? [String: Any] {
            opacity = SLOTKeyframeGroup(data: data)
            opacity?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        var hasSkew = false
        if let data = json["sk"] as? [String: Any], let k = data["k"] as? Int {
            hasSkew = (k == 0)
        }
        
        var hasSkewAxis = false
        if let data = json["sa"] as? [String: Any], let k = data["k"] as? Int {
            hasSkewAxis = (k == 0)
        }
        
        if (hasSkew || hasSkewAxis) {
            //NSLog("SLOTShapeTransform: skew is not supported in: %@", keyname ?? "")
        }
    }
}
