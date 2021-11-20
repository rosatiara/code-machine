//#-hidden-code
//
//  main.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//
import PlaygroundSupport
import UIKit
import SPCCore

Process.setIsUser()

public func playgroundPrologue() {
    registerEvaluator(Page6Assessment(), style: .discrete)
}

public func playgroundEpilogue() {
    performAssessment()
}

PlaygroundPage.current.needsIndefiniteExecution = true
let listener = LiveViewListener()
CodeMachineUserCodeProxy.registerToRecieveDecodedMessage(as: listener)
playgroundPrologue()
assessmentController?.shouldStopPageAfterDiscreteAssessment = false

var shouldEnableAutoPlayCelebrationDance = true
if let currentStatus = PlaygroundPage.current.assessmentStatus, case .pass = currentStatus {
    shouldEnableAutoPlayCelebrationDance = false
}
CodeMachineLiveViewProxy.shared.enableAutoPlayCelebrationDance(enabled: shouldEnableAutoPlayCelebrationDance)

//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, show, let, for, setItemA(_:), setItemB(_:), forgeItems(), switchLightOn(_:), [])
//#-code-completion(identifier, show, metal, stone, cloth, dirt, DNA, red, green, blue, ., Light, Item, spring, gear, egg, seed, tree, crystal, wire, mushroom, unidentifiedLifeForm)
//#-code-completion(identifier, hide, listener, proxy, PageAssessment, playgroundPrologue(), playgroundEpilogue(), shouldEnableAutoPlayCelebrationDance)

//#-end-hidden-code
//#-editable-code
let allItems = [Item.metal, Item.stone, Item.cloth, Item.dirt, Item.spring, Item.wire, Item.egg, Item.tree, Item.gear, Item.seed, Item.crystal, Item.mushroom, Item.unidentifiedLifeForm]

for item in allItems {
    // /*#-localizable-zone(Page6Main)*/Add your nested loop here./*#-end-localizable-zone*/
    
    
}
//#-end-editable-code
//#-hidden-code
assessmentController?.append(.pageExecutionCompleted)
assessmentController?.shouldStopPageAfterDiscreteAssessment = true
playgroundEpilogue()
//#-end-hidden-code


