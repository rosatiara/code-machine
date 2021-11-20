//
//  SLOTGradientFillRender.swift
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

class SLOTGradientFillRender: SLOTRenderNode {
    
    private var gradientInterpolator: SLOTArrayInterpolator?
    private var startPointInterpolator: SLOTPointInterpolator?
    private var endPointInterpolator: SLOTPointInterpolator?
    private var opacityInterpolator: SLOTNumberInterpolator?
    
    private var gradientOpacityLayer: SLOTRadialGradientLayer?
    private var gradientLayer = SLOTRadialGradientLayer()
    private var numberOfPositions: Int!
    
    private var maskShape = CAShapeLayer()
    
    private var startPoint: CGPoint!
    private var endPoint: CGPoint!
    
    private let nullActions = [
        "startPoint" : NSNull(),
        "endPoint" : NSNull(),
        "opacity" : NSNull(),
        "locations" : NSNull(),
        "colors" : NSNull(),
        "bounds" : NSNull(),
        "anchorPoint" : NSNull(),
        "isRadial" : NSNull()
    ]
    
    init(inputNode: SLOTAnimatorNode?, shapeGradientFill fill: SLOTShapeGradientFill) {
        super.init(inputNode: inputNode, keyname: fill.keyname)
        
        if let gradient = fill.gradient {
            gradientInterpolator = SLOTArrayInterpolator(keyframes: gradient.keyframes)
        }
        
        if let start = fill.startPoint {
            startPointInterpolator = SLOTPointInterpolator(keyframes: start.keyframes)
        }
        
        if let end = fill.endPoint {
            endPointInterpolator = SLOTPointInterpolator(keyframes: end.keyframes)
        }
        
        if let opacity = fill.opacity {
            opacityInterpolator = SLOTNumberInterpolator(keyframes: opacity.keyframes)
        }
        numberOfPositions = fill.numberOfColors ?? 0
        
        maskShape.fillRule = fill.evenOddFillRule ? .evenOdd : .nonZero
        maskShape.fillColor = UIColor.white.cgColor
        maskShape.actions = ["path" : NSNull()]

        gradientLayer.isRadial = (fill.type == .LOTGradientTypeRadial)
        gradientLayer.mask = maskShape
        gradientLayer.actions = nullActions
        outputLayer.addSublayer(gradientLayer)
    }
    
    override var valueInterpolators: [String : Any]? {
        get {
            return [
                "Start Point" : startPointInterpolator as Any,
                "End Point" : endPointInterpolator as Any,
                "Opacity" : opacityInterpolator as Any
            ]
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return (gradientInterpolator?.hasUpdate(frame: frame) ?? false) ||
        (startPointInterpolator?.hasUpdate(frame: frame) ?? false) ||
        (endPointInterpolator?.hasUpdate(frame: frame) ?? false) ||
        (opacityInterpolator?.hasUpdate(frame: frame) ?? false)
    }
    
    override func performLocalUpdate() {
        guard let currentFrame = currentFrame else { return }
        
        startPoint = startPointInterpolator?.pointValue(frame: currentFrame)
        endPoint = endPointInterpolator?.pointValue(frame: currentFrame)
        let newOpacity = opacityInterpolator?.floatValue(frame: currentFrame) ?? 1.0
        outputLayer.opacity = Float(newOpacity)
        let numberArray = gradientInterpolator?.numberArray(frame: currentFrame) ?? []
        var colorArray = [CGColor]()
        var locationsArray = [CGFloat]()
        var opacityArray = [CGColor]()
        var opacityLocationsArray = [CGFloat]()
        
        for i in 0..<numberOfPositions {
            let ix = i * 4
            let location = numberArray[ix]
            let r = numberArray[ix+1]
            let g = numberArray[ix+2]
            let b = numberArray[ix+3]
            locationsArray.append(location)
            let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            colorArray.append(color.cgColor)
        }
        
        let sequence = stride(from: numberOfPositions*4, to: numberArray.count, by: 2)
        for i in sequence {
            let opacityLocation = numberArray[i]
            opacityLocationsArray.append(opacityLocation)
            let opacity = numberArray[i+1]
            let opacityColor = UIColor(white: 1.0, alpha: opacity)
            opacityArray.append(opacityColor.cgColor)
        }
        
        if opacityArray.isEmpty {
            if let gradientOpacityLayer = gradientOpacityLayer {
                gradientOpacityLayer.backgroundColor = UIColor.white.cgColor
            }
        } else {
            // Create a gradient layer for opacity on demand.
            if gradientOpacityLayer == nil {
                let opacityLayer = SLOTRadialGradientLayer()
                let wrapperLayer = CALayer()
                opacityLayer.isRadial = gradientLayer.isRadial
                opacityLayer.actions = nullActions
                opacityLayer.mask = maskShape
                wrapperLayer.addSublayer(opacityLayer)
                gradientLayer.mask = wrapperLayer
                gradientOpacityLayer = opacityLayer
            }
            if let gradientOpacityLayer = gradientOpacityLayer {
                gradientOpacityLayer.startPoint = startPoint
                gradientOpacityLayer.endPoint = endPoint
                gradientOpacityLayer.locations = opacityLocationsArray
                gradientOpacityLayer.colors = opacityArray
            }
        }
        
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = locationsArray
        gradientLayer.colors = colorArray
    }
    
    override func rebuildOutputs() {
        let frame = inputNode?.outputPath.bounds ?? .zero
        let modifiedAnchor = CGPoint(x: -frame.origin.x / frame.size.width, y: -frame.origin.y / frame.size.height)
        maskShape.path = inputNode?.outputPath.CGPath
        if let gradientOpacityLayer = gradientOpacityLayer {
            gradientOpacityLayer.bounds = frame
            gradientOpacityLayer.anchorPoint = modifiedAnchor
        }
        
        gradientLayer.bounds = frame
        gradientLayer.anchorPoint = modifiedAnchor
    }
    
    override var actionsForRenderLayer: [String : CAAction] {
        return [
            "backgroundColor": NSNull(),
            "fillColor": NSNull(),
            "opacity": NSNull()
        ]
    }
}
