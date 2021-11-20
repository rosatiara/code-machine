//
//  SLOTRenderNode.swift
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

class SLOTRenderNode: SLOTAnimatorNode {
    private(set) var outputLayer: CAShapeLayer = CAShapeLayer()
    var actionsForRenderLayer: [String: CAAction] {
        return ["path": NSNull()]
    }
    
    override init(inputNode: SLOTAnimatorNode?, keyname: String?) {
        super.init(inputNode: inputNode, keyname: keyname)
        outputLayer.actions = actionsForRenderLayer
    }
    
    override func performLocalUpdate() {
        
    }
    
    override func rebuildOutputs() {
        
    }
    
    override var localPath: SLOTBezierPath {
        get {
            return inputNode?.localPath ?? SLOTBezierPath()
        } set {
            inputNode?.localPath = newValue
        }
    }
    
    override var outputPath: SLOTBezierPath {
        get {
            return inputNode?.outputPath ?? SLOTBezierPath()
        } set {
            inputNode?.outputPath = newValue
        }
    }
    
}
