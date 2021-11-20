//
//  SLOTTransformInterpolator.swift
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

import QuartzCore

class SLOTTransformInterpolator {
    
    var inputNode: SLOTTransformInterpolator?
    
    var positionInterpolator: SLOTPointInterpolator?
    var anchorInterpolator: SLOTPointInterpolator
    var scaleInterpolator: SLOTSizeInterpolator
    var rotationInterpolator: SLOTNumberInterpolator
    var positionXInterpolator: SLOTNumberInterpolator?
    var positionYInterpolator: SLOTNumberInterpolator?
    
    convenience init(position: [SLOTKeyframe], rotation: [SLOTKeyframe], anchor: [SLOTKeyframe], scale: [SLOTKeyframe]) {
        self.init(positionX: nil, positionY: nil, position: position, rotation: rotation, anchor: anchor, scale: scale)
    }
    
    convenience init(positionX: [SLOTKeyframe], positionY: [SLOTKeyframe], rotation: [SLOTKeyframe], anchor: [SLOTKeyframe], scale: [SLOTKeyframe]) {
        self.init(positionX: positionX, positionY: positionY, position: nil, rotation: rotation, anchor: anchor, scale: scale)
    }
    
    private init(positionX: [SLOTKeyframe]?, positionY: [SLOTKeyframe]?, position: [SLOTKeyframe]?, rotation: [SLOTKeyframe], anchor: [SLOTKeyframe], scale: [SLOTKeyframe]) {
        if let position = position {
            positionInterpolator = SLOTPointInterpolator(keyframes: position)
        } else if let positionY = positionY {
            positionYInterpolator = SLOTNumberInterpolator(keyframes: positionY)
        } else if let positionX = positionX {
            positionXInterpolator = SLOTNumberInterpolator(keyframes: positionX)
        }
        
        anchorInterpolator = SLOTPointInterpolator(keyframes: anchor)
        scaleInterpolator = SLOTSizeInterpolator(keyframes: scale)
        rotationInterpolator = SLOTNumberInterpolator(keyframes: rotation)
    }
    
    class func transform(for layer: SLOTLayer) -> SLOTTransformInterpolator {
        if let layerPosition = layer.position {
            return SLOTTransformInterpolator(position: layerPosition.keyframes, rotation: layer.rotation!.keyframes, anchor: layer.anchor!.keyframes, scale: layer.scale!.keyframes)
        }
        
        return SLOTTransformInterpolator(positionX: layer.positionX!.keyframes, positionY: layer.positionY!.keyframes, rotation: layer.rotation!.keyframes, anchor: layer.anchor!.keyframes, scale: layer.scale!.keyframes)
    }
    
    func transform(frame:Double) -> CATransform3D {
        var baseXform = CATransform3DIdentity
        if let inputNode = inputNode {
            baseXform = inputNode.transform(frame: frame)
        }
        var position = CGPoint.zero
        if let positionInterpolator = positionInterpolator {
            position = positionInterpolator.pointValue(frame: frame)
        }
        
        if let positionXInterpolator = positionXInterpolator, let positionYInterpolator = positionYInterpolator {
            position.x = positionXInterpolator.floatValue(frame: frame)
            position.y = positionYInterpolator.floatValue(frame: frame)
        }
        
        let anchor = anchorInterpolator.pointValue(frame: frame)
        let scale = scaleInterpolator.sizeValue(frame: frame)
        let rotation = rotationInterpolator.floatValue(frame: frame)
        let translateXform = CATransform3DTranslate(baseXform, position.x, position.y, 0)
        let rotateXForm = CATransform3DRotate(translateXform, rotation, 0, 0, 1)
        let scaleXForm = CATransform3DScale(rotateXForm, scale.width, scale.height, 1)
        let anchorXForm = CATransform3DTranslate(scaleXForm, -1 * anchor.x, -1 * anchor.y, 0)
        
        return anchorXForm
    }
    
    func hasUpdate(frame:Double) -> Bool {
        let inputUpdate = self.inputNode?.hasUpdate(frame: frame) ?? false
        if inputUpdate {
            return inputUpdate
        }
        
        if let positionInterpolator = positionInterpolator {
            return (positionInterpolator.hasUpdate(frame:frame) ||
            anchorInterpolator.hasUpdate(frame:frame) ||
            scaleInterpolator.hasUpdate(frame:frame) ||
            rotationInterpolator.hasUpdate(frame:frame))
        }
        
        return (positionXInterpolator!.hasUpdate(frame:frame) ||
            positionYInterpolator!.hasUpdate(frame:frame) ||
            anchorInterpolator.hasUpdate(frame:frame) ||
            scaleInterpolator.hasUpdate(frame:frame) ||
            rotationInterpolator.hasUpdate(frame:frame))
    }
    
}
