//
//  SLOTFillRenderer.swift
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

import UIKit

class SLOTFillRenderer : SLOTRenderNode {
    
    private var colorInterpolator: SLOTColorInterpolator?
    private var opacityInterpolator: SLOTNumberInterpolator?
    private var evenOddFillRule = false
    private var centerPoint_DEBUG = CALayer()

    init(inputNode: SLOTAnimatorNode?, shapeFill fill: SLOTShapeFill) {
        super.init(inputNode: inputNode, keyname: fill.keyname)
        
        if let keyframes = fill.color?.keyframes {
            colorInterpolator = SLOTColorInterpolator(keyframes: keyframes)
        }
        
        if let keyframes = fill.opacity?.keyframes {
            opacityInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        
        centerPoint_DEBUG.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
        #if ENABLE_DEBUG_SHAPES
            outputLayer.addSublayer(centerPoint_DEBUG)
        #endif
        evenOddFillRule = fill.evenOddFillRule
        outputLayer.fillRule = evenOddFillRule ? .evenOdd : .nonZero
    }
    
    override var valueInterpolators: [String : Any]? {
        get {
            var interpolators = [String : Any]()
            if let interpolator = colorInterpolator {
                interpolators["Color"] = interpolator
            }
            if let interpolator = opacityInterpolator {
                interpolators["Opacity"] = interpolator
            }
            return interpolators.isEmpty ? nil : interpolators
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    override var actionsForRenderLayer: [String: CAAction] {
        return [
            "backgroundColor": NSNull(),
            "fillColor": NSNull(),
            "opacity": NSNull()
        ]
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return (colorInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (opacityInterpolator?.hasUpdate(frame: frame) ?? false)
    }
    
    override func performLocalUpdate() {
        centerPoint_DEBUG.borderColor = UIColor.lightGray.cgColor
        centerPoint_DEBUG.borderWidth = 2.0
        guard let frame = currentFrame else { return }
        if let interpolator = colorInterpolator {
            centerPoint_DEBUG.backgroundColor = interpolator.colorFor(frame: frame).cgColor
            outputLayer.fillColor = interpolator.colorFor(frame: frame).cgColor
        }
        if let interpolator = opacityInterpolator {
            outputLayer.opacity = Float(interpolator.floatValue(frame: frame))
        }
    }
    
    override func rebuildOutputs() {
        if let inputNode = inputNode {
            outputLayer.path = inputNode.outputPath.CGPath
        }
    }
}
