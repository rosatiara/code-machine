//#-hidden-code
//
//  main.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport
import UIKit
import SPCCore

//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, show, setItemA(_:), setItemB(_:), forgeItems())
//#-code-completion(identifier, show, metal, stone, cloth, dirt, DNA, spring, .)
//#-code-completion(identifier, hide, listener, proxy, PageAssessment, playgroundPrologue(), playgroundEpilogue())

PlaygroundPage.current.needsIndefiniteExecution = true
let listener = LiveViewListener()
CodeMachineUserCodeProxy.registerToRecieveDecodedMessage(as: listener)
registerEvaluator(Page1Assessment(), style: .discrete)
assessmentController?.shouldStopPageAfterDiscreteAssessment = false
//#-end-hidden-code
//#-editable-code
setItemA(.metal)
setItemB(.cloth)
forgeItems()

//#-end-editable-code
//#-hidden-code
assessmentController?.append(.pageExecutionCompleted)
assessmentController?.shouldStopPageAfterDiscreteAssessment = true
performAssessment()
//#-end-hidden-code
