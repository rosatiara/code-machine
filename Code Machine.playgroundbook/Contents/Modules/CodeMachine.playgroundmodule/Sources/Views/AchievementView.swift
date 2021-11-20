//
//  AchievementView.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

@objc(AchievementView)
public class AchievementView: UIView {
    
    private var imageView = UIImageView()
    private let padding = CGFloat(2)
    
    var selectedBodyPart: BodyPart? {
        didSet {
            guard let bodyPart = selectedBodyPart else { return }
            let imageName = "Equip_\(bodyPart.rawValue)"
            imageView.image = UIImage(named: imageName)
            
            accessibilityLabel = String(format: NSLocalizedString("Row containing %@ items", comment: "AX hint for body part on equipment overlay"),
                              bodyPart.name)
            isAccessibilityElement = true
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 80, height: 50)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
