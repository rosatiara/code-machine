//
//  SLOTRenderGroup.swift
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

class SLOTRenderGroup: SLOTRenderNode {
    
    private(set) var containerLayer: CALayer = CALayer()
    private var rootNode: SLOTAnimatorNode?
	private var privateOutputPath: SLOTBezierPath?
	private var privateLocalPath: SLOTBezierPath?
    private var rootNodeHasUpdate: Bool = false
    private var opacityInterpolator: SLOTNumberInterpolator?
    private var transformInterpolator: SLOTTransformInterpolator?
    
    override var valueInterpolators: [String : Any]? {
        get {
            if let opInt = opacityInterpolator, let transInt = transformInterpolator {
                return [
                    "Transform.Opacity" : opInt,
                    "Transform.Position" : transInt.positionInterpolator!,
                    "Transform.Scale" : transInt.scaleInterpolator,
                    "Transform.Rotation" : transInt.scaleInterpolator,
                    "Transform.Anchor Point" : transInt.anchorInterpolator
                ]
            }
            return nil
        } set {
            
        }
    }
    
    init(inputNode: SLOTAnimatorNode?, contents: [Any], keyname: String?) {
        super.init(inputNode: inputNode, keyname: keyname)
        containerLayer.actions = ["transform": NSNull(), "opacity": NSNull()]
        build(contents: contents)
    }
    
    func build(contents: [Any]) {
        var previousNode: SLOTAnimatorNode?
        var transform: SLOTShapeTransform?
 
        for item in contents {
            
            switch item {
            case let shapeFill as SLOTShapeFill:
                let fillRenderer = SLOTFillRenderer(inputNode: previousNode, shapeFill: shapeFill)
                containerLayer.insertSublayer(fillRenderer.outputLayer, at: 0)
                previousNode = fillRenderer
            case let shapeStroke as SLOTShapeStroke:
                let strokeRenderer = SLOTStrokeRenderer(inputNode: previousNode, shapeStroke: shapeStroke)
                containerLayer.insertSublayer(strokeRenderer.outputLayer, at: 0)
                previousNode = strokeRenderer
            case let shapePath as SLOTShapePath:
                let pathAnimator = SLOTPathAnimator(inputNode: previousNode, shapePath: shapePath)
                previousNode = pathAnimator
            case let shapeRectangle as SLOTShapeRectangle:
                let rectAnimator = SLOTRoundedRectAnimator(inputNode: previousNode, shapeRectangle: shapeRectangle)
                previousNode = rectAnimator
            case let shapeCircle as SLOTShapeCircle:
                let circleAnimator = SLOTCircleAnimator(inputNode: previousNode, shapeCircle: shapeCircle)
                previousNode = circleAnimator
            case let shapeGroup as SLOTShapeGroup:
                if let items = shapeGroup.items {
                    let renderGroup = SLOTRenderGroup(inputNode: previousNode, contents: items, keyname: shapeGroup.keyname)
                    containerLayer.insertSublayer(renderGroup.containerLayer, at: 0)
                    previousNode = renderGroup
                }
            case let shapeTransform as SLOTShapeTransform:
                transform = shapeTransform
//            case let shapeTrimPath as SLOTShapeTrimPath:
//                // Not implemented
//                break
//            case let shapeStar as SLOTShapeStar:
//                // Not implemented
//                break
            case let shapeGradientFill as SLOTShapeGradientFill:
                let gradientFill = SLOTGradientFillRender(inputNode: previousNode, shapeGradientFill: shapeGradientFill)
                previousNode = gradientFill
                containerLayer.insertSublayer(gradientFill.outputLayer, at: 0)
//            case let shapeRepeater as SLOTShapeRepeater:
//                // Not implemented
//                break
            default:
                NSLog("Unrecognized item in SLOTRenderGroup")
                break
            }
            
        }
        
        if let transform = transform {
            if let opacity = transform.opacity {
                opacityInterpolator = SLOTNumberInterpolator(keyframes: opacity.keyframes)
            }
            if let position = transform.position,
                let rotation = transform.rotation,
                let anchor = transform.anchor,
                let scale = transform.scale {
                transformInterpolator = SLOTTransformInterpolator(position: position.keyframes,
                                                                  rotation: rotation.keyframes,
                                                                  anchor: anchor.keyframes,
                                                                  scale: scale.keyframes)
            }
        }
        
        rootNode = previousNode
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return (opacityInterpolator?.hasUpdate(frame: frame) ?? false) ||
        (transformInterpolator?.hasUpdate(frame: frame) ?? false) ||
        rootNodeHasUpdate
    }
    
    override func update(frame: Double, modifier: ((SLOTAnimatorNode) -> Void)?, forceLocalUpdate: Bool) -> Bool {
        indentationLevel += 1
        rootNodeHasUpdate = rootNode?.update(frame: frame, modifier: modifier, forceLocalUpdate: forceLocalUpdate) ?? false
        indentationLevel -= 1
        return super.update(frame: frame, modifier: modifier, forceLocalUpdate: forceLocalUpdate)
    }
    
    override func performLocalUpdate() {
        if let opacityInterpolator = opacityInterpolator, let frame = currentFrame {
            containerLayer.opacity = Float(opacityInterpolator.floatValue(frame: frame))
        }
        
        if let transformInterpolator = transformInterpolator, let frame = currentFrame {
            let xform = transformInterpolator.transform(frame: frame)
            containerLayer.transform = xform
            let appliedXform = CATransform3DGetAffineTransform(xform)
            privateLocalPath = rootNode?.outputPath.copy()
            privateLocalPath?.SLOT_apply(transform: appliedXform)
            
        } else {
            privateLocalPath = rootNode?.outputPath.copy()
        }
    }
    
    override func rebuildOutputs() {
        if let inputNode = inputNode {
            privateOutputPath = inputNode.outputPath.copy()
            privateOutputPath?.SLOT_append(bezierPath: localPath)
        } else {
            privateOutputPath = localPath
        }
    }
    
    override func setPathShouldCacheLengths(_ pathShouldCacheLengths: Bool) {
        super.pathShouldCacheLengths = pathShouldCacheLengths
        rootNode?.pathShouldCacheLengths = pathShouldCacheLengths
    }
    
    override var localPath: SLOTBezierPath {
        get {
            return privateLocalPath ?? super.localPath
        }
        set {
            super.localPath = newValue
        }
    }
    
    override var outputPath: SLOTBezierPath {
        get {
            return privateOutputPath ?? super.outputPath
        }
        set {
            super.outputPath = newValue
        }
    }
    
    override func setInterpolatorValue(_ value: Any, forKey key: String, forFrame frame: Double) -> Bool {
        
        if super.setInterpolatorValue(value, forKey: key, forFrame: frame) {
            return true
        }
        return rootNode?.set(value: value, forKeyPath: NSString(string: key), forFrame: frame) ?? false
    }
    
    override func logHierarchyKeypaths(withParent parent: String?) {
        var keypath = keyname
        if let parent = parent, let keyname = keyname {
            keypath = "\(parent).\(keyname)"
        }
        if let keypath = keypath, let interpolatorKeys = valueInterpolators?.keys {
            for interpolator in interpolatorKeys {
                log(string: "\(keypath).\(interpolator)")
            }
            rootNode?.logHierarchyKeypaths(withParent: keypath)
        }
    }
    
}
