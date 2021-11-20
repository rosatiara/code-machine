//
//  ThingCollectionViewCell.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

class ThingCollectionViewCell: UICollectionViewCell {
    
    var thing: Thing {
        get {
            return thingView.item
        }
        set(newThing) {
            thingView.item = newThing
        }
    }
    
    var recipe: Recipe?
    
    var forgedItem: ForgedItem? {
        get {
            return thingView.forgedItem
        }
        set(newForgedItem) {
            thingView.forgedItem = newForgedItem
            thingView.backgroundColor = (thingView.item == .undefined) ? .clear : thingView.backgroundColor
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
        thingView = ThingView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        thingView.axIncludeItemState = true
        thingView.axIncludeHint = true
        contentView.addSubview(thingView)
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        thingView.frame = self.bounds
    }
    
    override public var intrinsicContentSize: CGSize { return CGSize(width: thingView.intrinsicContentSize.width * 2, height: thingView.intrinsicContentSize.height * 2) }
}
