//
//  SLOTRadialGradientLayer.swift
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
import UIKit

class SLOTRadialGradientLayer: CALayer {
    @NSManaged var isRadial: Bool
    @NSManaged var startPoint: CGPoint
    @NSManaged var endPoint: CGPoint
    @NSManaged var colors: [CGColor]
    @NSManaged var locations: [CGFloat]
    
    override class func needsDisplay(forKey key: String) -> Bool {
        
        switch key {
        case "startPoint", "endPoint", "colors", "locations", "isRadial":
            return true
        default:
            return super.needsDisplay(forKey: key)
        }

    }
    
    override func action(forKey event: String) -> CAAction? {
        
        switch event {
        case "startPoint", "endPoint", "colors", "locations", "isRadial":
            let theAnimation = CABasicAnimation(keyPath: event)
            theAnimation.fromValue = self.presentation()?.value(forKey: event)
            return theAnimation
        default:
            return super.action(forKey: event)
        }
        
    }
    
    override func draw(in ctx: CGContext) {
        let numberOfLocations = locations.count
        var numbOfComponents = 0
        var colorSpace: CGColorSpace! = nil
        
        if colors.count > 0 {
            let colorRef = colors[0]
            numbOfComponents = colorRef.numberOfComponents
            colorSpace = colorRef.colorSpace
        }
        
        let origin = startPoint
        let radius = SLOT_PointDistanceFromPoint(startPoint, endPoint)
        let gradientLocations = UnsafeMutablePointer<CGFloat>.allocate(capacity: numberOfLocations)
        let gradientComponents = UnsafeMutablePointer<CGFloat>.allocate(capacity: numberOfLocations * numbOfComponents)
        
        defer {
            gradientLocations.deallocate()
            gradientComponents.deallocate()
        }
        
        for locationIndex in 0..<numberOfLocations {
            gradientLocations[locationIndex] = locations[locationIndex]
            let colorComponents = colors[locationIndex].components!
            
            for componentIndex in 0..<numbOfComponents {
                gradientComponents[numbOfComponents * locationIndex + componentIndex] = colorComponents[componentIndex]
            }
        }
        
        // This feels awful, but the ObjC version doesn’t handle the nil colorspace well at all.
        if colorSpace == nil { return }
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: gradientComponents, locations: gradientLocations, count: numberOfLocations)!
        
        if isRadial {
            ctx.drawRadialGradient(gradient, startCenter: origin, startRadius: 0, endCenter: origin, endRadius: radius, options: .drawsAfterEndLocation)
        } else {
            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }
}
