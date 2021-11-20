//
//  BodyPartEquipmentTableViewCell.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

protocol BodyPartEquipmentTableViewCellDelegate {
    
    func didSelectItem(thingView: ThingView, item: Thing)
    func didDoubleTapItem(thingView: ThingView, item: Thing)
}

class BodyPartEquipmentTableViewCell: UITableViewCell {
    
    var stackView = UIStackView()
    var achievmentView = AchievementView()
    var thingViews = [ThingView]()
    
    
    private var thingViewSize: CGSize {
        let thingView = ThingView()
        thingView.isLarger = true
        return thingView.intrinsicContentSize
    }
    
    var bodyPart: BodyPart? {
        didSet {
            achievmentView.selectedBodyPart = bodyPart
        }
    }
    
    var items = [Thing]() {
        didSet {
            thingViews.forEach { $0.removeFromSuperview() }
            thingViews.removeAll()
            for item in items {
                let thingView = ThingView(frame: CGRect(origin: CGPoint.zero, size: thingViewSize))
                thingView.isLarger = true
                thingView.item = item
                thingView.isTransparent = false
                thingView.axIncludeItemState = true
                thingView.axIncludeHint = true
                stackView.addArrangedSubview(thingView)
                thingViews.append(thingView)
                
                let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapThingView(_:)))
                thingView.addGestureRecognizer(tapGesture)
                
                let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapThingView(_:)))
                doubleTapGesture.numberOfTapsRequired = 2
                thingView.addGestureRecognizer(doubleTapGesture)
                
                tapGesture.require(toFail: doubleTapGesture)
                
                let action = UIAccessibilityCustomAction(name: NSLocalizedString("Describe element", comment: "AX action label"), target: thingView, selector: #selector(thingView.describeYourself))
                thingView.accessibilityCustomActions = [action]

            }
            
            update()
        }
    }
    
    func update() {
        for thingView in stackView.arrangedSubviews.compactMap({ $0 as? ThingView }) {
            thingView.isSelected = (bodyPart?.equippedItem == thingView.item)
            thingView.update()
        }
    }
    
    var delegate: BodyPartEquipmentTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        backgroundColor = .clear
        isAccessibilityElement = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 12.0
        stackView.addArrangedSubview(achievmentView)
        contentView.addSubview(stackView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = CGRect(origin: CGPoint.zero, size: intrinsicContentSize)
        stackView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: achievmentView.intrinsicContentSize.width + CGFloat(items.count) * (thingViewSize.width + stackView.spacing), height: max(achievmentView.intrinsicContentSize.height, thingViewSize.height))
    }
    
    // MARK: Actions
    
    @objc
    func didTapThingView(_ gesture: UITapGestureRecognizer) {
        guard let thingView = gesture.view as? ThingView else { return }
        delegate?.didSelectItem(thingView: thingView, item: thingView.item)
    }
    
    @objc
    func didDoubleTapThingView(_ gesture: UITapGestureRecognizer) {
        guard let thingView = gesture.view as? ThingView else { return }
        delegate?.didDoubleTapItem(thingView: thingView, item: thingView.item)
    }
    
    override var accessibilityElements: [Any]? {
        get {
            return [achievmentView] + thingViews
        }
        set { }
    }
}

