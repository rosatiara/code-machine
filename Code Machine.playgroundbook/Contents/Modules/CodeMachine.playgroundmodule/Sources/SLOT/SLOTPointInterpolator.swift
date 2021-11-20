//
//  SLOTPointInterpolator.swift
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

class SLOTPointInterpolator : SLOTValueInterpolator {
    
    func pointValue(frame: Double) -> CGPoint {
        
        let progress = self.progress(frame: frame)
        
        if progress == 0 {
            return leadingKeyframe!.pointValue!
        }
        if progress == 1 {
            return trailingKeyframe!.pointValue!
        }
        
        guard let leadingOut = leadingKeyframe?.spatialOutTangent, let trailingIn = trailingKeyframe?.spatialInTangent, let leadingPoint = leadingKeyframe?.pointValue, let trailingPoint = trailingKeyframe?.pointValue else {
            fatalError("All values expected if progress is somewhere in the middle.")
        }
        
        if(!SLOT_CGPointIsZero(leadingOut) && !SLOT_CGPointIsZero(trailingIn)) {
            let outTan = SLOT_PointAddedToPoint(leadingPoint, leadingOut)
            let inTan = SLOT_PointAddedToPoint(trailingPoint, trailingIn)
            return SLOT_PointInCubicCurve(leadingPoint, outTan, inTan, trailingPoint, progress)
        }
        
        return SLOT_PointInLine(leadingPoint, trailingPoint, progress)
    }
    
    override func keyframeData(for value: Any) -> Any? {
        if let value = value as? NSValue {
            return value.cgPointValue
        }
        return nil
    }
}
