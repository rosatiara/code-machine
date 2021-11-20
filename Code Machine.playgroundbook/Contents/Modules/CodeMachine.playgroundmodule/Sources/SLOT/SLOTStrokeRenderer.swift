//
//  SLOTStrokeRenderer.swift
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

class SLOTStrokeRenderer : SLOTRenderNode {
    
    private var colorInterpolator: SLOTColorInterpolator?
    private var opacityInterpolator: SLOTNumberInterpolator?
    private var widthInterpolator: SLOTNumberInterpolator?
//    private var dashOffsetInterpolator: SLOTNumberInterpolator?
//    private var dashPatternInterpolators: [SLOTNumberInterpolator]?
    
    init(inputNode: SLOTAnimatorNode?, shapeStroke stroke: SLOTShapeStroke) {
        super.init(inputNode: inputNode, keyname: stroke.keyname)
        
        if let keyframes = stroke.color?.keyframes {
            colorInterpolator = SLOTColorInterpolator(keyframes: keyframes)
        }
        if let keyframes = stroke.opacity?.keyframes {
            opacityInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        if let keyframes = stroke.width?.keyframes {
            widthInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        
        outputLayer.fillColor = nil
        outputLayer.lineCap = stroke.capType == .LOTLineCapTypeRound ? .round : .butt
        switch stroke.joinType {
        case .LOTLineJoinTypeBevel:
            outputLayer.lineJoin = .bevel
        case .LOTLineJoinTypeMiter:
            outputLayer.lineJoin = .miter
        case .LOTLineJoinTypeRound:
            outputLayer.lineJoin = .round
        }
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
            if let interpolator = widthInterpolator {
                interpolators["Stroke Width"] = interpolator
            }
            return interpolators.isEmpty ? nil : interpolators
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    func updateLineDashPatterns(frame: Double) {
        
    }
    
    override var actionsForRenderLayer: [String: CAAction] {
        return [
            "strokeColor": NSNull(),
            "lineWidth": NSNull(),
            "opacity": NSNull()
        ]
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        updateLineDashPatterns(frame: frame)
        return (colorInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (opacityInterpolator?.hasUpdate(frame: frame) ?? false) ||
            (widthInterpolator?.hasUpdate(frame: frame) ?? false)
    }
    
    override func performLocalUpdate() {
        guard let frame = currentFrame else { return }
        
        if let interpolator = colorInterpolator {
            outputLayer.strokeColor = interpolator.colorFor(frame: frame).cgColor
        }
        if let interpolator = widthInterpolator {
            outputLayer.lineWidth = interpolator.floatValue(frame: frame)
        }
        if let interpolator = widthInterpolator {
            outputLayer.opacity = Float(interpolator.floatValue(frame: frame))
        }
    }
    
    override func rebuildOutputs() {
        if let inputNode = inputNode {
            outputLayer.path = inputNode.outputPath.CGPath
        }
    }
    
}
