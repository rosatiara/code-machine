//
//  RecipeViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

protocol RecipeViewControllerDelegate {
    func didChooseToEquip(recipeViewController: RecipeViewController, with item: Thing)
    func didChooseToEquip(recipeViewController: RecipeViewController, with equipmentSet: EquipmentSet)
}

@objc(RecipeViewController)
class RecipeViewController: UIViewController {
    
    private var label = UILabel()
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var upperDividerView: UIView!
    @IBOutlet weak var copyCodeButton: UIButton!
    @IBOutlet weak var lowerDividerView: UIView!
    @IBOutlet weak var equipButton: UIButton!
    @IBOutlet weak var axWrapperView: UIView!

    @IBOutlet weak var copyCodeButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var copyCodeButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var equipButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var axWrapperViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var axWrapperViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var axWrapperViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ingredientsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelTopConstraint: NSLayoutConstraint!
    
    var forgedItem = ForgedItem.undefined
    var isEquippable = false
    
    var canCopyCode: Bool { return (forgedItem.recipe != .undefined) && (forgedItem.item != .brick) && (!forgedItem.item.isBaseMaterial) }

    private let margin = CGFloat(12)
    
    var delegate: RecipeViewControllerDelegate?
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var equipmentSet: EquipmentSet?
    
    override var preferredContentSize: CGSize {
        get {
            // Compute width.
            var width: CGFloat = 120
            if canCopyCode || isEquippable {
                equipButton.sizeToFit()
                copyCodeButton.sizeToFit()
                width = max(width, max(equipButton.frame.width, copyCodeButton.frame.width))
            }
            if !ingredientsStackView.isHidden {
                let ingredientsStackViewWidth = ingredientsStackView.arrangedSubviews.compactMap{ $0.intrinsicContentSize.width }.reduce(0, +)
                    + CGFloat(ingredientsStackView.arrangedSubviews.count - 1) * ingredientsStackView.spacing
                width = max(width, ingredientsStackViewWidth)
            }
            // Compute height.
            var height = CGFloat(0)
            height += margin
            height += ingredientsStackViewHeightConstraint.constant
            height += margin
            if ingredientsStackView.isHidden {
                // Name only so allow extra margin top and bottom.
                axWrapperViewTopConstraint.constant = margin * 2.0
                height += margin
            }
            height += nameLabel.sizeThatFits(CGSize(width: width * 0.8, height: CGFloat.greatestFiniteMagnitude)).height
            height += margin
            if canCopyCode {
                height += copyCodeButton.frame.height
                height += margin
            }
            if isEquippable {
                height += equipButton.frame.height
                height += margin
            }
            // Add left and right margins.
            width += axWrapperViewLeadingConstraint.constant + axWrapperViewTrailingConstraint.constant
            return CGSize(width: width, height: height)
        }
        set { super.preferredContentSize = newValue }
    }
    
    // MARK: View Controller Lifecycle
    
    public static func makeFromStoryboard() -> RecipeViewController {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "RecipeViewController") as! RecipeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Custom methods
    
    private func update() {
        if let equipmentSet = equipmentSet {
            // Equipment set.
            name = equipmentSet.name
            isEquippable = equipmentSet.isForged
            copyCodeButton.setTitle(NSLocalizedString("Copy Code", comment: "Copy Code button title"), for: .normal)
            equipButton.setTitle(Robot.isFullyEquippedWith(equipmentSet: equipmentSet) ?
                NSLocalizedString("Unequip Set", comment: "Unequip Set button title") :
                NSLocalizedString("Equip Set", comment: "Equip Set button title"),
                                                      for: .normal)
        } else {
            // Item.
            copyCodeButton.setTitle(NSLocalizedString("Copy Code", comment: "Copy Code button title"), for: .normal)
            equipButton.setTitle(NSLocalizedString("Equip", comment: "Equip button title"), for: .normal)
            if let bodyPart = Robot.bodyPartThatCanBeEquipped(with: forgedItem.item),
                bodyPart.equippedItem == forgedItem.item
            {
                equipButton.setTitle(NSLocalizedString("Unequip", comment: "Unequip button title"), for: .normal)
            }
            name = forgedItem.item.name
        }
        
        copyCodeButton.isHidden = !canCopyCode
        equipButton.isHidden = !isEquippable
        upperDividerView.isHidden = equipButton.isHidden && copyCodeButton.isHidden
        lowerDividerView.isHidden = equipButton.isHidden

        copyCodeButtonHeightConstraint.constant = copyCodeButton.isHidden ? 0 : 40
        equipButtonHeightConstraint.constant = equipButton.isHidden ? 0 : 40
        equipButtonBottomConstraint.isActive = !equipButton.isHidden
        
        ingredientsStackView.isHidden = (equipmentSet != nil) || (forgedItem.item.isBaseMaterial && (forgedItem.recipe == .undefined))
        
        if ingredientsStackView.isHidden {
            ingredientsStackViewHeightConstraint.constant = 0
            nameLabelTopConstraint.constant = 0
            view.setNeedsUpdateConstraints()
        } else {
            ingredientsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let thingViewA = ThingView(forgedItem.recipe.itemA)
            thingViewA.isTransparent = false
            thingViewA.isAccessibilityElement = false
            thingViewA.showQuestionMarkIfUndefined = true
            ingredientsStackView.addArrangedSubview(thingViewA)
            ingredientsStackView.addArrangedSubview(newPlusLabel())
            let thingViewB = ThingView(forgedItem.recipe.itemB)
            thingViewB.isTransparent = false
            thingViewB.isAccessibilityElement = false
            thingViewB.showQuestionMarkIfUndefined = true
            ingredientsStackView.addArrangedSubview(thingViewB)
            if (forgedItem.recipe.light != nil) || (forgedItem.recipe == .undefined) {
                // Show the light view.
                ingredientsStackView.addArrangedSubview(newPlusLabel())
                let lightView = LightView(frame: CGRect(origin: CGPoint.zero, size: LightView().intrinsicContentSize))
                lightView.isOn = true
                lightView.light = forgedItem.recipe.light
                lightView.isAccessibilityElement = false
                ingredientsStackView.addArrangedSubview(lightView)
            }
        }
        
        axWrapperView.isAccessibilityElement = true
        if forgedItem.recipe == .undefined {
            if forgedItem.item.isBaseMaterial {
                axWrapperView.accessibilityLabel = forgedItem.item.name
            } else {
                axWrapperView.accessibilityLabel = String(format:NSLocalizedString("%1$@, not yet forged", comment: "AX description of the recipe used to forge an item"), forgedItem.item.name)
            }
        } else if let axDescription = forgedItem.recipe.accessibilityDescription {
            axWrapperView.accessibilityLabel = String(format:NSLocalizedString("%1$@, forged from %2$@", comment: "AX description of the recipe used to forge an item"), forgedItem.item.name, axDescription)
        }
    }
    
    func newPlusLabel() -> UILabel {
        let plusLabel = UILabel()
        plusLabel.text = "+"
        plusLabel.textColor = nameLabel.textColor
        plusLabel.font = UIFont.systemFont(ofSize: 18.0)
        plusLabel.textAlignment = .center
        return plusLabel
    }
    
    // MARK: Actions
    
    @IBAction func didTapCopyCodeButton(_ sender: Any) {
        UIPasteboard.general.string = forgedItem.code
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapEquipButton(_ sender: Any) {
        playSoundFX(.switch1)
        dismiss(animated: true, completion: {
            if let equipmentSet = self.equipmentSet {
                self.delegate?.didChooseToEquip(recipeViewController: self, with: equipmentSet)
            } else {
                self.delegate?.didChooseToEquip(recipeViewController: self, with: self.forgedItem.item)
            }
        })
    }
    
    // Given a popover size and sourceView, returns the optimal arrow direction(s) and source rect for displaying the popover within layoutFrame.
    static func preferredDirectionsAndSourceRectForPopover(size: CGSize, sourceView: UIView, within layoutFrame: CGRect) -> (UIPopoverArrowDirection, CGRect) {
        
        // Get sourceRect in windows coordinates and allow some space around it for arrow.
        let extendedSourceRect = sourceView.convert(sourceView.bounds, to: nil).insetBy(dx: -16, dy: -16)
        
        // Split the source view into a 3x3 grid and try the center of each side, followed by each corner
        // until we find a direction and source rect from which the presented popover fits neatly within layoutFrame.
        let dx = sourceView.bounds.width / 3
        let dy = sourceView.bounds.height / 3
        let sourceRectSize = CGSize(width: dx, height: dy)
        let midsides: [[Int]] = [[-1, 0], [0, 1], [1, 0], [0, -1]]
        let corners: [[Int]] = [[-1, -1], [-1, 1], [1, 1], [1, -1]]
        let coordinatesToTry = midsides + corners
        
        var presentationRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        var permittedArrowDirections: UIPopoverArrowDirection = []
        var preferredSourceRect = CGRect.zero
        
        for coordinates in coordinatesToTry {
            let offsetX = CGFloat(coordinates[1]) * dx
            let offsetY = CGFloat(coordinates[0]) * dy
            preferredSourceRect = CGRect(x: sourceView.bounds.midX + offsetX - (sourceRectSize.width / 2),
                                         y: sourceView.bounds.midY + offsetY - (sourceRectSize.height / 2),
                                         width: sourceRectSize.width, height: sourceRectSize.height)
            
            if (coordinates[0] == -1) {
                // Down
                presentationRect.origin = CGPoint(x: offsetX + extendedSourceRect.midX - (size.width / 2), y: extendedSourceRect.minY - size.height)
                if layoutFrame.contains(presentationRect) {
                    permittedArrowDirections.insert(.down)
                }
            } else if (coordinates[0] == 1) {
                // Up
                presentationRect.origin = CGPoint(x: offsetX + extendedSourceRect.midX - (size.width / 2), y: extendedSourceRect.maxY)
                if layoutFrame.contains(presentationRect) {
                    permittedArrowDirections.insert(.up)
                }
            }
            if (coordinates[1] == -1) {
                // Right
                presentationRect.origin = CGPoint(x: extendedSourceRect.minX - size.width, y: offsetY + extendedSourceRect.midY - (size.height / 2))
                if layoutFrame.contains(presentationRect) {
                    permittedArrowDirections.insert(.right)
                }
            } else if (coordinates[1] == 1) {
                // Left
                presentationRect.origin = CGPoint(x: extendedSourceRect.maxX, y: offsetY + extendedSourceRect.midY - (size.height / 2))
                if layoutFrame.contains(presentationRect) {
                    permittedArrowDirections.insert(.left)
                }
            }
            
            if !permittedArrowDirections.isEmpty {
                break
            }
        }
        
        if permittedArrowDirections.isEmpty {
            // Unable to find a suitable location after all that => revert to default and leave the OS to deal with it.
            permittedArrowDirections = [.any]
            preferredSourceRect = sourceView.bounds
        }
        
        return (permittedArrowDirections, preferredSourceRect)
    }

    // MARK: Presentation
    
    // Present a popover showing the item name, and (optionally) its recipe along with Copy Code and Equip buttons.
    static func presentRecipe(for forgedItem: ForgedItem, equipmentSet: EquipmentSet? = nil, from viewController: UIViewController, sourceView: UIView, equippable: Bool = false, delegate: RecipeViewControllerDelegate? = nil, arrowDirections: UIPopoverArrowDirection? = nil, layoutFrame: CGRect? = nil) {
        
        let recipeViewController = RecipeViewController.makeFromStoryboard()
        recipeViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        recipeViewController.forgedItem = forgedItem
        recipeViewController.isEquippable = equippable
        recipeViewController.delegate = delegate
        recipeViewController.equipmentSet = equipmentSet

        playSoundFX(.lightSwitchOn)
        
        let arrowGapInset: CGFloat = -4 // Gap between arrow and sourceRect.
        
        // Specify the location and arrow direction of the popover.
        let popoverPresentationController = recipeViewController.popoverPresentationController
        popoverPresentationController?.backgroundColor = recipeViewController.view.backgroundColor
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.popoverLayoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        var sourceRect = sourceView.bounds
        var permittedArrowDirections: UIPopoverArrowDirection = [.any]
        if let arrowDirections = arrowDirections {
            // Use the specified arrow directions.
            permittedArrowDirections = arrowDirections
        } else {
            // Work out the best arrow directions and source rect.
            popoverPresentationController?.permittedArrowDirections = [.any]
            if let layoutFrame = layoutFrame {
                let popoverLayoutFrame = layoutFrame.inset(by: popoverPresentationController?.popoverLayoutMargins ?? UIEdgeInsets.zero)
                let directions = preferredDirectionsAndSourceRectForPopover(size: recipeViewController.preferredContentSize,
                                                                                                       sourceView: sourceView,
                                                                                                       within: popoverLayoutFrame)
                permittedArrowDirections = directions.0
                sourceRect = directions.1
            }
        }
        popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        popoverPresentationController?.sourceRect = sourceRect.insetBy(dx: arrowGapInset, dy: arrowGapInset)
        
        if let ppcDelegate = viewController as? UIPopoverPresentationControllerDelegate {
            popoverPresentationController?.delegate = ppcDelegate
        } else {
            popoverPresentationController?.delegate = recipeViewController
        }
        
        viewController.present(recipeViewController, animated: true) {
            UIAccessibility.post(notification: .layoutChanged, argument: recipeViewController.axWrapperView)
        }
    }
    
    // Present a popover for equipment set.
    static func presentEquipmentSet(for equipmentSet: EquipmentSet, from viewController: UIViewController, sourceView: UIView, delegate: RecipeViewControllerDelegate? = nil, layoutFrame: CGRect? = nil) {
        let dummyForgedItem = ForgedItem(item: .metal, recipe: .undefined)
        let equippable = equipmentSet.isForged
        presentRecipe(for: dummyForgedItem, equipmentSet: equipmentSet, from: viewController, sourceView: sourceView, equippable: equippable, delegate: delegate, layoutFrame: layoutFrame)
    }
}

// MARK: UIPopoverPresentationControllerDelegate

extension RecipeViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // Force the presentation controller to retain its specified presentation style (popover)
        // rather than adapting it to fullscreen for smaller sizes.
        return .none
    }
}
