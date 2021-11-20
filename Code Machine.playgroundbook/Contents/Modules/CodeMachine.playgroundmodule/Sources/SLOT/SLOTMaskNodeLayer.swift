//
//  SLOTMaskNodeLayer.swift
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
import UIKit
import CoreGraphics

class SLOTMaskNodeLayer : CAShapeLayer {
    public var maskNode : SLOTMask
    private var pathInterpolator : SLOTPathInterpolator?
    private var opacityInterpolator : SLOTNumberInterpolator?
    private var expansionInterpolator : SLOTNumberInterpolator?
    private var containerBounds = CGRect.zero
    
    public init(mask: SLOTMask, containerBounds: CGRect) {
        self.maskNode = mask
        self.containerBounds = containerBounds
        super.init()
        if let keyframes = mask.maskPath?.keyframes {
            pathInterpolator = SLOTPathInterpolator(keyframes: keyframes)
        }
        if let keyframes = mask.opacity?.keyframes {
            opacityInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        if let keyframes = mask.expansion?.keyframes {
            expansionInterpolator = SLOTNumberInterpolator(keyframes: keyframes)
        }
        self.fillColor = UIColor.blue.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func update(frame: Double, with viewBounds: CGRect) {
        if hasUpdate(frame: frame) {
            if let pI = pathInterpolator {
                let path = pI.path(frame: frame, cacheLengths: false)
                if maskNode.maskMode == .LOTMaskModeSubtract || maskNode.inverted {
                    let pathRef = CGMutablePath()
                    // Use stored container bounds because viewBounds is empty.
                    // It seems like these mask layers are not sized.
                    pathRef.addRect(containerBounds)
                    pathRef.addPath(path.CGPath)
                    self.path = pathRef
                    fillRule = .evenOdd
                }
                else {
                    self.path = path.CGPath
                }
            }
            if let oI = opacityInterpolator {
                self.opacity = Float(oI.floatValue(frame: frame))
            }
        }
    }
    
    private func hasUpdate(frame : Double) -> Bool {
        return (pathInterpolator?.hasUpdate(frame: frame) ?? false) ||
        (opacityInterpolator?.hasUpdate(frame: frame) ?? false)
    }
}
