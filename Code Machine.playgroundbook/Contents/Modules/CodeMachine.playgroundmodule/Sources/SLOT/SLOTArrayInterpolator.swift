//
//  SLOTArrayInterpolator.swift
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

class SLOTArrayInterpolator: SLOTValueInterpolator {
    
    public func numberArray(frame: Double) -> [CGFloat] {
        let progress = self.progress(frame: frame)
        
        if progress == 0 {
            let array = leadingKeyframe?.arrayValue as! [Double]
            return array.map { CGFloat($0) }
        }
        
        if progress == 1 {
            let array = trailingKeyframe?.arrayValue as! [Double]
            return array.map { CGFloat($0) }
        }
        
        guard let leadingArray = leadingKeyframe?.arrayValue as? [Double], let trailingArray = trailingKeyframe?.arrayValue as? [Double] else { fatalError("Both values expected if progress is not at beginning or end.") }
        
        var returnArray = [CGFloat]()
        
        for i in 0..<leadingArray.count {
            let from = leadingArray[i]
            let to = trailingArray[i]
            let value = SLOT_RemapValue(value: progress, low1: 0, high1: 1, low2: CGFloat(from), high2: CGFloat(to))
            returnArray.append(value)
        }
        
        return returnArray
    }
    
}
