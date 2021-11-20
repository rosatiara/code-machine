//
//  SLOTShapeGradientFill.swift
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

enum LOTGradientType: Int {
    case LOTGradientTypeLinear
    case LOTGradientTypeRadial
}


class SLOTShapeGradientFill {

    var keyname: String?
    var numberOfColors: Int?
    var startPoint: SLOTKeyframeGroup?
    var endPoint: SLOTKeyframeGroup?
    var gradient: SLOTKeyframeGroup?
    var opacity: SLOTKeyframeGroup?
    var evenOddFillRule: Bool = false
    var type = LOTGradientType.LOTGradientTypeLinear
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let value = json["t"] as? Int,
            let gradientType = LOTGradientType(rawValue: value) {
            type = gradientType
        }
        
        if let data = json["s"] as? [String: Any] {
            startPoint = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["e"] as? [String: Any] {
            endPoint = SLOTKeyframeGroup(data: data)
        }
        
        if let gradientData = json["g"] as? [String: Any],
            let unwrappedGradientData = gradientData["k"] as? [String: Any] {
            numberOfColors = gradientData["p"] as? Int
            gradient = SLOTKeyframeGroup(data: unwrappedGradientData)
        }
        
        if let data = json["o"] as? [String: Any] {
            opacity = SLOTKeyframeGroup(data: data)
            opacity?.remapKeyframes { inValue in
                return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
            }
        }
        
        if let value = json["r"] as? Int {
            evenOddFillRule = (value == 2)
        }
    }
}
