//
//  SLOTAsset.swift
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

class SLOTAsset {
    var referenceID : String = ""
    var width : Int?
    var height : Int?
    var imageName : String?
    var imageDirectory : String?
    var layerGroup : SLOTLayerGroup?
    var rootDirectory : URL?
    
    init(json: Dictionary<String,Any>, assetGroup:SLOTAssetGroup) {
        if let tmp = json["id"] as? String { referenceID = tmp }
        if let tmp = json["w"] as? Int { width = tmp }
        if let tmp = json["h"] as? Int { height = tmp }
        if let tmp = json["u"] as? String { imageDirectory = tmp }
        if let tmp = json["p"] as? String { imageName = tmp }
        if let tmp = json["layers"] {
            layerGroup = SLOTLayerGroup.init(json: tmp as! Array<Dictionary<String,Any>>, assetGroup: assetGroup)
        }
    }
}


