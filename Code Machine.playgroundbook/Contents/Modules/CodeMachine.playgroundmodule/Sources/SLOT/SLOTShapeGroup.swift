//
//  SLOTShapeGroup.swift
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

class SLOTShapeGroup {
    // returning Any here suuuuucks
    class func shapeItem(json: [String: Any]) -> Any? {
        
        guard let type = json["ty"] as? String else { return nil }
        
        switch type {
        case "gr":
            return SLOTShapeGroup(json: json)
        case "st":
            return SLOTShapeStroke(json: json)
        case "fl":
            return SLOTShapeFill(json: json)
        case "tr":
            return SLOTShapeTransform(json: json)
        case "sh":
            return SLOTShapePath(json: json)
        case "el":
            return SLOTShapeCircle(json: json)
        case "rc":
            return SLOTShapeRectangle(json: json)
        case "tm":
            return SLOTShapeTrimPath(json: json)
        case "gs":
            //NSLog("SLOTShapeGroup: gradient strokes are not supported.")
            return nil
        case "gf":
                return SLOTShapeGradientFill(json: json)
        case "sr":
            //NSLog("SLOTShapeGroup: star shape is not supported.")
            return nil
        case "mm":
            //NSLog("SLOTShapeGroup: merge shape is not supported.")
            return nil
        case "rp":
            return SLOTShapeRepeater(json: json)
        default:
            //NSLog("SLOTShapeGroup: shape type %@ is not supported.", type)
            return nil
        }
    }
    
    var keyname: String?
    var items: [Any]?

    init(json: [String: Any]) {
        if let value = json["nm"] as? String { keyname = value }
        
        if let itemsData = json["it"] as? [[String:Any]] {
            items = itemsData.compactMap { SLOTShapeGroup.shapeItem(json: $0) }
        }
    }
}
