//
//  SLOTComposition.swift
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

public class SLOTComposition {
    var bounds : CGRect = .zero
    var startFrame : Double?
    var endFrame : Double?
    var frameRate : Double?
    var timeDuration : TimeInterval = 0
    var assetGroup : SLOTAssetGroup?
    var layerGroup : SLOTLayerGroup?
    var rootDirectory : URL? {
        didSet {
            assetGroup?.rootDirectory = rootDirectory
        }
    }
    
    convenience init?(animationName: String) {
        let shortName = animationName.components(separatedBy: ".")[0]

        if let jsonURL = Bundle.main.url(forResource: shortName, withExtension: "json") {
            do {
                let data = try Data.init(contentsOf: jsonURL)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String,Any>
                self.init(json: json)
            }
            catch {
                fatalError("SLOTComposition failed to init: \(error)")
            }
        }
        else {
            return nil
        }
    }
    
    convenience init?(filePath: URL) {
        do {
            let data = try Data.init(contentsOf: filePath)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String,Any>
            self.init(json: json)
            
            // [will|did]Set observers on properties are not called in an initialization context.
            // Wrapping this in a closure works around this by allowing didSet to be invoked.
            ({ self.rootDirectory = filePath.deletingLastPathComponent() })()
        }
        catch {
            fatalError("SLOTComposition failed to init: \(error)")
            return nil
        }
    }
    
    init(json: Dictionary<String,Any>) {
        if let w = json["w"], let h = json["h"] {
            bounds = CGRect(x:0.0, y:0.0, width:w as! Double, height:h as! Double)
        }
        
        startFrame = json["ip"] as? Double
        endFrame = json["op"] as? Double
        frameRate = json["fr"] as? Double
        
        if let sF = startFrame, let eF = endFrame, let fR = frameRate {
            let frameDuration = (eF - sF) - 1
            timeDuration = frameDuration / fR
        }
        
        // Assets
        if let assets = json["assets"] as? Array<Dictionary<String,Any>>, assets.count > 0 {
            assetGroup = SLOTAssetGroup.init(json: assets)
        }
        
        // Layers
        if let layers = json["layers"] {
            layerGroup = SLOTLayerGroup.init(json: layers as! Array<Dictionary<String, Any>>, assetGroup: assetGroup)
        }

        // Finalize assetGroup
        assetGroup?.finalizeInitialization()
    }
}
