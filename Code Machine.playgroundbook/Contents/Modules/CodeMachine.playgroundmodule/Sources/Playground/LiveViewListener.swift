//
//  LiveViewListener.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport
import SPCCore

public class LiveViewListener: CodeMachineUserCodeRepresentable {
    
    public init() { }
    
    public func itemForged(item: ForgedItem) {
        forgedItem = item
        
        PBLog("forgedItem: \(item)")
        
        assessmentController?.append(.forgedItem(item: item))
        
        // Allow main run loop to complete first so it can be unblocked in forgeItems().
        DispatchQueue.main.async {
            performAssessment()
        }
    }
    
    public func celebrationDanceCompleted() {
        assessmentController?.append(.celebrationDanceCompleted)
    }
}

