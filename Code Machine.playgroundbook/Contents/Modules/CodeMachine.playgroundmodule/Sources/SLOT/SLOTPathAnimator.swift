//
//  SLOTPathAnimator.swift
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

class SLOTPathAnimator: SLOTAnimatorNode {
    
    var pathContent: SLOTShapePath?
    var interpolator: SLOTPathInterpolator?
    
    init(inputNode: SLOTAnimatorNode?, shapePath: SLOTShapePath) {
        super.init(inputNode: inputNode, keyname: shapePath.keyname ?? "")
        pathContent = shapePath
        if let keyframes = pathContent?.shapePath?.keyframes {
            interpolator = SLOTPathInterpolator(keyframes: keyframes)
        }
    }
    
    override var valueInterpolators: [String : Any]? {
        get {
            guard let interpolator = interpolator else { return nil }
            return ["Path" : interpolator as Any]
        }
        set {
            super.valueInterpolators = newValue
        }
    }
    
    override func needsUpdate(frame: Double) -> Bool {
        return interpolator?.hasUpdate(frame: frame) ?? false
    }
    
    override func performLocalUpdate() {
        guard let frame = currentFrame else { return }
        if let interpolator = interpolator {
            localPath = interpolator.path(frame: frame, cacheLengths: pathShouldCacheLengths)
        }
    }
}
