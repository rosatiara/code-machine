//
//  HoCBarButton.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

@objc(HocBarButton)
class HocBarButton: UIButton {
    
    private var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    private let spacing = CGFloat(20.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        updateInsets()
        titleLabel?.font = UIFont.hocBarButtonFont

        blurView.layer.cornerRadius = 22.0
        blurView.clipsToBounds = true
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        addSubview(blurView)
    }
    
    private func updateInsets() {
        contentEdgeInsets = UIEdgeInsets.zero
        imageEdgeInsets = UIEdgeInsets.zero
        titleEdgeInsets = UIEdgeInsets.zero
        if let _ = imageView?.image, let title = titleLabel?.text, !title.isEmpty {
            contentEdgeInsets = UIEdgeInsets(top: 11, left: spacing, bottom: 11, right: spacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing / 2)
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: .normal)
        updateInsets()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: .normal)
        updateInsets()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        sendSubviewToBack(blurView)
    }
    
    override func didMoveToSuperview() {
        if let sv = self.superview {
            setTitleColor(sv.tintColor, for: .normal)
        }
    }
}
