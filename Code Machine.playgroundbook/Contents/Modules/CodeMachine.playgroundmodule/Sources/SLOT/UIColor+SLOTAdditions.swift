//
//  UIColor+SLOTAdditions.swift
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

extension UIColor {
    class func colorByLerping(fromColor: UIColor, toColor: UIColor, byAmount amount: CGFloat) -> UIColor? {
        let clampedAmount = max(max(amount, 0.0), 1.0)
        guard let fromComponents = fromColor.cgColor.components,
            let toComponents = toColor.cgColor.components else { return nil }
        let r = fromComponents[0] + ((toComponents[0] - fromComponents[0]) * clampedAmount)
        let g = fromComponents[1] + ((toComponents[1] - fromComponents[1]) * clampedAmount)
        let b = fromComponents[2] + ((toComponents[2] - fromComponents[2]) * clampedAmount)
        let a = fromComponents[3] + ((toComponents[3] - fromComponents[3]) * clampedAmount)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
