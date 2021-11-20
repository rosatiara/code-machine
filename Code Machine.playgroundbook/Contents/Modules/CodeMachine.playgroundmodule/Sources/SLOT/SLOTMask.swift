//
//  SLOTMask.swift
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

enum LOTMaskMode: Int {
    case LOTMaskModeAdd
    case LOTMaskModeSubtract
    case LOTMaskModeIntersect
    case LOTMaskModeUnknown
}

class SLOTMask {
    
    private(set) var closed = false
    private(set) var inverted = false
    private(set) var maskMode = LOTMaskMode.LOTMaskModeUnknown
    private(set) var maskPath: SLOTKeyframeGroup?
    private(set) var opacity: SLOTKeyframeGroup?
    private(set) var expansion: SLOTKeyframeGroup?
    
    init(json: Dictionary<String,Any>) {
        if let closed = json["c1"] as? Int {
            self.closed = (closed == 0) ? false : true
        }
        
        if let inverted = json["inv"] as? Int {
            self.inverted = (inverted == 0) ? false : true
        }
        
        if let mode = json["mode"] as? String {
            switch mode {
            case "a":
                maskMode = .LOTMaskModeAdd
            case "s":
                maskMode = .LOTMaskModeSubtract
            case "i":
                maskMode = .LOTMaskModeIntersect
            default:
                maskMode = .LOTMaskModeUnknown
            }
        }
        
        if let maskShape = json["pt"] as? [String: Any] {
            self.maskPath = SLOTKeyframeGroup(data: maskShape)
        }
        
        if let opacity = json["o"] as? [String: Any] {
            self.opacity = SLOTKeyframeGroup(data: opacity)
            self.opacity?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        if let expansion = json["x"] as? [String: Any] {
            self.expansion = SLOTKeyframeGroup(data: expansion)
        }
        
    }
}
