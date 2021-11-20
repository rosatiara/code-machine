//
//  ThingView.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

@objc(ThingView)
public class ThingView: UIView {
    
    private static let contentSize = CGSize(width: 40, height: 40)
    private static let largerContentSize = CGSize(width: 60, height: 60)
    private static let imageInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    var imageView = UIImageView()
    var label = UILabel()
    private var cachedImageUpdateState: String?
    
    private var normalColor: UIColor = .clear
    private var highlightColor: UIColor = .white
    
    var item: Thing = .undefined {
        didSet {
            isHighlighted = false
            isSelected = false
        }
    }
    
    func update() {
        
        let shouldBeDimmed = (!item.hasBeenForged && !item.isBaseMaterial && !(item == .brick))
        
        // Update the icon.
        let imageUpdateState = "\(item.rawValue).\(isLarger).\(shouldBeDimmed)"
        if imageUpdateState != cachedImageUpdateState {
            cachedImageUpdateState = imageUpdateState
            imageView.image = nil
            var path = shouldBeDimmed ? "ItemIcons/Gray" : "ItemIcons/Color"
            path += isLarger ? "/Large" : "/Small"
            if let iconsURL = Bundle.main.url(forResource: path, withExtension: nil) {
                let iconURL = iconsURL.appendingPathComponent("\(item.rawValue).png")
                if let image = UIImage(contentsOfFile: iconURL.path) {
                    imageView.image = image
                }
            }
        }
        
        normalColor = shouldBeDimmed ? .hocThingBackgroundDimmed : .hocThingBackgroundWhite
        highlightColor = .yellow
        
        if item.isBaseMaterial {
            highlightColor = .hocThingBaseMaterialHighlightColor
        } else if item.isSecondaryItem {
            highlightColor = .hocThingSecondaryItemHighlightColor
        }
        
        backgroundColor = isTransparent ? .clear : normalColor
        backgroundColor = isHighlighted ? highlightColor : backgroundColor
        
        layer.borderColor = isSelected ? tintColor.cgColor : UIColor.clear.cgColor
        layer.borderWidth = isSelected ? 2 : 0
        
        let dimmedAlpha = shouldBeDimmed ? 1.0 : 1.0
        imageView.alpha = CGFloat(dimmedAlpha)
        
        if !item.isBaseMaterial && item.hasBeenForged {
            self.accessibilityTraits = .button
        }
        
        imageView.isHidden = false
        label.isHidden = true
        if showQuestionMarkIfUndefined {
            imageView.isHidden = (item == .undefined)
            label.isHidden = (item != .undefined)
        }
    }
    
    var isHighlighted: Bool = false {
        didSet { update() }
    }
    
    var isSelected: Bool = false {
        didSet { update() }
    }
    
    var isTransparent: Bool = true {
        didSet { update() }
    }
    
    var isLarger: Bool = false {
        didSet { update() }
    }
    
    var showQuestionMarkIfUndefined: Bool = false {
        didSet { update() }
    }
    
    var recipe: Recipe?
    
    var forgedItem: ForgedItem? {
        get {
            guard let recipe = recipe else { return nil }
            return ForgedItem(item: item, recipe: recipe)
        }
        set(newForgedItem) {
            guard let forgedItem = newForgedItem else { return }
            item = forgedItem.item
            recipe = forgedItem.recipe
        }
    }
    
    convenience init(_ item: Thing, frame: CGRect = CGRect(origin: CGPoint.zero, size: ThingView.contentSize)) {
        self.init(frame: frame)
        defer {
            self.item = item
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
        layer.cornerRadius = 8.0
        super.isAccessibilityElement = true
        
        label.isHidden = true
        imageView.frame = bounds.insetBy(dx: ThingView.imageInsets.top, dy: ThingView.imageInsets.left)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
        
        label.text = "?"
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 30.0)
        label.textAlignment = .center
        label.frame = bounds.insetBy(dx: ThingView.imageInsets.top, dy: ThingView.imageInsets.left)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.isHidden = false
        addSubview(label)
    }
    
    override public var intrinsicContentSize: CGSize { return isLarger ? ThingView.largerContentSize : ThingView.contentSize }

    // MARK: Accessibility
    
    var axIncludeItemState: Bool = false
    var axIncludeHint: Bool = false
    
    public override var isAccessibilityElement: Bool {
        get {
            if super.isAccessibilityElement {
                return (item != .undefined)
            }
            return false
        }
        set { super.isAccessibilityElement = newValue }
    }
    
    public override var accessibilityLabel: String? {
        get {
            guard item != .undefined else { return nil }
            // Name
            var label = item.name
            guard axIncludeItemState else { return label }
            // Unforged/Forged
            if item.isSecondaryItem || item.isFinalProduct || item == .brick {
                let itemStatus = item.hasBeenForged ?
                    NSLocalizedString("Forged", comment: "AX label for forged item") :
                    NSLocalizedString("Not yet forged", comment: "AX label for unforged item")
                label += ", \(itemStatus)"
            }
            // Description
            if item.isFinalProduct {
                label += ", \(item.accessibilityDescription)"
            }
            return label
        }
        set { super.accessibilityLabel = newValue }
    }

    public override var accessibilityHint: String? {
        get {
            guard axIncludeHint, item != .undefined else { return nil }
            if item.isBaseMaterial {
                return NSLocalizedString("one of five base elements used in forging", comment: "AX string describing a base element")
            }
            else if item.isSecondaryItem {
                return NSLocalizedString("one of nine secondary elements, forged from base or other secondary elements", comment: "AX string describing a secondary element")
            }
            else {
                return nil
            }
        }
        set { super.accessibilityHint = newValue }
    }
    
    @objc public func describeYourself() -> Void {
        UIAccessibility.post(notification: .announcement, argument: item.accessibilityDescription)
    }
}
