//
//  Assessments.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import Foundation
import os

// MARK: Top level

var loader: AssessmentLoader? = nil
public var assessmentController: AssessmentController? = nil


public enum EvaluationStyle {
    case discrete
    case continuous
}

public class LearningTrailsProxy {
    
    private static let currentTrailKey = "LearningTrails.currentTrail"
    private static let currentStepKey = "LearningTrails.currentStep"
    
    /// The key under which the names of sent messages are saved in the key-value store (per page/trail).
    private var sentMessagesKey: String? {
        guard !currentTrailIdentifier.isEmpty else {
            os_log("LearningTrailsProxy: failed to create sentMessagesKey: missing currentTrailIdentifier.", log: OSLog.default, type: .error)
            return nil
        }
        return "LearningTrailsProxy.SentMessages.\(currentTrailIdentifier)"
    }
    
    public init() { }
    
    /// A persistent array of the messages that have been sent.
    var sentMessages: [String] {
        get {
            guard
                let sentMessagesKey = sentMessagesKey,
                case let .array(playgroundValues)? = PlaygroundKeyValueStore.current[sentMessagesKey]
            else { return [] }
            var messageNames = [String]()
            messageNames = playgroundValues.compactMap { playgroundValue in
                guard case let .string(messageName) = playgroundValue else { return nil }
                return messageName
            }
            return messageNames
        }
        set {
            guard let sentMessagesKey = sentMessagesKey else { return }
            PlaygroundKeyValueStore.current[sentMessagesKey] = .array(newValue.map { PlaygroundValue.string($0) } )
        }
    }
    
    /// Returns a dictionary of key-value pairs for the specified key.
    func getKeyValueStoreInfoFor(key: String) -> [String : String]? {
        guard case let .dictionary(valueDict)? = PlaygroundKeyValueStore.current[key] else { return nil }
        var info = [String : String]()
        if let value = valueDict["Identifier"], case let .string(identifier) = value {
            info["Identifier"] = identifier
        }
        if let value = valueDict["Name"], case let .string(name) = value {
            info["Name"] = name
        }
        return info
    }
    
    /// The name of the current learning trail (as defined in LearningTrail.xml).
    public var currentTrail: String {
        guard
            let trailInfo = getKeyValueStoreInfoFor(key: Self.currentTrailKey),
            let trailName = trailInfo["Name"]
        else { return "" }
        return trailName
    }
    
    /// The identifier of the current trail.
    public var currentTrailIdentifier: String {
        guard
            let trailInfo = getKeyValueStoreInfoFor(key: Self.currentTrailKey),
            let trailIdentifier = trailInfo["Identifier"]
        else { return "" }
        return trailIdentifier
    }
    
    /// The name of the current step (as defined in LearningTrail.xml).
    public var currentStep: String {
        guard
            let stepInfo = getKeyValueStoreInfoFor(key: Self.currentStepKey),
            let stepName = stepInfo["Name"]
        else { return "" }
        return stepName
    }
    
    /// The identifier of the current step.
    public var currentStepIdentifier: String {
        guard
            let stepInfo = getKeyValueStoreInfoFor(key: Self.currentStepKey),
            let stepIdentifier = stepInfo["Identifier"]
        else { return "" }
        return stepIdentifier
    }
    
    /// Sends actions to the learning trail.
    /// - parameter actions: The actions to be sent.
    public func sendActions(_ actions: [String]) {
        PlaygroundPage.current.assessmentStatus = .fail(hints: actions, solution: nil)
    }
    
    /// Sends a message to be displayed in the learning trail.
    /// To send a message defined in LearningTrail.xml just specify its `name`.
    /// To send an ad hoc message specify `name`, `sender`, `content`, and optionally `scope`.
    /// - parameter name: The name of the message to be sent.
    /// - parameter sender: The character the message is to be sent from: byte, blue, hopper or expert.
    /// - parameter scope: The scope of the message: trail, step (the default), or ephemeral.
    /// - parameter content: The content of the message.
    public func sendMessage(_ name: String, sender: String? = nil, scope: String? = nil, content: String? = nil) {
        var action = "learningtrails://sendChatMessage?name=\(name)"
        if let sender = sender, let content = content, let encodedContent = content.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            action += "&sender=\(sender)"
            if let scope = scope {
                action += "&scope=\(scope)"
            }
            action += "&content=\(encodedContent)"
        }
        sendActions([action])
        sentMessages.append(name)
    }
    
    /// Sends a message to be displayed in the learning trail, but will only send the message one time.
    /// To send a message defined in LearningTrail.xml just specify its `name`.
    /// To send an ad hoc message specify `name`, `sender`, `content`, and optionally `scope`.
    /// - parameter name: The name of the message to be sent.
    /// - parameter sender: The character the message is to be sent from: byte, blue, hopper or expert.
    /// - parameter scope: The scope of the message: trail, step (the default), or ephemeral.
    /// - parameter content: The content of the message.
    public func sendMessageOnce(_ name: String, sender: String? = nil, scope: String? = nil, content: String? = nil) {
        guard !hasSentMessage(name) else { return }
        sendMessage(name, sender: sender, content: content)
    }
    
    /// Returns `true` if the specified message has been sent.
    /// - parameter messageName: The name of the message.
    public func hasSentMessage(_ messageName: String) -> Bool {
        return sentMessages.contains(messageName)
    }
    
    /// Sets the assessment status.
    /// - parameter assessmentName: The name of the assessment (as defined in LearningTrail.xml).
    /// - parameter passed: The status of the assessment to be set.
    public func setAssessment(_ assessmentName: String, passed: Bool) {
        let action = "assessment://assessmentPassed?name=\(assessmentName)&passed=\(passed)"
        sendActions([action])
    }
    
    /// Marks a task as completed.
    /// - parameter taskName: The name of the task (as defined in LearningTrail.xml).
    /// - parameter completed: The status of the task to be set.
    public func setTask(_ taskName: String, completed: Bool) {
        let action = "learningtrails://setTaskCompleted?name=\(taskName)&completed=\(completed)"
        sendActions([action])
    }
}



public class AssessmentController {
    
    let evaluator: Evaluator
    
    let style: EvaluationStyle
    
    public var enabled: Bool = true
    
    public var context : AssessmentInfo.Context = .discrete
    
    private var events = [AssessmentEvent]()
    
    public var customInfo = [AnyHashable : Any]()
    
    public var allowAssessmentUpdates: Bool
    
    var learningTrails = LearningTrailsProxy()
    
    public var shouldStopPageAfterDiscreteAssessment: Bool = true

    public init(evaluator: Evaluator, style: EvaluationStyle) {
        
        self.evaluator = evaluator
        self.style = style
        
        switch style {
        case .continuous:
            allowAssessmentUpdates = false
            
        case .discrete:
            allowAssessmentUpdates = true
        }
        
    }
    
    public func append(_ event: AssessmentEvent) {
        if allowAssessmentUpdates {
            events.append(event)
        }
    }
    
    public func removeAllAssessmentEvents() {
        events.removeAll()
    }
    
    public func setAssessmentStatus() {
        guard enabled else { return }
        
        let info = AssessmentInfo(events: events, context: context, customInfo: customInfo)
        if let status = evaluator.performAssessment(assessmentInfo: info) {
            let dedupedMessages = Set(evaluator.messages)
            for message in dedupedMessages {
                var sender = "byte"
                if !message.passed {
                    sender = "hopper"
                }
                learningTrails.setAssessment(message.name, passed: message.passed)
                if message.sentOnce {
                    learningTrails.sendMessageOnce(message.name, sender: sender, content: message.content)
                } else {
                    learningTrails.sendMessage(message.name, sender: sender, content: message.content)
                }
            }
            
        }
    }
}

// MARK: Evaluator

public typealias FailureMessage = (hints: [String], solution: String?)

public protocol Evaluator {
    /// The message to be displayed when `evaluate(info:)` returns true. 
    /// This should be set in the Assessments.swift file for each page.
    var successMessage: String? { get set }
    
    /// By default this message is loaded from Hints.plist.
    func failureMessage() -> FailureMessage?
    
    /// Custom evaluation to determine pass/fail assessment.
    /// Return `true` to mark the page as successful.
    /// Return `false` to trigger the hints UI.
    /// Return `nil` to avoid triggering any assessment feedback.
    func evaluate(assessmentInfo: AssessmentInfo) -> Bool?
    
    var messages: [AssessmentMessage] { get set }
}

public struct AssessmentMessage: Hashable {
    public var name: String
    public var content: String
    public var passed: Bool
    public var sentOnce: Bool
    
    public init(name: String, content: String, passed: Bool, sentOnce: Bool) {
        self.name = name
        self.content = content
        self.passed = passed
        self.sentOnce = sentOnce
    }
    
    
}

public extension Evaluator {
    /// Defers execution of all methods until `assessmentStatus()` is called.
    func performAssessment(assessmentInfo: AssessmentInfo) -> PlaygroundPage.AssessmentStatus? {
        if let result = evaluate(assessmentInfo: assessmentInfo) {
            if result {
                return .pass(message: successMessage)
            }
            else {
                guard let (hints, solution) = failureMessage() else { return nil }
                return .fail(hints: hints, solution: solution)
            }
        }
        return nil
    }
}



// MARK: Assessment Registration

public func registerEvaluator(_ assessment: Evaluator, style: EvaluationStyle) {
    assessmentController = AssessmentController(evaluator: assessment, style: style)
}

/// Displays assessment information. 
public func performAssessment() {
    guard let controller = assessmentController, controller.style == .discrete else { return }
    controller.setAssessmentStatus()    
    if controller.shouldStopPageAfterDiscreteAssessment {
        PlaygroundPage.current.finishExecution()
    }
}



