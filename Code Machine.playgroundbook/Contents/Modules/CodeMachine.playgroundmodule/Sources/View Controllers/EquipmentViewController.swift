//
//  EquipmentViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

protocol EquipmentViewControllerDelegate {
    func didChooseToEquip(equipmentViewController: EquipmentViewController, with item: Thing)
    func didChooseToEquip(equipmentViewController: EquipmentViewController, with equipmentSet: EquipmentSet)
    func didChooseDance(equipmentViewController: EquipmentViewController)
}

@objc(EquipmentViewController)
class EquipmentViewController: UIViewController {
    
    private static let cellReuseIdentifier = "thingViewGridTableViewCell"
    
    private let rowHeight = CGFloat(80.0)

    @IBOutlet weak var danceButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var tableHeaderView = EquipmentTableViewHeaderCell()
    var layoutFrame: CGRect?
    var delegate: EquipmentViewControllerDelegate?
    
    private var contentSize: CGSize {
        get {
            let cell = BodyPartEquipmentTableViewCell()
            guard let bodyPart = Robot.bodyParts.first else { return cell.intrinsicContentSize }
            cell.bodyPart = bodyPart
            cell.items = bodyPart.possibleFinalProducts
            var size = cell.intrinsicContentSize
            let tableHeaderHeight = tableView(tableView, heightForHeaderInSection: 0)
            size.width += 30 // Add margin on both sides.
            size.height = 20 + headerHeightConstraint.constant + tableHeaderHeight + (CGFloat(Robot.bodyParts.count) * rowHeight)
            if let layoutFrame = layoutFrame {
               size.width = min(size.width, layoutFrame.size.width)
               size.height = min(size.height, layoutFrame.size.height)
            }
            return size
        }
    }
    
    // MARK: View Controller Lifecycle
    
    public static func makeFromStoryboard() -> EquipmentViewController {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "EquipmentViewController") as! EquipmentViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        danceButton.setTitle(NSLocalizedString("Dance!", comment: "Dance button title"), for: .normal)
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done button title"), for: .normal)
        
        containerView.backgroundColor = .hocOverlayBackgroundPale
        containerView.layer.cornerRadius = 15
        containerView.clipsToBounds = true
                
        tableHeaderView.items = [.undefined, .undefined, .undefined, .undefined]
        tableHeaderView.delegate = self
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BodyPartEquipmentTableViewCell.self, forCellReuseIdentifier: EquipmentViewController.cellReuseIdentifier)
        tableView.tableFooterView = UIView()
        
        updateHeaderBadges()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    override func updateViewConstraints() {
        if let layoutFrame = layoutFrame {
            // Update constraints for the container view so that it sits neatly inside the layout area.
            let preferredSize = contentSize
            // Center horizontally.
            let dw = (view.bounds.size.width - min(layoutFrame.width, preferredSize.width)) / 2
            containerViewLeadingConstraint.constant = dw
            containerViewTrailingConstraint.constant = dw
            // Center vertically within the layout frame with a small offset to compensate for the gap between the layout frame and the top of Run My Code button.
            let offsetY: CGFloat = 6
            let dy = (layoutFrame.size.height - preferredSize.height) / 2
            containerViewTopConstraint.constant = layoutFrame.origin.y + dy + offsetY
            containerViewBottomConstraint.constant =  view.frame.size.height - containerViewTopConstraint.constant - offsetY - preferredSize.height
        }
        super.updateViewConstraints()
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Dismiss any recipe popover.
        if let _ = self.presentedViewController as? RecipeViewController {
            dismiss(animated: false)
        }
    }
    
    // MARK: Custom methods
    
    func updateHeaderBadges() {
        guard Robot.equipmentSets.count == tableHeaderView.thingViews.count else { return }
        for (index, equipmentSet) in Robot.equipmentSets.enumerated() {
            tableHeaderView.thingViews[index].isHighlighted = equipmentSet.isForged
        }
        tableHeaderView.update()
    }
    
    // MARK: Presentation
    
    static func present(from viewController: UIViewController, within layoutFrame: CGRect? = nil, delegate: EquipmentViewControllerDelegate? = nil) {
        
        let equipmentViewController = EquipmentViewController.makeFromStoryboard()
        equipmentViewController.layoutFrame = layoutFrame
        equipmentViewController.delegate = delegate
        equipmentViewController.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        playSoundFX(.lightSwitchOn)
        
        viewController.present(equipmentViewController, animated: true) {
            UIAccessibility.post(notification: .layoutChanged, argument: equipmentViewController.tableView)
        }
    }

    // MARK: Actions
    
    @IBAction func didTapDanceButton(_ sender: Any) {
        
        if !Robot.isFullyEquipped {
            let alert = UIAlertController(
                title: NSLocalizedString("Warning: Machine Malfunction!", comment: "Dance alert title"),
                message: NSLocalizedString("The machine can’t dance until you’ve equipped each of its six body parts.", comment: "Can’t dance until equipped message"),
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: NSLocalizedString("OK", comment: "OK button title"),
                style: .default) { (alert: UIAlertAction!) -> Void in
            }
            
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Robot is fully equipped so let’s dance.
        dismiss(animated: true, completion: {
            self.delegate?.didChooseDance(equipmentViewController: self)
        })
    }
    
    @IBAction func didTapDoneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDataSource
extension EquipmentViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Robot.bodyParts.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EquipmentViewController.cellReuseIdentifier, for: indexPath) as! BodyPartEquipmentTableViewCell
        
        guard indexPath.row < Robot.bodyParts.count else { return cell }
        
        let bodyPart = Robot.bodyParts[indexPath.item]
        
        cell.delegate = self
        cell.bodyPart = bodyPart
        cell.items = bodyPart.possibleFinalProducts
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension EquipmentViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeaderView.intrinsicContentSize.height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView
    }
}

// MARK: BodyPartEquipmentTableViewCellDelegate
extension EquipmentViewController: BodyPartEquipmentTableViewCellDelegate {
    
    func didSelectItem(thingView: ThingView, item: Thing) {
        // Tapped on an equipment set header.
        if let index = tableHeaderView.thingViews.firstIndex(of: thingView), let equipmentSet = EquipmentSet(rawValue: index) {
            RecipeViewController.presentEquipmentSet(for: equipmentSet, from: self, sourceView: thingView, delegate: self, layoutFrame: layoutFrame)
            return
        }
        
        // Tapped on a final product.
        guard let recipe = item.recipe else { return }
        let forgedItem = ForgedItem(item: item, recipe: recipe)
        RecipeViewController.presentRecipe(for: forgedItem, from: self, sourceView: thingView, equippable: true, delegate: self, layoutFrame: layoutFrame)
    }
    
    func didDoubleTapItem(thingView: ThingView, item: Thing) {
        // Double-tapped on an equipment set header.
        if let index = tableHeaderView.thingViews.firstIndex(of: thingView), let equipmentSet = EquipmentSet(rawValue: index) {
            guard equipmentSet.isForged else { return }
            playSoundFX(.switch1)
            dismiss(animated: true, completion: {
                self.delegate?.didChooseToEquip(equipmentViewController: self, with: equipmentSet)
            })
            return
        }
        
        // Double-tapped on a final product.
        guard let _ = item.recipe else { return }
        playSoundFX(.switch1)
        dismiss(animated: true, completion: {
            self.delegate?.didChooseToEquip(equipmentViewController: self, with: item)
        })
    }
}

// MARK: RecipeViewControllerDelegate
extension EquipmentViewController: RecipeViewControllerDelegate {
    
    func didChooseToEquip(recipeViewController: RecipeViewController, with item: Thing) {
        dismiss(animated: true, completion: {
            self.delegate?.didChooseToEquip(equipmentViewController: self, with: item)
        })
    }
    
    func didChooseToEquip(recipeViewController: RecipeViewController, with equipmentSet: EquipmentSet) {
        dismiss(animated: true, completion: {
            self.delegate?.didChooseToEquip(equipmentViewController: self, with: equipmentSet)
        })
    }
}
