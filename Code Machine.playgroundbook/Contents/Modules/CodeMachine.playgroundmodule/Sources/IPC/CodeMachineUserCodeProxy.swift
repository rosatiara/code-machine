//
//  CodeMachineUserCodeProxy.swift
//
//  Copyright © 2016-2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

public protocol CodeMachineUserCodeRepresentable {
    func itemForged(item: ForgedItem)
    func celebrationDanceCompleted()
}

public class CodeMachineUserCodeProxy: CodeMachineUserCodeRepresentable, Messagable {
    
    public static let shared = CodeMachineUserCodeProxy()
    
    static var receivers = [CodeMachineUserCodeRepresentable]()
    
    public static func registerToRecieveDecodedMessage(as object: CodeMachineUserCodeRepresentable) {
        receivers.append(object)
        Message.registerToReceiveData(as: self)
    }
    
    private static let decoder = JSONDecoder()
    
    public init() {}
    
    enum MessageType: String {
        case ItemForged
        case CelebrationDanceCompleted
    }
    
    private func send(_ thing: Sendable) {
        Message.send(thing, payload: type(of: thing), proxy: type(of: self))
    }
    
    public func itemForged(item: ForgedItem) {
        send(ItemForged(item: item))
    }
    
    public func celebrationDanceCompleted() {
        send(CelebrationDanceCompleted())
    }
    
    public static func decode(data: Data, withId id: String) {
        guard let type = MessageType.init(rawValue: id) else { return }
        switch type {
        case .ItemForged:
            if let decoded = try? decoder.decode(ItemForged.self, from: data) {
                receivers.forEach({$0.itemForged(item: decoded.item)})
            }
        case .CelebrationDanceCompleted:
            if let _ = try? decoder.decode(CelebrationDanceCompleted.self, from: data) {
                receivers.forEach({$0.celebrationDanceCompleted()})
            }
        }
    }
}

struct ItemForged: Sendable {
    var item : ForgedItem
}

struct CelebrationDanceCompleted: Sendable { }
