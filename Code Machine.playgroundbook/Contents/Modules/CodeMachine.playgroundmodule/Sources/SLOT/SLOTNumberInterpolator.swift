//
//  SLOTNumberInterpolator.swift
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

import CoreGraphics

class SLOTNumberInterpolator: SLOTValueInterpolator {
    
    func floatValue(frame:Double) -> CGFloat {
        let progress = self.progress(frame: frame)
        
        if progress == 0 {
            return leadingKeyframe!.floatValue!
        }
        if progress == 1 {
            return trailingKeyframe!.floatValue!
        }
        
        guard let leadingFloat = leadingKeyframe?.floatValue, let trailingFloat = trailingKeyframe?.floatValue else { fatalError("Both values expected if progress is not at beginning or end.") }
        
        return SLOT_RemapValue(value: progress, low1: 0, high1: 1, low2: leadingFloat, high2: trailingFloat)
    }
    
    override func keyframeData(for value: Any) -> Any? {
        if let value = value as? Int {
            return value
        }
        return nil
    }
}
