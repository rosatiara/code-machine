//
//  ConveyorCollectionViewCell.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

class ConveyorCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    var forgedItem: ForgedItem? {
        get {
            return thingView.forgedItem
        }
        set(newForgedItem) {
            thingView.forgedItem = newForgedItem
            thingView.update()
            thingView.backgroundColor = .clear
        }
    }
    
    var thingView: ThingView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        imageView.image = UIImage(named: "ConveyorBelt")
        imageView.contentMode = .scaleToFill
        contentView.addSubview(imageView)
        thingView = ThingView(frame: CGRect(x: 0, y: 0, width: frame.height, height: frame.height))
        thingView.isLarger = true
        contentView.addSubview(thingView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
        thingView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override public var intrinsicContentSize: CGSize { return CGSize(width: 94, height: 88) }
}
