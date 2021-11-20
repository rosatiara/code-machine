//
//  SLOTShapeRectangle.swift
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


class SLOTShapeRectangle {

    var keyname: String?
    var position: SLOTKeyframeGroup?
    var size: SLOTKeyframeGroup?
    var cornerRadius: SLOTKeyframeGroup?
    var reversed: Bool = false
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let data = json["p"] as? [String: Any] {
            position = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["r"] as? [String: Any] {
            cornerRadius = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["s"] as? [String: Any] {
            size = SLOTKeyframeGroup(data: data)
        }
        
        if let value = json["d"] as? Int {
            reversed = (value == 3)
        }
    }
}
