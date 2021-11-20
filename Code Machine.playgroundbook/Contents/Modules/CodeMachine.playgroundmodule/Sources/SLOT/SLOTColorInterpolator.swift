//
//  SLOTColorInterpolator.swift
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

class SLOTColorInterpolator: SLOTValueInterpolator {
    
    func colorFor(frame: Double) -> UIColor {
        let progress = self.progress(frame: frame)
        
        if progress == 0 {
            return leadingKeyframe?.colorValue ?? .black
        }
        if progress == 1 {
            return trailingKeyframe?.colorValue ?? .black
        }
        
        if let leadingColor = leadingKeyframe?.colorValue,
            let trailingColor = trailingKeyframe?.colorValue,
            let color = UIColor.colorByLerping(fromColor: leadingColor, toColor: trailingColor, byAmount: progress) {
            return color
        }
        return .black
    }
}
