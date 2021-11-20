//
//  SLOTMaskContainer.swift
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

class SLOTMaskContainer : CALayer {
    
    var currentFrame : Double? {
        didSet {
            guard currentFrame != oldValue else { return }
            guard let frame = currentFrame, let masks = masks else { return }
            for nodeLayer in masks {
                nodeLayer.update(frame: frame, with: bounds)
            }
        }
    }
    
    private var masks: [SLOTMaskNodeLayer]?
    
    public init(masks: [SLOTMask], containerBounds: CGRect) {
        super.init()
        
        var maskNodes = [SLOTMaskNodeLayer]()
        var containerLayer = CALayer()
        
        for (index, mask) in masks.enumerated() {
            let node = SLOTMaskNodeLayer(mask: mask, containerBounds: containerBounds)
            maskNodes.append(node)
            if (mask.maskMode == .LOTMaskModeAdd) || (index == 0) {
               containerLayer.addSublayer(node)
            } else {
                containerLayer.mask = node
                let newContainerLayer = CALayer()
                newContainerLayer.addSublayer(containerLayer)
                containerLayer = newContainerLayer
            }
        }
        addSublayer(containerLayer)
        self.masks = maskNodes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
