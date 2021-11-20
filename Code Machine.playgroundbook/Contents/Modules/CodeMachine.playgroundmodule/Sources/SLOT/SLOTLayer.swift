//
//  SLOTLayer.swift
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
import UIKit

enum SLOTLayerType : Int {
    case SLOTLayerTypePrecomp
    case SLOTLayerTypeSolid
    case SLOTLayerTypeImage
    case SLOTLayerTypeNull
    case SLOTLayerTypeShape
    case SLOTLayerTypeUnknown
}

enum SLOTMatteType : Int {
    case SLOTMatteTypeNone
    case SLOTMatteTypeAdd
    case SLOTMatteTypeInvert
    case SLOTMatteTypeUnknown
}

class SLOTLayer {
    var layerName : String?
    var layerID : Int = 0
    var layerType : SLOTLayerType = .SLOTLayerTypeUnknown
    var referenceID : String = ""
    var parentID : Int?
    var startFrame : Double = 0
    var inFrame : Double = 0
    var outFrame : Double = 0
    var width : Int?
    var height : Int?
    var imageAsset : SLOTAsset?
    var solidColor : UIColor?
    var layerBounds : CGRect = .zero
    var matteType : SLOTMatteType = .SLOTMatteTypeNone
    var shapes : Array<Any>?
    var masks : Array<SLOTMask>?
    
    var opacity : SLOTKeyframeGroup?
    var rotation : SLOTKeyframeGroup?
    var position : SLOTKeyframeGroup?
    var positionX : SLOTKeyframeGroup?
    var positionY : SLOTKeyframeGroup?
    var anchor : SLOTKeyframeGroup?
    var scale : SLOTKeyframeGroup?

    
    init(json: Dictionary<String,Any>, assetGroup: SLOTAssetGroup?) {
        if let tmp = json["nm"] as? String { layerName = tmp }
        if let tmp = json["ind"] as? Int { layerID = tmp }
        if let tmp = json["ty"] as? Int { layerType = SLOTLayerType(rawValue: tmp)! }
        if let tmp = json["parent"] as? Int { parentID = tmp }
        if let tmp = json["refId"] as? String { referenceID = tmp }
        
        if let tmp = json["st"] as? Double { startFrame = tmp }
        if let tmp = json["ip"] as? Double { inFrame = tmp }
        if let tmp = json["op"] as? Double { outFrame = tmp }
        
        switch layerType {
        case .SLOTLayerTypePrecomp:
            if let tmp = json["h"] as? String { height = Int(tmp) }
            else if let tmp = json["h"] as? Int { height = tmp }
            if let tmp = json["w"] as? String { width = Int(tmp) }
            else if let tmp = json["w"] as? Int { width = tmp }
            assetGroup?.buildAsset(named: referenceID)
        case .SLOTLayerTypeImage:
            assetGroup?.buildAsset(named: referenceID)
            imageAsset = assetGroup?.assetMap[referenceID]
            width = imageAsset?.width
            height = imageAsset?.height
        case .SLOTLayerTypeSolid:
            if let tmp = json["sh"] as? String { height = Int(tmp) }
            if let tmp = json["sw"] as? String { width = Int(tmp) }
            if let tmp = json["sc"] {
                fatalError("Need to implement LOT_colorWithHexString for SLOTLayer/TypeSolid color \(tmp)")
            }
        default:
            break
        }
        
        if let w = width, let h = height {
            layerBounds.size = CGSize(width: w, height: h)
        }
        
        if let ks = json["ks"] as? Dictionary<String,Any> {
            if let _opacity = ks["o"] {
                opacity = SLOTKeyframeGroup.init(data: _opacity)
                opacity?.remapKeyframes { (inValue) in 
                    return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
                }
            }

            var _rotation = ks["r"]
            if _rotation == nil {
                _rotation = ks["rz"]
            }
            if let r = _rotation {
                rotation = SLOTKeyframeGroup.init(data: r)
                rotation?.remapKeyframes { (inValue) in 
                    return SLOT_DegreesToRadians(inValue)
                }
            }
            
            if let pos = ks["p"] as? Dictionary<String,Any> {
                if let _ = pos["s"] as? Bool, let x = pos["x"], let y = pos["y"] {
                    positionX = SLOTKeyframeGroup.init(data: x)
                    positionY = SLOTKeyframeGroup.init(data: y)
                } else {
                    position = SLOTKeyframeGroup.init(data: pos)
                }
            }
            
            if let _anchor = ks["a"] as? Dictionary<String,Any> {
                anchor = SLOTKeyframeGroup.init(data: _anchor)
            }
            
            if let _scale = ks["s"] as? Dictionary<String,Any> {
                scale = SLOTKeyframeGroup.init(data: _scale)
                scale?.remapKeyframes { (inValue) in 
                    return SLOT_RemapValue(value: inValue, low1: 0, high1: 100, low2: 0, high2: 1)
                }
            }
        }

        if let tmp = json["tt"] as? Int {
            matteType = SLOTMatteType.init(rawValue: tmp)!
        }
        
        if let maskProps = json["masksProperties"] as? Array<Dictionary<String,Any>> {
            masks = maskProps.map{ (json) -> SLOTMask in
                return SLOTMask.init(json: json)
            }
        }

        if let _shapes = json["shapes"] as? Array<Dictionary<String,Any>> {
            shapes = _shapes.compactMap{ (json) -> Any? in
                SLOTShapeGroup.shapeItem(json: json)
            }
        }
        
        if let effects = json["ef"] as? Array<Dictionary<String,Any>>, effects.count > 0 {
            let effectNames = [
                0: "slider",
                1: "angle",
                2: "color",
                3: "point",
                4: "checkbox",
                5: "group",
                6: "noValue",
                7: "dropDown",
                9: "customValue",
                10: "layerIndex",
                20: "tint",
                21: "fill"
            ]
            
            for effect in effects {
                let typeNumber = effect["ty"] as! Int
                let name = effect["nm"] as! String
                let internalName = effect["mn"] as! String
                if let typeString = effectNames[typeNumber] {
                    print("\(#function): \(typeString) effect not supported: \(internalName) / \(name)")
                }
            }
        }
    }
}
