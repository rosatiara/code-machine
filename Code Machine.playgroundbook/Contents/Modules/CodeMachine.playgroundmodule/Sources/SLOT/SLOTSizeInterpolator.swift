//
//  SLOTSizeInterpolator.swift
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
import CoreGraphics

class SLOTSizeInterpolator : SLOTValueInterpolator {
    
    func sizeValue(frame: Double) -> CGSize {
        
        let progress = self.progress(frame: frame)
        
        if progress == 0 {
            return leadingKeyframe!.sizeValue!
        }
        
        if progress == 1 {
            return trailingKeyframe!.sizeValue!
        }
        
        guard let leadingSize = leadingKeyframe?.sizeValue, let trailingSize = trailingKeyframe?.sizeValue else {
            fatalError("Both values expected if progress is not at beginning or end.")
        }
        
        let mappedWidth = SLOT_RemapValue(value: progress, low1: 0, high1: 1, low2: leadingSize.width, high2: trailingSize.width)
        
        let mappedHeight = SLOT_RemapValue(value: progress, low1: 0, high1: 1, low2: leadingSize.height, high2: trailingSize.height)
        
        return CGSize(width: mappedWidth, height: mappedHeight)
    }
    
    override func keyframeData(for value: Any) -> Any? {
        if let value = value as? NSValue {
            return value.cgSizeValue
        }
        return nil
    }
}
