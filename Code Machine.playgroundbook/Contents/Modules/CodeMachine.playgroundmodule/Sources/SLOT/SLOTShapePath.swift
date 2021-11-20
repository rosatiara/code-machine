//
//  SLOTShapePath.swift
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


class SLOTShapePath {

    var keyname: String?
    var closed: Bool = false
    var index: Int?
    var shapePath: SLOTKeyframeGroup?
    
    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        index = json["ind"] as? Int
        
        closed = json["closed"] as? Bool ?? false
        
        if let data = json["ks"] as? [String: Any] {
            shapePath = SLOTKeyframeGroup(data: data)
        }
    }
}
