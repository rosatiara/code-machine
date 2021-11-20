//
//  SLOTLayerGroup.swift
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

class SLOTLayerGroup {
    var layers = Array<SLOTLayer>()
    var modelMap = Dictionary<Int,SLOTLayer>()
    var referenceMap = Dictionary<String, SLOTLayer>()
    
    init(json: Array<Dictionary<String,Any>>, assetGroup: SLOTAssetGroup?) {
        for layerJSON in json {
            let layer = SLOTLayer.init(json: layerJSON, assetGroup: assetGroup)
            layers.append(layer)
            modelMap[layer.layerID] = layer
            referenceMap[layer.referenceID] = layer
        }
    }
    
    func layerModel(id: Int) -> SLOTLayer? {
        return modelMap[id]
    }
    
    func layer(referenceID: String) -> SLOTLayer? {
        return referenceMap[referenceID]
    }
}
