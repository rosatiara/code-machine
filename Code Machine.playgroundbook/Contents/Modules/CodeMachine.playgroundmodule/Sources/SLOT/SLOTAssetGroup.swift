//
//  SLOTAssetGroup.swift
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

class SLOTAssetGroup {
    var assetMap = Dictionary<String, SLOTAsset>()
    var assetJSONMap = Dictionary<String, Dictionary<String, Any>>()
    var rootDirectory : URL? {
        didSet {
            for asset in assetMap.values {
                asset.rootDirectory = rootDirectory
            }
        }
    }
    
    init(json: Array<Dictionary<String,Any>>) {
        for assetDictionary in json {
            if let referenceID = assetDictionary["id"] as? String {
                assetJSONMap[referenceID] = assetDictionary
            }
        }
    }
    
    func finalizeInitialization() {
        for refID in assetMap.keys {
            buildAsset(named: refID)
        }
        assetJSONMap.removeAll()
    }
    
    func buildAsset(named refID: String) {
        guard assetMap[refID] == nil else {
            return
        }
        
        if let assetDict = assetJSONMap[refID] {
            let asset = SLOTAsset.init(json: assetDict, assetGroup: self)
            assetMap[refID] = asset
        }
    }
}
