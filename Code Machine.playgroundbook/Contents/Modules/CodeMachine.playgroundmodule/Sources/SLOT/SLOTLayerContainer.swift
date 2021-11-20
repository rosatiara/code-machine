//
//  SLOTLayerContainer.swift
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

class SLOTLayerContainer : CALayer {
    var wrapperLayer = CALayer()
    var layerName : String?
    @NSManaged var currentFrame: Double
    
    private var transformInterpolator: SLOTTransformInterpolator!
    private var opacityInterpolator: SLOTNumberInterpolator!
    private var inFrame: Double!
    private var outFrame: Double!
    private var contentsGroup: SLOTRenderGroup!
    private var maskLayer: SLOTMaskContainer?
    private var valueInterpolators: [String: Any]!
    
    private var imageAsset : SLOTAsset?
    
//    var viewportBounds: CGRect? {
//        didSet {
//            
//        }
//    }
    
    var isEnabled: Bool = true {
        
        didSet {
            guard let imageAsset = imageAsset else { return }
            
            // Image layer: load/unload image.
            if isEnabled {
                setImage(for: imageAsset)
            } else {
                self.wrapperLayer.contents = nil
            }
        }
    }
    
    init(model: SLOTLayer?, inLayerGroup: SLOTLayerGroup?) {
        super.init()
        
        self.addSublayer(wrapperLayer)
        self.actions = ["hidden":NSNull(), "opacity":NSNull(), "transform":NSNull()]
        wrapperLayer.actions = self.actions
        commonInit(with: model, in: inLayerGroup)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(with layer: SLOTLayer?, in layerGroup: SLOTLayerGroup?) {
        guard let layer = layer else { return }
        layerName = layer.layerName

        switch layer.layerType {
        case .SLOTLayerTypeImage, .SLOTLayerTypeSolid, .SLOTLayerTypePrecomp:
            wrapperLayer.bounds = CGRect(x: 0, y: 0, width: layer.width!, height: layer.height!)
            wrapperLayer.anchorPoint = .zero
            wrapperLayer.masksToBounds = true
        default:
            break
        }
        
        if layer.layerType == .SLOTLayerTypeImage {
            // Image layer: save asset for loading at the point when the layer is enabled.
            imageAsset = layer.imageAsset
        }
        
        inFrame = layer.inFrame
        outFrame = layer.outFrame
        transformInterpolator = SLOTTransformInterpolator.transform(for: layer)
        if layer.parentID != nil {
            var parentId = layer.parentID
            var childInterpolator = transformInterpolator
            while parentId != nil {
                let parentModel = layerGroup?.layerModel(id: parentId!)
                let interpolator = SLOTTransformInterpolator.transform(for: parentModel!)
                childInterpolator?.inputNode = interpolator
                childInterpolator = interpolator
                parentId = parentModel?.parentID
            }
        }
        opacityInterpolator = SLOTNumberInterpolator(keyframes: layer.opacity!.keyframes)
        if layer.layerType == .SLOTLayerTypeShape {
            if let shapes = layer.shapes, shapes.count > 0 {
                build(contents: shapes)
            }
        }
        
        if layer.layerType == .SLOTLayerTypeSolid {
            wrapperLayer.backgroundColor = layer.solidColor?.cgColor
        }
        
        if let masks = layer.masks, masks.count > 0 {
            maskLayer = SLOTMaskContainer(masks: masks, containerBounds: wrapperLayer.bounds)
            wrapperLayer.mask = maskLayer
        }

        //Skip to setting interpolators
        var interpolators = [String: Any]()
        interpolators["Transform.Opacity"] = opacityInterpolator
        interpolators["Transform.Anchor Point"] = transformInterpolator.anchorInterpolator
        interpolators["Transform.Scale"] = transformInterpolator.scaleInterpolator
        interpolators["Transform.Rotation"] = transformInterpolator.scaleInterpolator
        if let posXInt = transformInterpolator.positionXInterpolator, let posYInt =            transformInterpolator.positionYInterpolator {
            interpolators["Transform.X Position"] = posXInt
            interpolators["Transform.Y Position"] = posYInt
        } else if let posInt = transformInterpolator.positionInterpolator {
            interpolators["Transform.Position"] = posInt
        }
        
        valueInterpolators = interpolators
    }
    
    private func build(contents: [Any]) {
        //print("SLOTLayerContainer build(contents:) for \(layerName ?? "")")
        contentsGroup = SLOTRenderGroup(inputNode: nil, contents: contents, keyname: layerName)
        wrapperLayer.addSublayer(contentsGroup.containerLayer)
    }
    
    private func setImage(for asset: SLOTAsset) {
        guard let imageName = asset.imageName else { return }
        
        if let rootDirectory = asset.rootDirectory {
            var assetURL = rootDirectory
            if let imageDirectory = asset.imageDirectory {
                assetURL.appendPathComponent(imageDirectory)
            }
            assetURL.appendPathComponent(imageName) 
            
            loadImageAsync(.path(assetURL.path))
        }
        else {
            loadImageAsync(.name(imageName))
        }
    }
    
    private enum ImageLoad {
        case path(String)
        case name(String)
    }
    
    private func loadImageAsync(_ load: ImageLoad) {
        DispatchQueue.global(qos: .background).async {
            let image: UIImage?
            
            switch load {
            case .path(let path):
                image = UIImage(contentsOfFile: path)
            case .name(let name):
                image = UIImage(named: name)
            }
            
            DispatchQueue.main.async {
                if let image = image {
                    self.wrapperLayer.contents = image.cgImage
                }
            }
        }
    }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "currentFrame" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "currentFrame" {
            let theAnimation = CABasicAnimation(keyPath: event)
            theAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            theAnimation.fromValue = self.presentation()?.value(forKey: event)
            return theAnimation
        }
        return super.action(forKey: event)
    }
    
    override func display() {
        var thePresentation = self
        if let keys = animationKeys(), let pres = self.presentation(), keys.count > 0 {
            thePresentation = pres
        }
        display(frame: thePresentation.currentFrame)
    }
    
    func display(frame: Double) {
        display(frame: frame, forceUpdate: false)
    }
    
    func display(frame: Double, forceUpdate: Bool) {
        var hidden = false
        if let inFrame = inFrame, let outFrame = outFrame {
            hidden = (frame < inFrame || frame > outFrame)
        }
        self.isHidden = isEnabled ? hidden : true
        if hidden {
            return
        }
        
        if let opacityInterpolator = opacityInterpolator, opacityInterpolator.hasUpdate(frame: frame) {
            self.opacity = Float(opacityInterpolator.floatValue(frame: frame))
        }
        
        if let transformInterpolator = transformInterpolator, transformInterpolator.hasUpdate(frame: frame) {
            wrapperLayer.transform = transformInterpolator.transform(frame: frame)
        }
        if contentsGroup != nil {
            let _ = contentsGroup.update(frame: frame, modifier: nil, forceLocalUpdate: forceUpdate)
        }
        if let maskLayer = maskLayer {
            maskLayer.currentFrame = frame
        }
    }
    
    func logHierarchyKeypaths(withParent parent: String?) {
        contentsGroup?.logHierarchyKeypaths(withParent: parent)
    }
}
