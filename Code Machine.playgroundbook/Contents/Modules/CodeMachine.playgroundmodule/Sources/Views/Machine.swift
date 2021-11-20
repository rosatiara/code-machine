//
//  Machine.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit
import SPCAudio
import SPCCore

class Machine: UIView {
    
    private let lightsLayerName = "robotLights"
    private var animationView: SLOTAnimationView?
    private var isIdleEventsEnabled = false
    private var idleTimer: Timer?
    private var particleEmitterLayer: CAEmitterLayer?
    
    private var danceAnimator: UIViewPropertyAnimator?
    
    let celebrationDanceScale: CGFloat = 0.6
    var danceCanceled = false
    
    // MARK: Positions of components
    
    private let normalizedMachineFrame = CGRect(x: 0.16, y: 0.09, width: 0.53, height: 0.56)
    private let normalizedFunnelFrame = CGRect(x: 0.15, y: 0.08, width: 0.17, height: 0.15)
    private let normalizedChuteFrame = CGRect(x: 0.28, y: 0.34, width: 0.08, height: 0.22)
    private let normalizedRedLightFrame = CGRect(x: 0.47, y: 0.39, width: 0.05, height: 0.05)
    private let normalizedGreenLightFrame = CGRect(x: 0.53, y: 0.39, width: 0.05, height: 0.05)
    private let normalizedBlueLightFrame = CGRect(x: 0.60, y: 0.38, width: 0.05, height: 0.05)
    private let normalizedEyesFrame = CGRect(x: 0.45, y: 0.31, width: 0.19, height: 0.07)
    private let normalizedMouthFrame = CGRect(x: 0.49, y: 0.48, width: 0.19, height: 0.07)

    var normalizedInputPosition: CGPoint { return CGPoint(x: normalizedFunnelFrame.midX, y: normalizedFunnelFrame.midY) }
    var normalizedOutputPosition: CGPoint { return CGPoint(x: normalizedChuteFrame.midX, y: normalizedChuteFrame.midY) }
        
    private func normalizedEquipFrame(for bodyPart: BodyPart) -> CGRect {
        switch bodyPart {
        case .face:
            return CGRect(x: 0.43, y: 0.29, width: 0.22, height: 0.09)
        case .head:
            return CGRect(x: 0.37, y: 0.16, width: 0.27, height: 0.09)
        case .torso:
            return CGRect(x: 0.36, y: 0.45, width: 0.33, height: 0.14)
        case .appendage1:
            return CGRect(x: 0.15, y: 0.27, width: 0.23, height: 0.21)
        case .appendage2:
            return CGRect(x: 0.66, y: 0.27, width: 0.23, height: 0.21)
        case .feet:
            return CGRect(x: 0.43, y: 0.62, width: 0.27, height: 0.14)
        }
    }
    
    // MARK: Animations sequences
    
    private enum AnimationSequence {
        case forge, popOutForgedItem, eyesBlink, mouthAnimate
    }
    
    private func timeRangeFor(sequence: AnimationSequence) -> (Double, Double) {
        switch sequence {
        case .forge:
            return (0.0, 2.5)
        case .popOutForgedItem:
            return (3.75, 4.25)
        case .eyesBlink:
            return (5.30, 7.30)
        case .mouthAnimate:
            return (8.00, 10.00)
        }
    }
    
    // MARK: Layers
    
    private var allExpectedLayerKeyPaths: [String] {
        var keyPaths = [String]()
        for bodyPart in Robot.bodyParts {
            keyPaths.append(bodyPart.rawValue)
            for item in bodyPart.possibleFinalProducts {
                keyPaths.append("\(bodyPart.rawValue).\(item.rawValue)")
            }
        }
        keyPaths.append(lightsLayerName)
        keyPaths.append("\(lightsLayerName).\(layerNameFor(color: nil))")
        keyPaths.append("\(lightsLayerName).\(layerNameFor(color: .red))")
        keyPaths.append("\(lightsLayerName).\(layerNameFor(color: .blue))")
        keyPaths.append("\(lightsLayerName).\(layerNameFor(color: .green))")
        return keyPaths
    }

    // MARK: Initialization and loading

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        backgroundColor = .clear
        isAccessibilityElement = false
    }
    
    func load() {
        guard let base = Bundle.main.url(forResource: "Animations", withExtension: nil) else {
            fatalError("Animations folder not found in resources.")
        }
        
        let animationBase = base.appendingPathComponent("robotv17/data.json")
        guard let animationView = SLOTAnimationView(filePath: animationBase) else {
            fatalError("Unable to load animation")
        }
        
        animationView.frame = bounds
        animationView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = false
        addSubview(animationView)
        self.animationView = animationView
        
        // Check for any missing layers.
        if let missingLayersKeyPaths = animationView.getMissingLayersIn(keyPaths: allExpectedLayerKeyPaths) {
            for keyPath in missingLayersKeyPaths {
                PBLog("Missing layer: \(keyPath)")
            }
        }
        
        unequipAll()
        setLightsOff()
        
        // Force mouth animation image layers to load.
        animationView.setSublayersOfLayerEnabled(true, forKeypath: "robotMouth.robotMouthAnimation")
    }
    
    func restoreState() {
        guard let animationView = animationView else { return }
        animationView.restoreState()
    }
    
    // MARK: Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        particleEmitterLayer?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        axElements.removeAll()
    }
    
    // MARK: Animation
    
    func reveal(reduceMotion: Bool) {
        playSoundFX(.machineAppearingSound)
        transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        alpha = 0.3
        let duration = reduceMotion ? 0.0 : 0.75
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        self.alpha = 1.0
                        self.transform = CGAffineTransform.identity
        }, completion: { _ in
            self.startIdlingSound()
            if !reduceMotion {
                self.startIdlingVibration()
            }
            self.startIdleEvents()
        })
    }
    
    func blink(completion: (() -> Void)? = nil) {
        play(sequence: .eyesBlink, completion: {
            completion?()
        })
    }
    
    func vocalize(completion: (() -> Void)? = nil) {
        playSoundFX(.idlingVocalization, volume: 5)
        play(sequence: .mouthAnimate, completion: {
            completion?()
        })
    }
    
    private func play(sequence: AnimationSequence, speed: Int = 1, completion: (() -> Void)? = nil) {
        guard let animationView = animationView else { return }
        animationView.animationSpeed = speed
        let timeRange = timeRangeFor(sequence: sequence)
        animationView.play(startTime: timeRange.0, endTime: timeRange.1, completion: { _ in
            completion?()
        })
    }
    
    private func stopAnimation() {
        guard let animationView = animationView, animationView.isAnimationPlaying else { return }
        animationView.stop()
    }
    
    // MARK: Particle Effects
    
    private func getEmitterLayer() -> CAEmitterLayer {
        if particleEmitterLayer == nil {
            let emitterLayer = CAEmitterLayer()
            emitterLayer.emitterShape = .point
            emitterLayer.emitterSize = CGSize(width: 1, height: 1)
            
            let cellA = makeEmitterCell(color: #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1), item: .spring, name: "Cell1")
            let cellB = makeEmitterCell(color: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), item: .gear, name: "Cell2")
            let cellC = makeEmitterCell(color: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), item: .wire, name: "Cell3")
            emitterLayer.emitterCells = [cellA, cellB, cellC]
            
            superview?.layer.insertSublayer(emitterLayer, at: 0)
            particleEmitterLayer = emitterLayer
        }
        return particleEmitterLayer!
    }
    
    func startParticleEffects() {
        guard let emitterCells = getEmitterLayer().emitterCells else { return }
        emitterCells.forEach { $0.birthRate = 3 }
        let emitterLayer = getEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitterLayer.birthRate = 1.0
        emitterLayer.removeAllAnimations()
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.0
        fadeAnimation.toValue = 1.0
        fadeAnimation.duration = 0.5
        emitterLayer.opacity = 1.0
        emitterLayer.add(fadeAnimation, forKey: "emitterLayerFadeIn")
    }
    
    func stopParticleEffects() {
        let emitterLayer = getEmitterLayer()
        emitterLayer.birthRate = 0
        emitterLayer.removeAllAnimations()
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = emitterLayer.opacity
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 0.5
        emitterLayer.opacity = 0.0
        emitterLayer.add(fadeAnimation, forKey: "emitterLayerFadeOut")
    }
    
    private func makeEmitterCell(color: UIColor, item: Thing, name: String) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = name
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 60
        cell.velocityRange = 25
        cell.emissionLongitude = -CGFloat.pi / 2
        cell.emissionRange = CGFloat.pi / 2
        cell.spin = 2
        cell.spinRange = 3
        cell.scale = 0.5
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        cell.contents = UIImage(named: "Spark")?.cgImage
        let iconsPath = "ItemIcons/Gray/Small"
        if let iconsURL = Bundle.main.url(forResource: iconsPath, withExtension: nil) {
            let iconURL = iconsURL.appendingPathComponent("\(item.rawValue).png")
            if let image = UIImage(contentsOfFile: iconURL.path) {
                cell.contents = image.cgImage
            }
        }
        return cell
    }
    
    // MARK: Idling
    
    func startIdlingSound() {
        audioController.playBackgroundAudioLoop(SoundFX.idling.resourcePath, volume: 15)
    }
    
    func startIdlingVibration() {
        jiggle(enabled: true)
    }
    
    func stopIdlingVibration() {
        jiggle(enabled: false)
    }
    
    // MARK: Idle events
    
    func startIdleEvents(after timeInterval: Double? = nil) {
        isIdleEventsEnabled = true
        scheduleNextIdleEvent(after: timeInterval)
    }
    
    func stopIdleEvents() {
        isIdleEventsEnabled = false
        guard let idleTimer = idleTimer else { return }
        idleTimer.invalidate()
        self.idleTimer = nil
    }

    private func scheduleNextIdleEvent(after timeInterval: Double? = nil) {
        guard isIdleEventsEnabled else { return }
        idleTimer?.invalidate()
        self.idleTimer = nil
        var interval = Double(Float.random(from: 3.0, to: 6.0))
        if let specifiedTimeInterval = timeInterval {
            interval = specifiedTimeInterval
        }
        idleTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { timer in
            self.doIdleEvent()
        })
    }
    
    private func doIdleEvent() {
        guard let idleTimer = idleTimer else { return }
        idleTimer.invalidate()
        self.idleTimer = nil
        
        let completion = {
            self.scheduleNextIdleEvent()
        }
        
        // Action the event and schedule the next one.
        if Int.random(from: 0, to: 5) < 3 {
            blink(completion: completion)
        } else {
            vocalize(completion: completion)
        }
    }
    
    // MARK: Forging
    
    func forge(speed: Speed = .normal, reduceMotion: Bool, completion: (() -> Void)? = nil) {
        // Stop any currently running idle animation.
        stopAnimation()
        // Get that machine movin’.
        if !reduceMotion {
            wobbleAndShake(speed: speed)
        }
        // Play the forging sound.
        playSoundFX( speed.isFast ? .fastForgingSound : .forgingSound)
        // Play the forging animation.
        play(sequence: .forge, speed: speed.isFast ? 4 : 1, completion: {
            completion?()
        })
    }
    
    func popOutForgedItem(speed: Speed = .normal, completion: (() -> Void)? = nil) {
        // Stop any currently running idle animation.
        stopAnimation()
        // Play the popping out sound.
        if speed.isNormal {
            playSoundFX(.poppingOut)
        }
        // Play the chute animation.
        play(sequence: .popOutForgedItem, speed: speed.isFast ? 4 : 2, completion: {
            completion?()
        })
    }
    
    func stopForging() {
        guard let animationView = animationView else { return }
        animationView.stop()
        focusAXElement.isAccessibilityElement = false
    }
    
    // MARK: Lights
    
    private func layerNameFor(color: Light?) -> String {
        guard let color = color else { return "lightsOff" }
        switch color {
        case .red:
            return "redLightOn"
        case .blue:
            return "blueLightOn"
        case .green:
            return "greenLightOn"
        }
    }
    
    private func isLightOn(_ light: Light) -> Bool {
        guard let animationView = animationView else { return false }
        return animationView.isLayerEnabled("\(lightsLayerName).\(layerNameFor(color: light))")
    }
    
    private func stateOf(light: Light) -> String {
        return isLightOn(light) ?
            NSLocalizedString("On", comment: "AX label light state on") :
            NSLocalizedString("Off", comment: "AX label light state off")
    }
    
    func setLight(_ light: Light, on: Bool) {
        guard let animationView = animationView else { return }
        setLightsOff()
        animationView.setLayerEnabled(on, forKeypath: "\(lightsLayerName).\(layerNameFor(color: light))")
    }
    
    func setLightsOff() {
        guard let animationView = animationView else { return }
        animationView.setSublayersOfLayerEnabled(false, forKeypath: lightsLayerName)
        animationView.setLayerEnabled(true, forKeypath: "\(lightsLayerName).\(layerNameFor(color: nil))")
    }
    
    // MARK: Equipping
    
    func equipOrUnequip(bodyPart: BodyPart, item: Thing, silent: Bool = false) {
        if Robot.equippedItems.contains(item) {
            unequip(bodyPart: bodyPart, silent: silent)
        } else {
            equip(bodyPart: bodyPart, item: item, silent: silent)
        }
    }
    
    func equip(bodyPart: BodyPart, item: Thing, silent: Bool = false) {
        guard let animationView = animationView,
            bodyPart.possibleFinalProducts.contains(item)
            else { return }

        // Hide all appendages for body part.
        animationView.setSublayersOfLayerEnabled(false, forKeypath: bodyPart.rawValue)

        // Show the appendage we want.
        let appendageKeypath = "\(bodyPart.rawValue).\(item.rawValue)"
        animationView.setLayerEnabled(true, forKeypath: appendageKeypath)
        // Enable the sublayer(s) that contain the image forcing the image to load.
        animationView.setSublayersOfLayerEnabled(true, forKeypath: appendageKeypath)
        
        bodyPart.setEquippedItem(item)
        
        if !silent {
            playSoundFX(.equippedItemSound)
        }
        
        if UIAccessibility.isVoiceOverRunning {
            let notification = String(format: NSLocalizedString("Equipped %1$@ onto %2$@", comment: "AX notification for equipped item onto body part"),
                                      item.name, bodyPart.name)
            UIAccessibility.post(notification: .announcement, argument: notification)
        }
        axElements.removeAll()
    }
    
    func unequip(bodyPart: BodyPart, silent: Bool = false) {
        guard let animationView = animationView else { return }
        
        // Hide any currently equipped item.
        if let equippedItem = bodyPart.equippedItem {
            let appendageKeypath = "\(bodyPart.rawValue).\(equippedItem.rawValue)"
            animationView.setLayerEnabled(false, forKeypath: appendageKeypath)
            // Disable the sublayer(s) that contain the image forcing any image to unload.
            animationView.setSublayersOfLayerEnabled(false, forKeypath: appendageKeypath)
        }
        
        // Hide all appendages for body part.
        animationView.setSublayersOfLayerEnabled(false, forKeypath: bodyPart.rawValue)
        bodyPart.setEquippedItem(nil)
        
        if !silent {
            playSoundFX(.removedItemSound)
        }
        
        if UIAccessibility.isVoiceOverRunning {
            let notification = String(format: NSLocalizedString("Unequipped %@", comment: "AX notification for unequipped body part"),
                                      bodyPart.name)
            UIAccessibility.post(notification: .announcement, argument: notification)
        }
        axElements.removeAll()
    }
    
    func unequipAll() {
        guard let animationView = animationView else { return }
        for bodyPart in Robot.bodyParts {
            animationView.setSublayersOfLayerEnabled(false, forKeypath: bodyPart.rawValue)
        }
        axElements.removeAll()
    }
    
    // MARK: Celebration
    
    func dance(overlayView: UIView, completion: @escaping (() -> Void)) {
        
        let duration = 7.5
        let rotationRadians = 10 / 180.0 * CGFloat.pi
        
        let danceMoves = 7
        let increments = (danceMoves * 2) + 2 + 1
        let dt = 1.0 / Double(increments)
        
        danceCanceled = false
        
        playSoundFX(.idleVocal2)
        
        // Pause idle events and vibration.
        stopIdleEvents()
        stopIdlingVibration()
        
        // Start the music and particle effects.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            guard !self.danceCanceled else { return }
            self.startParticleEffects()
            playSoundFX(.celebration)
        })
        
        // Create a dance animator to orchestrate the key frame animation.
        danceAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: {
                
            UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: .calculationModeLinear,
                                    animations: {
                                        var startTime = 0.0
                                        
                                        // Scale down machine.
                                        UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt) {
                                            self.transform = self.transform.scaledBy(x: self.celebrationDanceScale, y: self.celebrationDanceScale)
                                            overlayView.alpha = 1.0
                                        }
                                        startTime += dt
                                        
                                        // Initial rotation.
                                        UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt / 2) {
                                            self.transform = self.transform.rotated(by: -rotationRadians / 2)
                                        }
                                        startTime += dt / 2
                                        
                                        // Dance moves.
                                        for _ in 0..<danceMoves {
                                            UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt) {
                                                self.transform = self.transform.rotated(by: rotationRadians)
                                            }
                                            startTime += dt
                                            UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt) {
                                                self.transform = self.transform.rotated(by: -rotationRadians)
                                            }
                                            startTime += dt
                                        }
                                        
                                        // Restore original rotation.
                                        UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt / 2) {
                                            self.transform = self.transform.rotated(by: +rotationRadians / 2)
                                        }
                                        startTime += dt / 2
                                        
                                        // Restore original scale.
                                        UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: dt) {
                                            self.transform = self.transform.scaledBy(x: 1.0 / self.celebrationDanceScale, y: 1.0 / self.celebrationDanceScale)
                                            // Fade overlayView to the minimum alpha value that still qualifies for hit testing.
                                            // Otherwise overlayView does not respond to touch events during the entire animation.
                                            overlayView.alpha = 0.015
                                        }
            })
        })
        
        danceAnimator?.addCompletion({ animationPosition in
            self.stopParticleEffects()
            completion()
        })
        
        // Start the dance animation.
        danceAnimator?.startAnimation()
    }
    
    func cancelDance() {
        danceCanceled = true
        audioController.stopAllPlayersExceptBackgroundAudio()
        stopParticleEffects()
        danceAnimator?.stopAnimation(false)
        danceAnimator?.finishAnimation(at: .end)
    }
    
    // MARK: Accessibility
    
    private var axElements = [UIAccessibilityElement]()
    
    private lazy var focusAXElement: UIAccessibilityElement = {
        let axElement = UIAccessibilityElement(accessibilityContainer: self)
        axElement.isAccessibilityElement = false
        axElement.accessibilityFrame = convert(frameFor(normalizedRect: normalizedMachineFrame), to: nil)
        return axElement
    }()
    
    // Returns an accessibility element that can serve as the AX focus during forging.
    func focusAXElementForForging(recipe: Recipe) -> UIAccessibilityElement {
        let label : String
        if let light = recipe.light {
            label = String(format: NSLocalizedString("Forging %1$@ and %2$@ with %3$@ light", comment: "AX notification before forging item with a light"), recipe.itemA.name, recipe.itemB.name, light.name)
        }
        else {
            label = String(format: NSLocalizedString("Forging %1$@ and %2$@", comment: "AX notification before forging item"), recipe.itemA.name, recipe.itemB.name)
        }
        focusAXElement.accessibilityLabel = label
        focusAXElement.isAccessibilityElement = true
        return focusAXElement
    }
    
    override var accessibilityElements: [Any]? {
        get {
            guard axElements.isEmpty else { return axElements }
            
            axElements.append(focusAXElement)
            
            let axElement = UIAccessibilityElement(accessibilityContainer: self)
            axElement.accessibilityLabel = NSLocalizedString("The machine", comment: "AX label machine")
            axElement.accessibilityFrame = convert(frameFor(normalizedRect: normalizedMachineFrame), to: nil)
            axElement.accessibilityIdentifier = "\(type(of: self)).theMachine"
            axElements.append(axElement)
            
            let describeMachineAction = UIAccessibilityCustomAction(name: NSLocalizedString("Describe the machine", comment: "AX action label"), target: self, selector: #selector(describeTheMachine))
            let describeEquipmentAction = UIAccessibilityCustomAction(name: NSLocalizedString("Describe the machine’s equipment", comment: "AX action label"), target: self, selector: #selector(describeTheEquipment))
            
            axElement.accessibilityCustomActions = [describeMachineAction, describeEquipmentAction]

            return axElements
        }
        set { }
    }
    
    @objc func describeTheMachine() {
        let description = String(format:NSLocalizedString("The machine is indeed a strange thing. It has bright rainbow eyes, a funnel and chute on its right side, red, green, and blue lights for a nose, and a generally happy disposition. The number of items equipped is %d.", comment: "AX description of the machine"), Robot.bodyParts.filter({ $0.isEquipped }).count)
        UIAccessibility.post(notification: .announcement, argument: description)
    }
    
    @objc func describeTheEquipment() {
        if Robot.bodyParts.filter({ $0.isEquipped }).count < 1 {
            UIAccessibility.post(notification: .announcement, argument: NSLocalizedString("The machine currently has nothing equipped.", comment: "AX description"))
        }
        else {
            var description = ""
            for bodyPart in Robot.bodyParts {
                if let thing = bodyPart.equippedItem, bodyPart.isEquipped {
                    description += String(format:NSLocalizedString("%1$@: %2$@ - %3$@.", comment: "AX description"), bodyPart.name, thing.name, thing.accessibilityDescription)
                }
            }
            UIAccessibility.post(notification: .announcement, argument: description)
        }
    }
    
}

