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
    registerEvaluator(Page4Assessment(), style: .discrete)
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
//#-code-completion(identifier, show, let, for, setItemA(_:), setItemB(_:), forgeItems(), switchLightOn(_:), [])
//#-code-completion(identifier, show, metal, stone, cloth, dirt, DNA, red, green, blue, ., spring, wire, gear, egg, seed, tree, crystal)
//#-code-completion(identifier, hide, listener, proxy, PageAssessment, playgroundPrologue(), playgroundEpilogue())

//#-end-hidden-code
//#-editable-code
let colors = [Light.red, Light.green, Light.blue]

for color in colors {
    setItemA(.stone)
    setItemB(.dirt)
    switchLightOn(color)
    forgeItems()
}
//#-end-editable-code
//#-hidden-code
assessmentController?.append(.pageExecutionCompleted)
assessmentController?.shouldStopPageAfterDiscreteAssessment = true
playgroundEpilogue()
//#-end-hidden-code

