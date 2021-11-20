//
//  EquipConfirmationViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

@objc(EquipConfirmationViewController)
class EquipConfirmationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thingView: ThingView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelWidthConstraint: NSLayoutConstraint!
    var forgedItem: ForgedItem = .undefined
    
    var completion: ((Bool) -> Void)?
    
    override var preferredContentSize: CGSize {
        get {
            let preferredWidth = CGFloat(220)
            let spacing = titleLabelTopConstraint.constant
            let widthMultiplier = titleLabelWidthConstraint.multiplier
            let boundingSize = CGSize(width: preferredWidth * widthMultiplier, height: CGFloat.greatestFiniteMagnitude)
            var height: CGFloat = spacing
            height += titleLabel.sizeThatFits(boundingSize).height
            height += spacing
            height += thingView.bounds.size.height
            height += spacing
            height += messageLabel.sizeThatFits(boundingSize).height
            height += spacing
            height += buttonsStackView.bounds.size.height
            return CGSize(width: preferredWidth, height: height)
        }
        set { super.preferredContentSize = newValue }
    }
    
    public static func makeFromStoryboard() -> EquipConfirmationViewController {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "EquipConfirmationViewController") as! EquipConfirmationViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        thingView.item = forgedItem.item
        thingView.isLarger = true
        thingView.isTransparent = false
        thingView.layer.shadowOffset = CGSize(width: 0, height: 0)
        thingView.layer.shadowRadius = 15.0
        thingView.layer.shadowOpacity = 0.5
        thingView.layer.shadowColor = UIColor.black.cgColor
        titleLabel.text = String(format: NSLocalizedString("You forged: %1$@!", comment: "Title for equip confirmation alert."), forgedItem.item.name)
        messageLabel.text = NSLocalizedString("Do you want to equip this item right now?", comment: "Message for equip confirmation alert.")
        leftButton.setTitle(NSLocalizedString("No", comment: "No button title"), for: .normal)
        rightButton.setTitle(NSLocalizedString("Yes", comment: "Yes button title"), for: .normal)
        // Accessibility Identifiers
        messageLabel.accessibilityIdentifier = "\(type(of: self)).equipMessage"
        leftButton.accessibilityIdentifier = "\(type(of: self)).noBtn"
        rightButton.accessibilityIdentifier = "\(type(of: self)).yesBtn"
        // We remove the button trait here because this ThingView doesn’t respond like a button in this context.
        thingView.accessibilityTraits = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapLeftButton(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.completion?(false)
        })
    }
    
    @IBAction func didTapRightButton(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.completion?(true)
        })
    }
}
