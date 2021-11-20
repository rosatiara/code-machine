//
//  SpotlightOverlayView.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

class SpotlightOverlayView: UIView {
    
    var spotlightLayer = CAShapeLayer()
    
    var machineFrame: CGRect? {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSubviews () {
        super.layoutSubviews()
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        var holeSize = min(frame.width, frame.height) * 0.6
        var holePath = UIBezierPath(ovalIn: CGRect(x: (bounds.width - holeSize) / 2, y: (bounds.height - holeSize) / 2, width: holeSize, height: holeSize))
        if let machineFrame = machineFrame {
            holeSize = min(machineFrame.width, machineFrame.height)
            holePath = UIBezierPath(ovalIn: CGRect(x: machineFrame.midX - (holeSize / 2), y: machineFrame.midY - (holeSize / 2), width: holeSize, height: holeSize))
        }
        path.append(holePath)
        path.usesEvenOddFillRule = true
        
        spotlightLayer.frame = bounds
        spotlightLayer.path = path.cgPath
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        spotlightLayer.fillRule = .evenOdd
        spotlightLayer.fillColor = UIColor.black.cgColor
        spotlightLayer.opacity = 0.6
        layer.addSublayer(spotlightLayer)
    }
}
