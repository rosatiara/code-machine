//
//  SLOTKeyframeGroup.swift
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

class SLOTKeyframeGroup {
    var keyframes = Array<SLOTKeyframe>()
    
    init(data: Any) {
        switch data {
        case let v as Dictionary<String,Any>:
            if let k = v["k"] {
                buildKeyframes(data: k)
            }
        default:
            buildKeyframes(data: data)
        }
    }
    
    private func buildKeyframes(data: Any) {
        switch data {
        case let v as Array<Dictionary<String,Any>> where v[0]["t"] != nil:
            // Array of keyframes
            var previousFrame : Dictionary<String,Any>?
            for keyframe in v {
                var currentFrame = Dictionary<String,Any>()
                if let v = keyframe["t"] { currentFrame["t"] = v }
                if let v = keyframe["s"] { 
                    currentFrame["s"] = v 
                }
                else if let v = previousFrame, let vv = v["e"] {
                    currentFrame["s"] = vv
                }
                if let v = keyframe["o"] { currentFrame["o"] = v }
                
                if let v = previousFrame, let vv = v["i"] {
                    currentFrame["i"] = vv
                }
                if let v = keyframe["to"] { currentFrame["to"] = v }
                if let v = previousFrame, let vv = v["ti"] {
                    currentFrame["ti"] = vv
                }
                if let v = keyframe["h"] { currentFrame["h"] = v }
                let key = SLOTKeyframe.init(keyframe: currentFrame)
                keyframes.append(key)
                previousFrame = keyframe
            }
        default:
            let keyframe = SLOTKeyframe.init(value: data)
            keyframes.append(keyframe)
        }
    }
    
    func remapKeyframes(remapBlock : (CGFloat) -> (CGFloat)) {
        for keyframe in keyframes {
            keyframe.remapValue(with: remapBlock)
        }
    }
}
