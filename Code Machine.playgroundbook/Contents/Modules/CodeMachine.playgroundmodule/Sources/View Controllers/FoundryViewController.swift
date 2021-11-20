//
//  FoundryViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport
import SPCCore
import SPCAudio
import SPCLiveView
import AVFoundation

@objc(FoundryViewController)
public class FoundryViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var ingredientsTopContainerView: UIView!
    @IBOutlet weak var centerStackView: UIStackView!
    @IBOutlet weak var baseMaterialsLeftContainerView: UIView!
    @IBOutlet weak var secondaryItemsRightContainerView: UIView!
    
    @IBOutlet weak var machineOuterContainerView: UIView!
    @IBOutlet weak var machineContainerView: UIView!
    @IBOutlet weak var ouputItemsContainerView: UIView!
    
    @IBOutlet weak var leftBarButton: HocBarButton!
    @IBOutlet weak var rightBarButton: HocBarButton!
    @IBOutlet weak var conveyorSupportImageView: UIImageView!
    @IBOutlet weak var liveViewSafeAreaBottomView: UIView!
    
    @IBOutlet weak var outerStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var machineContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var conveyorSupportBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseMaterialsLeftContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var secondaryItemsRightContainerWidth: NSLayoutConstraint!

    private var leftBarButtonTopSafeAreaConstraint = NSLayoutConstraint()
    private var rightBarButtonTopSafeAreaConstraint = NSLayoutConstraint()
    
    private var conveyorBeltViewController: ConveyorBeltViewController?
    private var ingredientsTopViewController: ItemsViewController?
    private var baseMaterialsLeftViewController: ItemsViewController?
    private var secondaryItemsRightViewController: ItemsViewController?
    
    private var danceOverlayView: SpotlightOverlayView?

    private var stateMachine = IngredientStateMachine()
    private var forgeResult: Thing?
    private var machine = Machine()
    private var forgingSpeed: Speed = .normal
    private var isEquipAlertsEnabled = true
    private var isAutoEquipEnabled = false

    // Flag to indicate that the live view has been paused while it is disappeared.
    private var isPausedWhileDisappeared = false
    
    // Flag to indicate that the live view has been paused while it is in the background.
    private var isPausedWhileExtensionInBackground = false
    private var deferredForgedItem: ForgedItem?
            
    // Flag to indicate that view is in launch mode.
    private var isInLaunchMode = false
            
    private var isInLandscapeOrientation: Bool {
        return view.frame.width > view.frame.height
    }
    
    private var isReduceMotionEnabled: Bool {
        return UIAccessibility.isReduceMotionEnabled
    }
    
    private var forgeCycleCount = 0
    
    private var previousViewSize = CGSize.zero
    
    private var autoPlayCelebrationDanceWhenFullyEquipped = false
    private var hasAutoPlayedCelebrationDance = false
    
    private let audioPlayerQueue = DispatchQueue(label: "com.apple.audioPlayerQueue")
    
    // MARK: View Controller Lifecycle
    
    public static func makeFromStoryboard() -> FoundryViewController {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "FoundryViewController") as! FoundryViewController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        leftBarButton.setTitle(NSLocalizedString("Equipment", comment: "Equipment button title"), for: .normal)
        leftBarButton.accessibilityHint = NSLocalizedString("View all your forged items and equip the machine", comment: "AX hint for Equipment button")
        leftBarButton.accessibilityIdentifier = "\(type(of: self)).equipment"
        leftBarButton.setImage(UIImage(named: "EquipMenuIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        // Audio button supplied by SPCAudio.
        rightBarButton.isHidden = true
        
        if let image = UIImage(named: "ConveyorSupport") {
            conveyorSupportImageView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            conveyorSupportImageView.accessibilityLabel = NSLocalizedString("Conveyor belt onto which newly forged items land", comment: "AX label for conveyor belt")
            conveyorSupportImageView.accessibilityIdentifier = "\(type(of: self)).ConveyorSupport"
        }
        
        // Load the machine.
        machine.load()
        machine.frame = machineContainerView.bounds
        machine.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        machineContainerView.addSubview(machine)
        // Hide it initially.
        machine.alpha = 0.0
        
        stateMachine.delegate = self
        stateMachine.reset()
        
        // Restore any equipped body parts.
        restoreEquippedState()
        
        // Constrain the top buttons to within the `liveViewSafeAreaGuide`.
        leftBarButtonTopSafeAreaConstraint = leftBarButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20)
        rightBarButtonTopSafeAreaConstraint = rightBarButton.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20)
        NSLayoutConstraint.activate( [leftBarButtonTopSafeAreaConstraint, rightBarButtonTopSafeAreaConstraint])
        
        previousViewSize = CGSize.zero
        
        // Hide ingredient containers initially.
        ingredientsTopContainerView.isHidden = true
        baseMaterialsLeftContainerView.isHidden = true
        secondaryItemsRightContainerView.isHidden = true
        ingredientsTopContainerView.alpha = 0.0
        baseMaterialsLeftContainerView.alpha = 0.0
        secondaryItemsRightContainerView.alpha = 0.0

        // Configure the audio session to listen to background audio notifications.
        AudioSession.current.delegate = self
        AudioSession.current.configureEnvironment()
    
        LiveViewExtensionHost.current.delegate = self
        
        // This hidden view is anchored to the bottom of the liveViewSafeAreaGuide so that
        // changes to the safe area (e.g. the UCB being invoked) trigger a layout update.
        NSLayoutConstraint.activate([
            liveViewSafeAreaBottomView.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor, constant: 0)
            ])
        
        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapMachine(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        machine.addGestureRecognizer(doubleTapGesture)
        
        isInLaunchMode = true
        
        CodeMachineLiveViewProxy.registerToRecieveDecodedMessage(as: self)
        //AudioProxy.registerToRecieveDecodedMessage(as: self)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            
            // Reveal the machine for the first time if it’s hidden (as on page load).
            guard self.machine.alpha == 0.0 else { return }
            self.machine.reveal(reduceMotion: self.isReduceMotionEnabled)
        })
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: {
            // Reveal the ingredients panel(s) if they’re hidden (as on page load).
            guard self.ingredientsTopContainerView.alpha == 0.0, self.baseMaterialsLeftContainerView.alpha == 0.0, self.secondaryItemsRightContainerView.alpha == 0.0 else { return }
            self.revealIngredientsPanels(completion: {
                self.isInLaunchMode = false
            })
        })
        
        // Reactivate machine animation if it was interrupted e.g. by view disappearing.
        if isPausedWhileDisappeared {
            machine.restoreState()
            if isReduceMotionEnabled {
                machine.stopIdlingVibration()
            } else {
                machine.startIdlingVibration()
            }
            isPausedWhileDisappeared = false
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isPausedWhileDisappeared = true
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        switch segueIdentifier {
        case "ConveyorBeltViewControllerSegue":
            guard let viewController = segue.destination as? ConveyorBeltViewController else { return }
            viewController.delegate = self
            conveyorBeltViewController = viewController
        case "IngredientsTopSegue":
            guard let itemsViewController = segue.destination as? ItemsViewController else { return }
            itemsViewController.delegate = self
            itemsViewController.orientation = .horizontal
            ingredientsTopViewController = itemsViewController
            itemsViewController.items = itemsForIngredientsPanel(ingredientsTopViewController)
        case "BaseMaterialsLeftSegue":
            guard let itemsViewController = segue.destination as? ItemsViewController else { return }
            itemsViewController.delegate = self
            itemsViewController.orientation = .vertical
            itemsViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            baseMaterialsLeftViewController = itemsViewController
            itemsViewController.items = itemsForIngredientsPanel(baseMaterialsLeftViewController)
        case "SecondaryItemsRightSegue":
            guard let itemsViewController = segue.destination as? ItemsViewController else { return }
            itemsViewController.delegate = self
            itemsViewController.orientation = .vertical
            itemsViewController.view.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            secondaryItemsRightViewController = itemsViewController
            itemsViewController.items = itemsForIngredientsPanel(secondaryItemsRightViewController)
        default:
            break
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Layout
    
    override public func viewDidLayoutSubviews() {
        // Configure layout (if necessary).
        configureLayout(for: view.frame.size)
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Dismiss any recipe popover.
        dismissRecipePopover()
        
        // Dismiss equipment panel if it would be too small.
        if shouldEquipmentPanelBeHiddenFor(size: size) {
            dismissEquipmentPanel()
        }
        
        let isTransitioningToLandscape = (size.width > size.height)
        
        coordinator.animate(alongsideTransition: {  _ in
            self.ingredientsTopContainerView.alpha = isTransitioningToLandscape ? 0.0 : 1.0
            self.baseMaterialsLeftContainerView.alpha = isTransitioningToLandscape ? 1.0 : 0.0
            self.secondaryItemsRightContainerView.alpha = isTransitioningToLandscape ? 1.0 : 0.0
        }, completion: { _ in
            self.configureLayout(for: size)
        })
    }
    
    private func configureLayout(for size: CGSize) {
        
        // Respond to live view safe area changes.
        
        // Get the height of the area below the safe area.
        let safeAreaTopHeight = liveViewSafeAreaGuide.layoutFrame.minY
        let safeAreaBottomHeight = view.frame.height - liveViewSafeAreaGuide.layoutFrame.maxY
        // Limit to the height of the conveyor support image i.e. ignore keyboard appearance.
        let conveyorAdjustmentHeight = min(safeAreaBottomHeight, conveyorSupportImageView.frame.height)
        // Adjust the gap above the Run My Code button depending on available vertical space.
        let gapAboveRunMyCode = CGFloat((size.height <= CGFloat(683.0)) ? -12 : 24)
        // Adjust the conveyor up or down depending on whether the UCB is visible.
        conveyorSupportBottomConstraint.constant = conveyorSupportImageView.frame.height - conveyorAdjustmentHeight - gapAboveRunMyCode

        guard size != previousViewSize else { return }
        
        // Respond to view size changes.
        
        previousViewSize = size
        let isLandscape = (size.width > size.height)
        let buttonsAreHidden = shouldEquipmentPanelBeHiddenFor(size: size)
        
        // Adjust constraints.
        leftBarButtonTopSafeAreaConstraint.constant = CGFloat(isLandscape ? 10 : 20)
        rightBarButtonTopSafeAreaConstraint.constant = CGFloat(isLandscape ? 10 : 20)
        machineContainerViewHeightConstraint = machineContainerViewHeightConstraint.copy(withMultiplier: CGFloat(isLandscape ? 1.0 : 1.0))
        
        // Show Equipment and Audio buttons based on available space
        leftBarButton.isHidden = buttonsAreHidden
        rightBarButton.isHidden = true //buttonsAreHidden
        
        // Show appropriate ingredient containers based on aspect ratio and available space.
        ingredientsTopContainerView.isHidden = false
        baseMaterialsLeftContainerView.isHidden = false
        secondaryItemsRightContainerView.isHidden = false
        if size.width <= CGFloat(375.0) {
            // Not enough room so hide all ingredients.
            ingredientsTopContainerView.isHidden = true
            baseMaterialsLeftContainerView.isHidden = true
            secondaryItemsRightContainerView.isHidden = true
        } else if isLandscape {
            // Landscape: show left and right ingredients.
            ingredientsTopContainerView.isHidden = true
            baseMaterialsLeftContainerView.isHidden = false
            secondaryItemsRightContainerView.isHidden = false
        } else {
            // Portrait: show top ingredients.
            ingredientsTopContainerView.isHidden = false
            baseMaterialsLeftContainerView.isHidden = true
            secondaryItemsRightContainerView.isHidden = true
        }
        
        // Adjust the offset of the outer stack view from the top of the view.
        var outerStackViewTopOffset = safeAreaTopHeight
        if buttonsAreHidden {
            outerStackViewTopOffset += ingredientsTopContainerView.isHidden ? 0 : leftBarButtonTopSafeAreaConstraint.constant
        } else {
            outerStackViewTopOffset += ingredientsTopContainerView.isHidden ?
                leftBarButtonTopSafeAreaConstraint.constant + leftBarButton.bounds.size.height :
                (leftBarButtonTopSafeAreaConstraint.constant * 2) + leftBarButton.bounds.size.height
        }
        outerStackViewTopConstraint.constant = outerStackViewTopOffset
        
        // Reconfigure items in left/right ingredient containers for best fit.
        if isLandscape {
            if let itemsViewController = baseMaterialsLeftViewController {
                itemsViewController.items = itemsForIngredientsPanel(baseMaterialsLeftViewController, availableSize: size)
                baseMaterialsLeftContainerWidth.constant = itemsViewController.preferredContentSize.width
            }
            if let itemsViewController = secondaryItemsRightViewController {
                itemsViewController.items = itemsForIngredientsPanel(secondaryItemsRightViewController, availableSize: size)
                secondaryItemsRightContainerWidth.constant = itemsViewController.preferredContentSize.width
            }
        }
        
        // Reset ingredient container alpha in case transition animation interrupted.
        if !isInLaunchMode {
            ingredientsTopContainerView.alpha = 1.0
            baseMaterialsLeftContainerView.alpha = 1.0
            secondaryItemsRightContainerView.alpha = 1.0
        }
        
        // Update the equipment panel if presented.
        if let equipmentViewController = self.presentedViewController as? EquipmentViewController {
            equipmentViewController.layoutFrame = liveViewSafeAreaGuide.layoutFrame
            equipmentViewController.view.setNeedsUpdateConstraints()
        }
        
        // Update the celebration dance overlay if visible.
        if let danceOverlayView = danceOverlayView {
            DispatchQueue.main.async {
                danceOverlayView.machineFrame = self.machineOuterContainerView.superview?.convert(self.machineOuterContainerView.frame, to: nil)
            }
        }
    }
    
    private func shouldEquipmentPanelBeHiddenFor(size: CGSize) -> Bool {
        return (size.width <= CGFloat(438.0)) || (size.height <= CGFloat(384.0))
    }
    
    private func revealIngredientsPanels(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.ingredientsTopContainerView.alpha = 1.0
            self.baseMaterialsLeftContainerView.alpha = 1.0
            self.secondaryItemsRightContainerView.alpha = 1.0
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: General
    
    // Returns the items that should appear in an ingredients panel: one array of items per row or column.
    private func itemsForIngredientsPanel(_ viewController: ItemsViewController?, availableSize: CGSize? = nil) -> [[Thing]] {
        var items = [[Thing]]()
        let compactVerticalHeight = CGFloat(384.0)
        
        // Top panel.
        if viewController == ingredientsTopViewController {
            // One row of base materials and one row of secondary items.
            items = [Thing.baseMaterials, Thing.secondaryItems]
            
        // Left-hand panel.
        } else if viewController == baseMaterialsLeftViewController {
            // Single column of base materials.
            items = [Thing.baseMaterials]
            if let size = availableSize, size.height <= compactVerticalHeight {
                // Two columns of base materials.
                items = [Array(Thing.baseMaterials[0...2]), Array(Thing.baseMaterials[3...4])]
            }
            
        // Right-hand panel.
        } else if viewController == secondaryItemsRightViewController {
            // Two columns of secondary items.
            items = [Array(Thing.secondaryItems[0...3]), Array(Thing.secondaryItems[4...8])]
            if let size = availableSize, size.height <= compactVerticalHeight {
                // Three columns of secondary items.
                items = [Array(Thing.secondaryItems[0...2]), Array(Thing.secondaryItems[3...5]), Array(Thing.secondaryItems[6...8])]
            }
        }
        
        return items
    }
    
    func resetAll() {
        playSoundFX(.whistle)
        Thing.resetState()
        Robot.resetState()
        updateSecondaryItemStatus()
        clearConveyorBelt()
        machine.unequipAll()
    }
    
    private func clearConveyorBelt() {
        self.conveyorBeltViewController?.clear()
    }
    
    // Given an item return its ThingView and position.
    private func getThingViewAndPosition(for item: Thing) -> (ThingView, CGPoint)? {
        var itemsViewController: ItemsViewController?
        if item.isBaseMaterial {
            itemsViewController = baseMaterialsLeftContainerView.isHidden ? ingredientsTopViewController : baseMaterialsLeftViewController
        } else if item.isSecondaryItem {
            itemsViewController = secondaryItemsRightContainerView.isHidden ? ingredientsTopViewController : secondaryItemsRightViewController
        }
        
        if let itemsViewController = itemsViewController,
            let cell = itemsViewController.cellFor(item: item),
            let position = itemsViewController.getPosition(of: cell, relativeTo: view) {
            return (cell.thingView, position)
        }
    
        return nil
    }
    
    // Given a ThingView return the arrow direction of a popover that points to it.
    private func getPopoverArrowDirections(for thingView: ThingView) -> UIPopoverArrowDirection {
        var arrowDirections: UIPopoverArrowDirection = [.any]
        if thingView.item.isBaseMaterial {
            arrowDirections = baseMaterialsLeftContainerView.isHidden ? [.up] : [.left]
        } else if thingView.item.isSecondaryItem {
            arrowDirections = secondaryItemsRightContainerView.isHidden ? [.up] : [.right]
        }
        return arrowDirections
    }
    
    private func updateSecondaryItemStatus() {
        ingredientsTopViewController?.updateItemStatus()
        secondaryItemsRightViewController?.updateItemStatus()
    }
    
    // MARK: Forging
    
    private func startForgeCycle() {
        // Pause idle events while forging.
        machine.stopIdleEvents()
        
        // Dismiss any presented viewcontroller such as the Equipment panel or a recipe popover.
        if let _ = presentedViewController { dismiss(animated: false) }
        
        // Increase forging speed after a certain number of items.
        if forgeCycleCount >= 4 {
            forgingSpeed = .fast
        }
        
        // VoiceOver announcement that forging has begun
        if UIAccessibility.isVoiceOverRunning {
            var desc = ""
            if let title = stateMachine.currentRecipe.accessibilityDescription {
                desc = title
            }
            UIAccessibility.post(notification: .announcement, argument: String(format: NSLocalizedString("Forging %@", comment: "AX announcement for the start of forging"), desc))
        }
        
        // Add a short initial delay before the first forge cycle.
        let initialDelay = (forgeCycleCount == 0) ? 1.0 : 0.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + initialDelay, execute: {
            let _ = self.stateMachine.forgeItems()
        })
    }
    
    private func animateInputItem(_ item: Thing, to finalPosition: CGPoint, speed: Speed = .normal, completion: (() -> Void)? = nil) {
        guard let thingViewAndPosition = getThingViewAndPosition(for: item) else {
            // Item is not found in the ingredients panels => nothing to animate into the funnel.
            completion?()
            return
        }
        
        let duration = speed.isFast ? 0.25 : 0.75
        
        let movingView = ThingView(item, frame: CGRect(origin: CGPoint(x: 0, y: 0), size: ThingView().intrinsicContentSize))
        movingView.center = thingViewAndPosition.1
        view.addSubview(movingView)
        
        var intermediatePosition1 = CGPoint(x: movingView.center.x, y: finalPosition.y * 0.5)
        var intermediatePosition2 = CGPoint(x: movingView.center.x, y: finalPosition.y * 0.75)
        let dx1 = abs(finalPosition.x - movingView.center.x) * 0.4
        let dx2 = abs(finalPosition.x - movingView.center.x) * 0.4
        if finalPosition.x > movingView.center.x {
            intermediatePosition1.x += dx1
            intermediatePosition2.x = intermediatePosition1.x + dx2
        } else {
            intermediatePosition1.x -= dx1
            intermediatePosition2.x = intermediatePosition1.x - dx2
        }

        if isInLandscapeOrientation {
            if finalPosition.x > movingView.center.x {
                intermediatePosition1 = CGPoint(x: movingView.center.x + 80, y: movingView.center.y)
                intermediatePosition2 = CGPoint(x: finalPosition.x - 40, y: finalPosition.y * 0.6)
            } else {
                intermediatePosition1 = CGPoint(x: movingView.center.x - 80, y: movingView.center.y)
                intermediatePosition2 = CGPoint(x: finalPosition.x + 40, y: finalPosition.y * 0.6)
            }
        }
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubicPaced, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4) {
                movingView.center = intermediatePosition1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.4) {
                movingView.center = intermediatePosition2
            }

            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                movingView.alpha = 0.0
                movingView.center = finalPosition
            }

        }, completion: { _ in
            movingView.removeFromSuperview()
            thingViewAndPosition.0.isHighlighted = false
            completion?()
        })
    }
    
    private func animateForgedItem(_ forgedItem: ForgedItem, speed: Speed = .normal, completion: (() -> Void)? = nil) {
        guard let conveyorBelt = self.conveyorBeltViewController else { return }
        
        let duration = speed.isFast ? 0.25 : 1.0
        
        let finalPosition = conveyorBelt.view.convert(conveyorBelt.centerOfLeftMostAvailableEmptyCell(), to: self.view)
        let outputPositionInContainer = CGPoint(x: machine.normalizedOutputPosition.x * machineContainerView.frame.width,
                                                     y: machine.normalizedOutputPosition.y * machineContainerView.frame.height)
        let outputInitialPosition = machineContainerView.convert(outputPositionInContainer, to: view)
        let verticalFallDistance = abs(finalPosition.y - outputInitialPosition.y)
        let intermediatePosition = CGPoint(x: finalPosition.x, y: outputInitialPosition.y + (verticalFallDistance * 0.5)) // Half-way down
        let conveyorCellSize = ConveyorCollectionViewCell().intrinsicContentSize
        let finalMovingViewSize = CGSize(width: conveyorCellSize.height, height: conveyorCellSize.height)
        
        let movingView = ThingView(forgedItem.item, frame: CGRect(origin: CGPoint(x: 0, y: 0), size: ThingView().intrinsicContentSize))
        movingView.center = outputInitialPosition
        movingView.isLarger = true
        movingView.alpha = 0.0
        view.addSubview(movingView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration * 0.4, execute: {
            SoundFX.playForgedSound(for: forgedItem)
        })
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeLinear, animations: {
            
            // Move the forged item to a point below the chute and directly above where it should land on the conveyor.
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                movingView.alpha = 1.0
                movingView.center = intermediatePosition
            }
            
            // Drop the forged item onto the conveyor.
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                movingView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: finalMovingViewSize)
                movingView.center = finalPosition
            }
            
        }, completion: { _ in
            
            completion?()
            movingView.removeFromSuperview()
        })
    }
    
    private func animateForgeCycle(forgedItem: ForgedItem, speed: Speed = .normal, completion: (() -> Void)? = nil) {
        guard let conveyorBelt = self.conveyorBeltViewController else { return }
        
        // Dismiss any recipe popover.
        dismissRecipePopover()
        
        let inputFunnelPositionInContainer = CGPoint(x: machine.normalizedInputPosition.x * machineContainerView.frame.width,
                                          y: machine.normalizedInputPosition.y * machineContainerView.frame.height)
        let inputFunnelPosition = machineContainerView.convert(inputFunnelPositionInContainer, to: view)
        
        if speed.isNormal {
            playSoundFX(.enteringFunnel)
        } else if speed.isFast {
            playSoundFX(.fastEntering)
        }
        
        // Animate the first item into the machine input funnel.
        animateInputItem(forgedItem.recipe.itemA, to: inputFunnelPosition, speed: speed, completion: {
            
            if speed.isNormal {
                playSoundFX(.enteringFunnel)
            }
            
            // Animate the second item into the machine input funnel.
            self.animateInputItem(forgedItem.recipe.itemB, to: inputFunnelPosition, speed: speed, completion: {
                
                // Forge the items.
                self.machine.forge(speed: speed, reduceMotion: self.isReduceMotionEnabled, completion: {
                    
                    // Dismiss any recipe popover so it won’t be in the wrong place when the conveyor advances.
                    self.dismissRecipePopover()
                    
                    // Advance the conveyor so it’s ready to receive the newly forged item.
                    conveyorBelt.advanceForNextItem(completion: {
                    
                        // Animate the forged item out the machine’s output chute.
                        self.machine.popOutForgedItem(speed: speed, completion: {
                        
                            // Animate the forged item onto the conveyor.
                            self.animateForgedItem(forgedItem, speed: speed, completion: {
                                
                                // Stop the machine forging.
                                self.machine.stopForging()
                                
                                // Calls finishForgeCycle.
                                completion?()
                            })
                        })
                    })
                })
            })
        })
    }
    
    private func finishForgeCycle(forgedItem: ForgedItem) {
        forgeCycleCount += 1
        
        // Add the forged item to the output items tray.
        _ = conveyorBeltViewController?.addItem(forgedItem: forgedItem)
        
        // Update secondary items to show forged items.
        updateSecondaryItemStatus()
        
        //PostNotification for VO to speak process ends and add item description
        
        // VoiceOver announcement that forging has ended and the produced output
        if UIAccessibility.isVoiceOverRunning {
            let desc = forgedItem.item.accessibilityDescription
            UIAccessibility.post(notification: .announcement, argument: String(format: NSLocalizedString("Forging complete, %@ produced", comment: "AX announcement when forging is complete"), desc))
        }
        
        // Complete next steps after the item is forged.
        if forgedItem.item.isFinalProduct, forgedItem.isForgedFirstTime
        {
            // A final product has been forged for the first time.
            if isEquipAlertsEnabled {
                // Prompt user to equip with the forged item.
                let equipConfirmationViewController = EquipConfirmationViewController.makeFromStoryboard()
                equipConfirmationViewController.modalPresentationStyle = UIModalPresentationStyle.formSheet
                equipConfirmationViewController.forgedItem = forgedItem
                equipConfirmationViewController.completion = { equipConfirmed in
                    
                    if equipConfirmed {
                        DispatchQueue.main.async {
                            self.equipOrUnequip(item: forgedItem.item, completion: {
                                self.notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
                            })
                        }
                    } else {
                        self.notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
                    }
                    
                    // Refocus AX back on the machine after dismissing the form sheet.
                    UIAccessibility.post(notification: .layoutChanged, argument: self.machineContainerView)
                    UIAccessibility.post(notification: .layoutChanged, argument: self.machineContainerView)
                }
                
                // Dismiss any presented viewcontroller such as a recipe popover.
                if let _ = presentedViewController { dismiss(animated: false) }

                present(equipConfirmationViewController, animated: true, completion: {
                    if UIAccessibility.isVoiceOverRunning {
                        UIAccessibility.post(notification: .layoutChanged,
                                             argument: equipConfirmationViewController.view)
                    }
                })
                
            } else {
                // Equip alert disabled.
                if isAutoEquipEnabled {
                    // Automatically equip with the forged item.
                    equipOrUnequip(item: forgedItem.item, completion: {
                        self.notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
                    })
                } else {
                    notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
                }
            }
            
        } else {
            notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
        }
    }
    
    private func notifyUserProcessOfCompletedForgeCycle(forgedItem: ForgedItem) {
        
        // Check if the live view extension has gone into the background. If so, defer notifying
        // the user process until such time as the live view extension has re-entered the foreground.
        if isPausedWhileExtensionInBackground {
            deferredForgedItem = forgedItem
            return
        }
        
        // Resume idle events.
        machine.startIdleEvents(after: 5.0)

//        guard let proxy = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler else { return }
                
        // Interval before next forge cycle, if there is one.
        let delay = forgingSpeed.isFast ? 0.5 : 2.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: {
            CodeMachineUserCodeProxy.shared.itemForged(item: forgedItem)
//            proxy.send(
//                PlaygroundMessageFromLiveView.itemForged(item: forgedItem).playgroundValue
//            )
        })
    }
    
    // MARK: Equipping
    
    func restoreEquippedState() {
        for bodyPart in Robot.bodyParts {
            guard let item = bodyPart.equippedItem else { continue }
            machine.equip(bodyPart: bodyPart, item: item, silent: true)
        }
    }
    
    func equipOrUnequip(bodyPart: BodyPart, item: Thing, silent: Bool = false) {
        machine.equipOrUnequip(bodyPart: bodyPart, item: item, silent: silent)
    }
    
    func equipOrUnequip(item: Thing, completion: (() -> Void)? = nil) {
        guard let bodyPart = Robot.bodyPartThatCanBeEquipped(with: item) else {
            completion?()
            return
        }
        equipOrUnequip(bodyPart: bodyPart, item: item)
        if Robot.isFullyEquipped && autoPlayCelebrationDanceWhenFullyEquipped && !hasAutoPlayedCelebrationDance {
            playCelebrationDance(completion: {
                self.hasAutoPlayedCelebrationDance = true
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    func equipOrUnequip(equipmentSet: EquipmentSet) {
        guard equipmentSet.items.count == Robot.bodyParts.count else { return }
        let equip = !Robot.isFullyEquippedWith(equipmentSet: equipmentSet)
        for (i, bodyPart) in Robot.bodyParts.enumerated() {
            let silent = (i > 0)
            if equip {
                machine.equip(bodyPart: bodyPart, item: equipmentSet.items[i], silent: silent)
            } else {
                machine.unequip(bodyPart: bodyPart, silent: silent)
            }
        }
    }
    
    // MARK: Equipment
    
    func showEquipmentPanel() {
        EquipmentViewController.present(from: self, within: liveViewSafeAreaGuide.layoutFrame, delegate: self)
    }
    
    func dismissEquipmentPanel() {
        if let _ = self.presentedViewController as? EquipmentViewController {
            dismiss(animated: false)
        }
    }
    
    // MARK: Recipes
    
    func presentRecipePopoverFor(forgedItem: ForgedItem, sourceView: UIView) {
        guard forgedItem.item != .undefined else { return }
        var presentationSourceView = sourceView
        var arrowDirections: UIPopoverArrowDirection = [.any]
        if let _ = sourceView as? ThingView {
            // If the source view is a ThingView then it’s on one of the ingredients panels
            // so make sure to use the currently visible one.
            if let thingViewAndPosition = getThingViewAndPosition(for: forgedItem.item) {
                presentationSourceView = thingViewAndPosition.0
                arrowDirections = getPopoverArrowDirections(for: thingViewAndPosition.0)
            }
        } else if let _ = sourceView as? ConveyorCollectionViewCell {
            arrowDirections = [.down]
        }
 
        RecipeViewController.presentRecipe(for: forgedItem, from: self, sourceView: presentationSourceView, arrowDirections: arrowDirections)
    }
    
    func dismissRecipePopover() {
        if let _ = self.presentedViewController as? RecipeViewController {
            dismiss(animated: false)
        }
    }
    
    // MARK: Celebration Dance
    
    func playCelebrationDance(completion: (() -> Void)? = nil) {
        
        let overlayView = SpotlightOverlayView(frame: view.bounds)
        overlayView.machineFrame = machineOuterContainerView.superview?.convert(machineOuterContainerView.frame, to: view)
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
        danceOverlayView = overlayView
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapDanceOverlay(_:)))
        overlayView.addGestureRecognizer(tapGesture)
        
        machine.dance(overlayView: overlayView, completion: {

            self.clearUpAfterCelebrationDance()

            // Slight delay before notifying completion.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {

                // Notify user process that celebration dance has been completed.
                CodeMachineUserCodeProxy.shared.celebrationDanceCompleted()
//                if let proxy = PlaygroundPage.current.liveView as? PlaygroundLiveViewMessageHandler {
//                    proxy.send(PlaygroundMessageFromLiveView.celebrationDanceCompleted.playgroundValue)
//                }

                completion?()
            })
        })
    }
    
    func clearUpAfterCelebrationDance() {
        danceOverlayView?.removeFromSuperview()
        danceOverlayView = nil
        
        // Resume machine idle events and vibration.
        self.machine.startIdleEvents(after: 2.0)
        if !self.isReduceMotionEnabled {
            self.machine.startIdlingVibration()
        }
    }
    
    func cancelCelebrationDance() {
        guard let _ = danceOverlayView else { return }
        machine.cancelDance()
        clearUpAfterCelebrationDance()
    }
    
    // MARK: Actions
    
    @IBAction func didTapLeftBarButton(_ sender: Any) {
        showEquipmentPanel()
    }
    
    @IBAction func didTapRightBarButton(_ sender: Any) {
    }
    
    @objc
    func didDoubleTapMachine(_ gesture: UITapGestureRecognizer) {
        guard Robot.isFullyEquipped else { return }
        playCelebrationDance()
    }
    
    @objc
    func didTapDanceOverlay(_ gesture: UITapGestureRecognizer) {
        cancelCelebrationDance()
    }
}

// MARK: - StateMachineDelegate
extension FoundryViewController: StateMachineDelegate {
    
    func itemDidChange(stateMachine:IngredientStateMachine, itemA: Thing?, itemB: Thing?) {
        if let itemA = itemA {
            if let thingViewAndPosition = getThingViewAndPosition(for: itemA) {
                thingViewAndPosition.0.isHighlighted = true
            }
        }
        else if let itemB = itemB {
            if let thingViewAndPosition = getThingViewAndPosition(for: itemB) {
                thingViewAndPosition.0.isHighlighted = true
            }
        }
    }
    
    func lightsDidChange(stateMachine: IngredientStateMachine, lightState: LightsState) {
        if lightState.red {
            machine.setLight(.red, on: true)
        } else if lightState.green {
            machine.setLight(.green, on: true)
        } else if lightState.blue {
            machine.setLight(.blue, on: true)
        }
    }
    
    func didForgeItems(stateMachine: IngredientStateMachine, itemA: Thing, itemB: Thing, forgedItem: ForgedItem) {
        guard forgedItem.item != .undefined else { return }

        // Mark the item as forged by storing its recipe.
        forgedItem.item.setRecipe(forgedItem.recipe)
        
        // Initiate the forging sequence.
        animateForgeCycle(forgedItem: forgedItem, speed: forgingSpeed, completion: {
            self.finishForgeCycle(forgedItem: forgedItem)
        })
    }
}

// MARK: - ItemsViewControllerDelegate
extension FoundryViewController: ItemsViewControllerDelegate {
    
    func didSelectItem(itemsViewController: ItemsViewController, thingView: ThingView, item: Thing) {
        var recipe = Recipe.undefined
        if let itemRecipe = thingView.item.recipe {
            recipe = itemRecipe
        }
        let forgedItem = ForgedItem(item: thingView.item, recipe: recipe)
        presentRecipePopoverFor(forgedItem: forgedItem, sourceView: thingView)
    }
}

// MARK: - ConveyorBeltViewControllerDelegate
extension FoundryViewController: ConveyorBeltViewControllerDelegate {
    
    func didSelectItem(conveyorBeltViewController: ConveyorBeltViewController, forgedItem: ForgedItem, cell: ConveyorCollectionViewCell) {
        presentRecipePopoverFor(forgedItem: forgedItem, sourceView: cell)
    }
}

// MARK: - EquipmentViewControllerDelegate
extension FoundryViewController: EquipmentViewControllerDelegate {

    func didChooseToEquip(equipmentViewController: EquipmentViewController, with item: Thing) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            self.equipOrUnequip(item: item)
        })
    }
    
    func didChooseToEquip(equipmentViewController: EquipmentViewController, with equipmentSet: EquipmentSet) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            self.equipOrUnequip(equipmentSet: equipmentSet)
        })
    }
    
    func didChooseDance(equipmentViewController: EquipmentViewController) {
        self.playCelebrationDance()
    }
}

// MARK: - AudioPlaybackDelegate
extension FoundryViewController: AudioPlaybackDelegate {
    
    public func audioSession(_ session: AudioSession, isPlaybackBlocked: Bool) {
        
        if isPlaybackBlocked {
            // Pause background audio if the audio session is blocked, for example, by the app going into the background.
            audioController.pauseBackgroundAudioLoop()
            audioController.stopAllPlayersExceptBackgroundAudio()
        } else {
            // Resume if audio session is unblocked, assuming audio is enabled.
            if audioController.isBackgroundAudioEnabled {
                audioController.resumeBackgroundAudioLoop()
            }
        }
    }
}

// MARK: - LiveViewExtensionHostDelegate
extension FoundryViewController: LiveViewExtensionHostDelegate {
    
    func liveViewExtensionHostDidEnterBackground() {
        // The live view extension is going into the background.
        isPausedWhileExtensionInBackground = true
        
        // Pause idle events.
        machine.stopIdleEvents()
        
        // Pause machine idle animation.
        machine.stopIdlingVibration()
    }
    
    func liveViewExtensionHostWillEnterForeground() {
        // The live view extension is about to enter the foreground.
        
        if isPausedWhileExtensionInBackground {
            // If the live view has been paused by the extension going into the background,
            // notify the user process of any deferred forged item so as to resume processing:
            // it may be waiting in a run loop in forgeItems().
            if let forgedItem = deferredForgedItem {
                deferredForgedItem = nil
            
                DispatchQueue.main.async {
                    // Note: notifyUserProcessOfCompletedForgeCycle will resume idle events.
                    self.notifyUserProcessOfCompletedForgeCycle(forgedItem: forgedItem)
                }
            } else {
                // Resume idle events.
                machine.startIdleEvents(after: 2.0)
            }
            
            // Resume machine idle animation.
            if !isReduceMotionEnabled {
                machine.startIdlingVibration()
            }
        }
        
        isPausedWhileExtensionInBackground = false
    }
}

// MARK: - LiveViewLifeCycleProtocol
extension FoundryViewController: LiveViewLifeCycleProtocol {

    public func liveViewMessageConnectionOpened() {
        PBLog("")
        cancelCelebrationDance()
        stateMachine.reset()
        clearConveyorBelt()
        forgeCycleCount = 0

        // Set the forging speed based on the page’s current `executionMode`.
        forgingSpeed = .normal
        switch PlaygroundPage.current.executionMode {
        case .runFaster, .runFastest:
            forgingSpeed = .fast
        default:
            break
        }
    }
    
    public func liveViewMessageConnectionClosed() {}
}

// MARK: - CodeMachineLiveViewRepresentable
extension FoundryViewController: CodeMachineLiveViewRepresentable {
    public func setItemA(item: Thing) {
        stateMachine.itemA = item
    }
    
    public func setItemB(item: Thing) {
        stateMachine.itemB = item
    }
    
    public func forgeItems() {
        startForgeCycle()
    }
    
    public func switchLight(light: Light, onOff: SwitchState) {
        switch light {
        case .red:
            stateMachine.lights.red = onOff != off
        case .green:
            stateMachine.lights.green = onOff != off
        case .blue:
            stateMachine.lights.blue = onOff != off
        }
    }
    
    public func setSpeed(speed: Speed) {
        forgingSpeed = speed
    }
    
    public func reset() {
        resetAll()
    }
    
    public func enableEquipAlerts(enabled: Bool, autoEquip: Bool) {
        isEquipAlertsEnabled = enabled
        isAutoEquipEnabled = autoEquip
    }
    
    public func playMachineSound(sound: SoundFX) {
        audioPlayerQueue.async {
            let volume = 80
            if let url = sound.url {
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.volume = Float(max(min(volume, 100), 0)) / 100.0
                    audioController.register(audioPlayer)
                    audioPlayer.play()
                } catch {}
            }
        }
    }
    
    public func enableAutoPlayCelebrationDance(enabled: Bool) {
        autoPlayCelebrationDanceWhenFullyEquipped = enabled
    }
    

}
