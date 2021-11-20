//
//  SLOTCompositionContainer.swift
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
import QuartzCore

class SLOTCompositionContainer : SLOTLayerContainer {
    private var frameOffset : Double = 0
    lazy var childLayers = Array<SLOTLayerContainer>()
    lazy var childMap = Dictionary<String,SLOTLayerContainer>()
    
    init(model: SLOTLayer?, inLayerGroup layerGroup: SLOTLayerGroup?, withLayerGroup childLayerGroup: SLOTLayerGroup?, withAssetGroup assetGroup: SLOTAssetGroup?) {
        super.init(model: model, inLayerGroup: layerGroup)
        
        // Ignoring debug stuff for now
        
        if let m = model {
            frameOffset = m.startFrame
        }
        
        if let cg = childLayerGroup, let ag = assetGroup {
            initialize(childGroup: cg, assetGroup: ag)
        }
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize(childGroup: SLOTLayerGroup, assetGroup: SLOTAssetGroup) {
        var maskedLayer : CALayer?
        //print("layer: \(layerName ?? "")")
        for layer in childGroup.layers.reversed() {
            let asset = assetGroup.assetMap[layer.referenceID]
            let child : SLOTLayerContainer
            if asset?.layerGroup != nil {
                child = SLOTCompositionContainer.init(model: layer, inLayerGroup: childGroup, withLayerGroup: asset?.layerGroup, withAssetGroup: assetGroup)
            }
            else {
                child = SLOTLayerContainer.init(model: layer, inLayerGroup: childGroup)
            }
            
            if maskedLayer != nil {
                maskedLayer?.mask = child
                maskedLayer = nil
            }
            else {
                if layer.matteType == .SLOTMatteTypeAdd {
                    maskedLayer = child
                }
                wrapperLayer.addSublayer(child)
            }
            childLayers.append(child)
            if let ln = child.layerName {
                childMap[ln] = child
            }
        }
    }
    
    override func display(frame: Double, forceUpdate: Bool) {
        super.display(frame: frame, forceUpdate: forceUpdate)
        let childFrame = frame - frameOffset
        for child in childLayers {
            child.display(frame: childFrame, forceUpdate: forceUpdate)
        }
    }

    func layerWith(name layerName: String) -> SLOTLayerContainer? {
        return childMap[layerName]
    }
    
    func layerWith(keyPath: String) -> SLOTLayerContainer? {
        let pathSeparator = "."
        let keys = keyPath.split(separator: Character(pathSeparator)).map { String($0) }
        guard !keys.isEmpty, let firstKey = keys.first else { return nil }
        guard childMap[firstKey] != nil else { return nil }
        
        if keys.count == 1 {
            return childMap[firstKey]
        } else {
            guard let compositionContainer = childMap[firstKey] as? SLOTCompositionContainer else { return nil }
            var remainingKeys = keys
            remainingKeys.removeFirst()
            return compositionContainer.layerWith(keyPath: remainingKeys.joined(separator: pathSeparator))
        }
    }
    
    func sublayersOfLayerWith(keyPath: String) -> [SLOTLayerContainer]? {
        guard let compositionContainer = layerWith(keyPath: keyPath) as? SLOTCompositionContainer else { return nil }
        return compositionContainer.childLayers
    }
    
    override func logHierarchyKeypaths(withParent parent: String?) {
        var keypath = parent
        if let parent = parent, let layerName = layerName {
            keypath = "\(parent).\(layerName)"
        }
        for layer in childLayers {
            layer.logHierarchyKeypaths(withParent: keypath)
        }
    }
    

}


