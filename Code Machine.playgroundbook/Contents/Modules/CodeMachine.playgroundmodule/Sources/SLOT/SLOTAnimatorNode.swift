//
//  SLOTAnimatorNode.swift
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

var indentationLevel = 0

class SLOTAnimatorNode {
    var valueInterpolators: [String: Any]?
    var keyname: String?
    var currentFrame: Double?
    var inputNode: SLOTAnimatorNode?
    var pathShouldCacheLengths = false
    
    var localPath: SLOTBezierPath = SLOTBezierPath()
    var outputPath: SLOTBezierPath = SLOTBezierPath()
    
    init(inputNode: SLOTAnimatorNode?, keyname: String?) {
        self.keyname = keyname
        self.inputNode = inputNode
    }
    
    // To be overwritten by subclass. Defaults to true
    func needsUpdate(frame: Double) -> Bool {
        return true
    }
    
    // The node checks if local update or if upstream update required. If upstream update outputs are rebuilt. If local update local update is performed. Returns no if no action
    func update(frame: Double) -> Bool {
        return update(frame: frame, modifier: nil, forceLocalUpdate: false)
    }
    
    @discardableResult func update(frame: Double, modifier: ((SLOTAnimatorNode) -> Void)?, forceLocalUpdate: Bool) -> Bool {
        
        if currentFrame == frame && !forceLocalUpdate {
            return false
        }
        let localUpdate = needsUpdate(frame: frame) || forceLocalUpdate
        let inputUpdated = inputNode?.update(frame: frame, modifier: modifier, forceLocalUpdate: forceLocalUpdate) ?? false
        currentFrame = frame
        
        if localUpdate {
            performLocalUpdate()
            if let modifier = modifier {
                modifier(self)
            }
        }
        
        if inputUpdated || localUpdate {
            rebuildOutputs()
        }
        
        return (inputUpdated || localUpdate)
    }
    
    func forceSetCurrentFrame(_ frame: Double) {
        currentFrame = frame
    }
    
    func performLocalUpdate() {
        localPath = SLOTBezierPath()
    }
    
    func rebuildOutputs() {
        if let inputNode = inputNode {
            outputPath = inputNode.outputPath.copy()
            outputPath.SLOT_append(bezierPath: localPath)
        } else {
            outputPath = localPath
        }
    }
    
    func setPathShouldCacheLengths(_ pathShouldCacheLengths: Bool) {
        self.pathShouldCacheLengths = pathShouldCacheLengths
        inputNode?.pathShouldCacheLengths = pathShouldCacheLengths
    }
    
    func set(value: Any, forKeyPath keyPath: NSString, forFrame frame: Double) -> Bool {
        let components = keyPath.components(separatedBy: ".") as [NSString]
        if let firstKey = components.first, components.count > 1 {
            let range = NSMakeRange(0, firstKey.length)
            let nextPath = keyPath.replacingCharacters(in: range, with: "")
            return setInterpolatorValue(value, forKey: nextPath, forFrame: frame)
        }
        return inputNode?.set(value: value, forKeyPath: keyPath, forFrame: frame) ?? false
    }
    
    func setInterpolatorValue(_ value: Any, forKey key: String, forFrame frame: Double) -> Bool {
        if let interpolator = valueInterpolators?[key] as? SLOTValueInterpolator {
            return interpolator.set(value: value, atFrame: frame)
        }
        
        return false
    }
    
    func log(string: String) {
        var logString = ""
        logString += "|"
        for _ in 0..<indentationLevel {
            logString += "  "
        }
        logString += string
        NSLog("%@ %@", String(describing: type(of: self)), logString);
    }
    
    func logHierarchyKeypaths(withParent parent: String?) {
        var keypath = keyname
        if let parent = parent, let keyname = keyname {
            keypath = "\(parent).\(keyname)"
        }
        if let keypath = keypath, let interpolatorKeys = valueInterpolators?.keys {
            for interpolator in interpolatorKeys {
                log(string: "\(keypath).\(interpolator)")
            }
            inputNode?.logHierarchyKeypaths(withParent: keypath)
        }
    }
}
