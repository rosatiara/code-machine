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
    registerEvaluator(Page3Assessment(), style: .discrete)
}

public func playgroundEpilogue() {
    performAssessment()
}

PlaygroundPage.current.needsIndefiniteExecution = true
let listener = LiveViewListener()
CodeMachineUserCodeProxy.registerToRecieveDecodedMessage(as: listener)
playgroundPrologue()
assessmentController?.shouldStopPageAfterDiscreteAssessment = false

//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, show, let, setItemA(_:), setItemB(_:), forgeItems(), switchLightOn(_:))
//#-code-completion(identifier, show, metal, seed, stone, cloth, dirt, DNA, red, green, blue, ., crystal, spring, gear)
//#-code-completion(identifier, hide, listener, proxy, PageAssessment, playgroundPrologue(), playgroundEpilogue())

//#-end-hidden-code
//#-editable-code
setItemA(.stone)
setItemB(.stone)
switchLightOn(.red)
forgeItems()
//#-end-editable-code
//#-hidden-code
assessmentController?.append(.pageExecutionCompleted)
assessmentController?.shouldStopPageAfterDiscreteAssessment = true
playgroundEpilogue()
//#-end-hidden-code
