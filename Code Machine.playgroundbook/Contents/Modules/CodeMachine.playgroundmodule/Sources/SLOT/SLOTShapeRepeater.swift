//
//  SLOTShapeRepeater.swift
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


class SLOTShapeRepeater {

    var keyname: String?
    var copies: SLOTKeyframeGroup?
    var offset: SLOTKeyframeGroup?
    var anchorPoint: SLOTKeyframeGroup?
    var scale: SLOTKeyframeGroup?
    var position: SLOTKeyframeGroup?
    var rotation: SLOTKeyframeGroup?
    var startOpacity: SLOTKeyframeGroup?
    var endOpacity: SLOTKeyframeGroup?
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let data = json["c"] as? [String: Any] {
            copies = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["o"] as? [String: Any] {
            offset = SLOTKeyframeGroup(data: data)
        }
        
        guard let transform = json["tr"] as? [String: Any] else { return }
        
        if let data = transform["r"] as? [String: Any] {
            rotation = SLOTKeyframeGroup.init(data: data)
            rotation?.remapKeyframes { (inValue) in
                return SLOT_DegreesToRadians(inValue)
            }
        }
        
        if let data = transform["so"] as? [String: Any] {
            startOpacity = SLOTKeyframeGroup(data: data)
            startOpacity?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        if let data = transform["eo"] as? [String: Any] {
            endOpacity = SLOTKeyframeGroup(data: data)
            endOpacity?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        if let data = transform["a"] as? [String: Any] {
            anchorPoint = SLOTKeyframeGroup(data: data)
        }
        
        if let data = transform["p"] as? [String: Any] {
            position = SLOTKeyframeGroup(data: data)
        }
        
        if let data = transform["s"] as? [String: Any] {
            scale = SLOTKeyframeGroup(data: data)
            scale?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
    }
}
