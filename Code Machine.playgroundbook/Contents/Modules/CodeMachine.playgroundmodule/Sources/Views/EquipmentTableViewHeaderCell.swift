//
//  EquipmentTableViewHeaderCell.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

class EquipmentTableViewHeaderCell: BodyPartEquipmentTableViewCell {
    
    private var thingViewSize: CGSize {
        let thingView = ThingView()
        thingView.isLarger = false
        return thingView.intrinsicContentSize
    }
    
    override var items: [Thing] {
        
        get {
            return super.items
        }
        
        set(newItems) {
            super.items = newItems
            for thingView in thingViews {
                thingView.isLarger = true
                thingView.backgroundColor = .clear
                thingView.label.isHidden = true
                thingView.imageView.isHidden = false
                thingView.imageView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                thingView.updateBadgeIcon()

            }
        }
    }
    
    override func update() {
        super.update()
        for thingView in thingViews {
            thingView.updateBadgeIcon()
        }
    }
    
    // MARK: Accessibility
    
    override var accessibilityElements: [Any]? {
        get {
            return thingViews
        }
        set { }
    }
}

extension ThingView {
    
    func updateBadgeIcon() {
        var path = isHighlighted ? "ItemIcons/Color" : "ItemIcons/Gray"
        path += isLarger ? "/Large" : "/Small"
        if let iconsURL = Bundle.main.url(forResource: path, withExtension: nil) {
            let iconURL = iconsURL.appendingPathComponent("badge.png")
            if let image = UIImage(contentsOfFile: iconURL.path) {
                imageView.image = image
            }
        }
        backgroundColor = .clear
    }
}

