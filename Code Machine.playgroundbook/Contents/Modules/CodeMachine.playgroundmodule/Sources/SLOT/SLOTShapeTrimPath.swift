//
//  SLOTShapeTrimPath.swift
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


class SLOTShapeTrimPath {

    var keyname: String?
    var start: SLOTKeyframeGroup?
    var end: SLOTKeyframeGroup?
    var offset: SLOTKeyframeGroup?
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let data = json["s"] as? [String: Any] {
            start = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["e"] as? [String: Any] {
            end = SLOTKeyframeGroup(data: data)
        }
        
        if let data = json["o"] as? [String: Any] {
            offset = SLOTKeyframeGroup(data: data)
        }
    }
}
