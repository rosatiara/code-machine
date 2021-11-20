//
//  SLOTAnimationView.swift
//
// The source code contained in this file originated from 'lottie-ios' has been modified by Apple. The original source code is licensed under the Apache 2.0 license, available here:
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// and the original source code for 'lottie-ios' is available for download here:
//
//      https://github.com/airbnb/lottie-ios
//
// Modifications made by Apple are licensed under the Swift Playgrounds Software License, located at the root of this playground document.
//
// Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

typealias SLOTAnimationCompletionHandler = (_ animationFinished: Bool) -> Void
let kCompContainerAnimationKey = "play"

public class SLOTAnimationView : UIView, CAAnimationDelegate {
    
    var animationSpeed = 1
    var animationProgress = 0.0
    var autoReverseAnimation = false
    var playRangeEndFrame : Double?
    var playRangeStartFrame : Double?
    var playRangeEndProgress = 0
    var playRangeStartProgress = 0
    var isAnimationPlaying = false
    var completionHandler: SLOTAnimationCompletionHandler?
    
    var animationDuration: Double {
        guard let compContainer = compContainer else { return 0.0 }
        if let play = compContainer.animation(forKey: kCompContainerAnimationKey) {
            return play.duration
        }
        guard let startFrame = sceneModel.startFrame, let endFrame = sceneModel.endFrame, let frameRate = sceneModel.frameRate, frameRate != 0.0 else { return 0.0}
        return (endFrame - startFrame) / frameRate
    }
    
    var loopAnimation = false {
        didSet {
            if isAnimationPlaying {
                let frame = compContainer!.presentation()!.currentFrame
                setProgress(frame: frame, callCompletion: false)
                play(startFrame: playRangeStartFrame!, endFrame: playRangeEndFrame!, completion: completionHandler)
            }
        }
    }
    
    var sceneModel : SLOTComposition {
        // Ignoring teardown for now
        didSet {
            setupWithSceneModel(model: sceneModel)
        }
    }
    
    var isSpeedNegative: Bool {
        return animationSpeed >= 0
    }
    
    private var compContainer : SLOTCompositionContainer?
    
    convenience init?(name: String) {
        if let composition = SLOTComposition.init(animationName: name) {
            self.init(model: composition)
        }
        else {
            return nil
        }
    }
    
    convenience init?(filePath: URL) {
        guard filePath.isFileURL else { return nil }

        if let composition = SLOTComposition.init(filePath: filePath) {
            self.init(model: composition)
        }
        else {
            return nil
        }
    }

    init(model: SLOTComposition) {
        sceneModel = model
        super.init(frame: model.bounds)
        setupWithSceneModel(model: sceneModel)
        self.clipsToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWithSceneModel(model: SLOTComposition) {
        compContainer = SLOTCompositionContainer.init(model: nil, inLayerGroup: nil, withLayerGroup: sceneModel.layerGroup, withAssetGroup: sceneModel.assetGroup)
        self.layer.addSublayer(compContainer!)
        #if ENABLE_DEBUG_LOGGING
            logHierarchyKeypaths()
        #endif
        restoreState()
        self.setNeedsLayout()
    }
    
    func restoreState() {
        setProgress(frame: frame(progress: animationProgress), callCompletion: true)
    }

    func play() {
        play(startFrame: sceneModel.startFrame!, endFrame: sceneModel.endFrame!, completion: nil)
        
    }
    
    private func play(startFrame: Double, endFrame: Double, completion: SLOTAnimationCompletionHandler?) {
        if isAnimationPlaying {
            return
        }
        
        playRangeStartFrame = startFrame
        playRangeEndFrame = endFrame
        
        if completion != nil {
            completionHandler = completion
        }
        
        var currentFrame = frame(progress: animationProgress)
        
        currentFrame = max(min(currentFrame, endFrame), startFrame)
        let playingForward = isSpeedNegative
        if currentFrame == endFrame && playingForward {
            currentFrame = startFrame
        } else if currentFrame == startFrame && !playingForward {
            currentFrame = endFrame
        }
        animationProgress = progress(frame: currentFrame)
        
        let sceneModelEndFrame = sceneModel.endFrame!
        let sceneModelStartFrame = sceneModel.startFrame!
        let sceneModelFramerate = sceneModel.frameRate!
        
        let offset = max(0.0, (animationProgress * (sceneModelEndFrame - sceneModelStartFrame)) - startFrame) / sceneModelFramerate
        let duration = (endFrame - startFrame) / sceneModelFramerate
        
        let animation = CABasicAnimation(keyPath: "currentFrame")
        animation.speed = Float(animationSpeed)
        animation.fromValue = startFrame
        animation.toValue = endFrame
        animation.duration = duration
        animation.fillMode = .both
        animation.repeatCount = loopAnimation ? Float.infinity : 1
        animation.autoreverses = autoReverseAnimation
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        if offset != 0 {
            animation.beginTime = CACurrentMediaTime() - offset
        }
        compContainer?.add(animation, forKey: kCompContainerAnimationKey)
        isAnimationPlaying = true
    }
    
    func play(startProgress: Double, endProgress: Double, completion: SLOTAnimationCompletionHandler?) {
        play(startFrame: frame(progress: startProgress), endFrame: frame(progress: endProgress), completion: completion)
    }
    
    func play(startTime: Double, endTime: Double, completion: SLOTAnimationCompletionHandler?) {
        play(startFrame: frame(time: startTime), endFrame: frame(time: endTime), completion: completion)
    }
    
    func stop() {
        isAnimationPlaying = false
        let startFrame = sceneModel.startFrame!
        setProgress(frame: startFrame, callCompletion: true)
    }
    
    func setLayerEnabled(_ enabled: Bool, forKeypath keyPath: String) {
        guard let compContainer = compContainer else { return }
        if let layer = compContainer.layerWith(keyPath: keyPath) {
            layer.isEnabled = enabled
            layer.setNeedsDisplay()
        }
    }
    
    func setSublayersOfLayerEnabled(_ enabled: Bool, forKeypath keyPath: String) {
        guard let compContainer = compContainer else { return }
        if let sublayers = compContainer.sublayersOfLayerWith(keyPath: keyPath) {
            for sublayer in sublayers {
                sublayer.isEnabled = enabled
                sublayer.setNeedsDisplay()
            }
        }
    }
    
    func isLayerEnabled(_ keyPath: String) -> Bool {
        guard let compContainer = compContainer,
            let layer = compContainer.layerWith(keyPath: keyPath) else { return false }
        return layer.isEnabled
    }
    
    func getMissingLayersIn(keyPaths: [String]) -> [String]? {
        guard let compContainer = compContainer else { return nil }
        var missingLayersKeyPaths = [String]()
        for keyPath in keyPaths {
            guard let _ = compContainer.layerWith(keyPath: keyPath) else {
                missingLayersKeyPaths.append(keyPath)
                continue
            }
        }
        return missingLayersKeyPaths.isEmpty ? nil : missingLayersKeyPaths
    }
    
    private func setProgress(frame: Double, callCompletion: Bool) {
        removeCurrentAnimationIfNecessary()
        
        animationProgress = progress(frame: frame)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        compContainer?.currentFrame = frame
        compContainer?.setNeedsDisplay()
        CATransaction.commit()
        if callCompletion {
            callCompletionIfNecessary(complete: false)
        }
    }
    
    private func callCompletionIfNecessary(complete: Bool) {
        if let completion = completionHandler {
            completionHandler = nil
            completion(complete)
        }
    }
    
    private func removeCurrentAnimationIfNecessary() {
        isAnimationPlaying = false
        compContainer?.removeAllAnimations()
    }
    
    private func frame(progress: Double) -> Double {
        guard let startFrame = sceneModel.startFrame, let endFrame = sceneModel.endFrame else { return 0.0}
        let newProgress = progress
        return ((endFrame - startFrame) * newProgress) + startFrame
    }
    
    private func progress(frame: Double) -> Double {
        guard let startFrame = sceneModel.startFrame, let endFrame = sceneModel.endFrame else { return 0.0}
        return (frame - startFrame) / (endFrame - startFrame)
    }
    
    private func frame(time: Double) -> Double {
        guard let startFrame = sceneModel.startFrame, let endFrame = sceneModel.endFrame, let frameRate = sceneModel.frameRate, frameRate != 0.0 else { return 0.0}
        let frame = time * frameRate
        return min(max(startFrame, frame), endFrame)
    }
    
    private func time(frame: Double) -> Double {
        guard let startFrame = sceneModel.startFrame, let endFrame = sceneModel.endFrame, let frameRate = sceneModel.frameRate, frameRate != 0.0 else { return 0.0}
        let totalFrames = (endFrame - startFrame) / frameRate
        return (frame / totalFrames) * totalFrames
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            callCompletionIfNecessary(complete: false)
        }
    }
    
    public override var contentMode: UIView.ContentMode {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _layout()
    }    
    
    // Using underscore to follow convention with ObjC version (believe 'layout' conflicts with macOS target)
    // Not using macros, just UIViewContentMode enums
    private func _layout() {
        let compBounds = sceneModel.bounds
        let centerPoint = SLOT_RectGetCenterPoint(bounds)
        let xform: CATransform3D
        
        switch contentMode {
        case .scaleToFill:
            let scaleSize = CGSize(width: bounds.width / compBounds.width, height: bounds.height / compBounds.height)
            xform = CATransform3DMakeScale(scaleSize.width, scaleSize.height, 1)
        case .scaleAspectFit:
            let compAspect = compBounds.width / compBounds.height
            let viewAspect = bounds.width / bounds.height
            let scaleWidth = compAspect > viewAspect
            let dominantDimension = scaleWidth ? bounds.width : bounds.height
            let compDimension = scaleWidth ? compBounds.width : compBounds.height
            let scale = dominantDimension / compDimension
            xform = CATransform3DMakeScale(scale, scale, 1)
        case .scaleAspectFill:
            let compAspect = compBounds.width / compBounds.height
            let viewAspect = bounds.width / bounds.height
            let scaleWidth = compAspect < viewAspect
            let dominantDimension = scaleWidth ? bounds.width : bounds.height
            let compDimension = scaleWidth ? compBounds.width : compBounds.height
            let scale = dominantDimension / compDimension
            xform = CATransform3DMakeScale(scale, scale, 1)
        default:
            xform = CATransform3DIdentity
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        compContainer?.transform = CATransform3DIdentity
        compContainer?.bounds = compBounds
        compContainer?.transform = xform
        compContainer?.position = centerPoint
        CATransaction.commit()
    }
    
    // MARK: CAAnimationDelegate
    
    public func animationDidStop(_ anim: CAAnimation, finished complete: Bool) {
        guard compContainer?.animation(forKey: kCompContainerAnimationKey) == anim, let playAnimation = anim as? CABasicAnimation else { return }
        
        var frame = compContainer?.presentation()?.currentFrame ?? 0.0
        
        if complete {
            frame = isSpeedNegative ? playAnimation.toValue as! Double : playAnimation.fromValue as! Double
        }
        
        removeCurrentAnimationIfNecessary()
        setProgress(frame: frame, callCompletion: complete)
    }
    
    func logHierarchyKeypaths() {
        compContainer?.logHierarchyKeypaths(withParent: nil)
    }
    
}
