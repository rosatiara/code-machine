//
//  LightView.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

@objc(LightView)
public class LightView: UIView {
    
    private let contentSize = CGSize(width: 24, height: 24)
    private let lightSize = CGSize(width: 24, height: 24)
    
    private let colorView = UIView()
    private var label = UILabel()
    
    var light: Light? {
        didSet {
            update()
        }
    }
    
    var isOn: Bool = false {
        didSet {
            update()
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
        colorView.frame = CGRect(origin: CGPoint.zero, size: lightSize)
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.darkGray.cgColor
        addSubview(colorView)
        
        label.text = "?"
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.textAlignment = .center
        label.frame = CGRect(origin: CGPoint.zero, size: lightSize)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.isHidden = false
        addSubview(label)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        colorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        colorView.layer.cornerRadius = colorView.frame.width / 2
    }
    
    private func update() {
        label.isHidden = (light != nil)
        colorView.backgroundColor = UIColor.lightGray
        
        guard let light = light else { return }
        
        let level: CGFloat = isOn ? 1.0 : 0.25
        switch light {
        case .red:
            colorView.backgroundColor = UIColor(displayP3Red: level, green: 0.0, blue: 0.0, alpha: 1.0)
        case .blue:
            colorView.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: level, alpha: 1.0)
        case .green:
            colorView.backgroundColor = UIColor(displayP3Red: 0.0, green: level, blue: 0.0, alpha: 1.0)
        }
    }
    
    override public var intrinsicContentSize: CGSize { return contentSize }
}
