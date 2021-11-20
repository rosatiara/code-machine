//
//  AssessmentInfo.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit



public enum AssessmentTrigger {
    case start(context: AssessmentInfo.Context)
    case stop
    case evaluate
}


extension AssessmentTrigger: RawRepresentable {
    public typealias RawValue = [Int]

    public init?(rawValue: RawValue) {
        guard rawValue.count > 0 else { return nil }
        
        switch rawValue[0] {
        case 0:
            guard
                rawValue.count > 1,
                let context = AssessmentInfo.Context(rawValue: rawValue[1])
                else { return nil }
            self = .start(context: context)
            
        case 1:
            self = .stop
            
        case 2:
            self = .evaluate
            
        default:
            return nil
        }
    }
    
    
    public var rawValue: RawValue {
        var value = [Int]()
        switch self {
        case .start(let context):
            value.append(0)
            value.append(context.rawValue)
            
        case .stop:
            value.append(1)
            
        case .evaluate:
            value.append(2)
        }

        return value
    }

}

public enum AssessmentEvent {
    
    case forgedItem(item: ForgedItem)
    case celebrationDanceCompleted
    case pageExecutionCompleted
}


public struct AssessmentInfo {
    
    public enum Context: Int {
        case discrete
    }

    public let events: [AssessmentEvent]
    public let context: Context
    public let customInfo: [AnyHashable : Any]
    
    public subscript(key: AnyHashable) -> Any? {
         return customInfo[key]
    }

}


