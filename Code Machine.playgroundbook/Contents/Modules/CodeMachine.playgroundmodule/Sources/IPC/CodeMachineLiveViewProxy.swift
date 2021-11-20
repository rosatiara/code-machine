//
//  CodeMachineLiveViewProxy.swift
//
//  Copyright © 2016-2020 Apple Inc. All rights reserved.
//

import Foundation
import SPCCore
import SPCIPC

public protocol CodeMachineLiveViewRepresentable {
    func setItemA(item: Thing)
    func setItemB(item: Thing)
    func forgeItems()
    func switchLight(light: Light, onOff: SwitchState)
    func setSpeed(speed: Speed)
    func reset()
    func enableEquipAlerts(enabled: Bool, autoEquip: Bool)
    func playMachineSound(sound: SoundFX)
    func enableAutoPlayCelebrationDance(enabled: Bool)
}

public class CodeMachineLiveViewProxy: CodeMachineLiveViewRepresentable, Messagable, LiveViewRegistering {
    
    public static let shared = CodeMachineLiveViewProxy()
    
    static var receivers = [CodeMachineLiveViewRepresentable]()
    
    public static func registerToRecieveDecodedMessage(as object: CodeMachineLiveViewRepresentable) {
        receivers.append(object)
    }
    
    public static func liveViewRegistration() {
        Message.registerToReceiveData(as: self)
    }
    
    private static let decoder = JSONDecoder()
    
    public init() {}
    
    private func send(_ thing: Sendable) {
        Message.send(thing, payload: type(of: thing), proxy: type(of: self))
    }
    
    public func setItemA(item: Thing) {
        send(SetItemA(item: item))
    }
    
    public func setItemB(item: Thing) {
        send(SetItemB(item: item))
    }
    
    public func forgeItems() {
        send(ForgeItems())
    }
    
    public func switchLight(light: Light, onOff: SwitchState) {
        send(SwitchLight(light: light, isOn: onOff))
    }
    
    public func setSpeed(speed: Speed) {
        send(SetSpeed(speed: speed))
    }
    
    public func reset() {
        send(Reset())
    }
    
    public func enableEquipAlerts(enabled: Bool, autoEquip: Bool) {
        send(EnableEquipAlerts(enabled: enabled, autoEquip: autoEquip))
    }
    
    public func playMachineSound(sound: SoundFX) {
        send(PlayMachineSound(sound: sound))
    }
    
    public func enableAutoPlayCelebrationDance(enabled: Bool) {
        send(EnableAutoPlayCelebrationDance(value: enabled))
    }
    
    enum MessageType: String {
        case SetItemA
        case SetItemB
        case ForgeItems
        case SwitchLight
        case SetSpeed
        case Reset
        case EnableEquipAlerts
        case PlayMachineSound
        case EnableAutoPlayCelebrationDance
    }
    
    public static func decode(data: Data, withId id: String) {
        guard let type = MessageType(rawValue: id) else { return }
        switch type {
        case .SetItemA:
            if let decoded = try? decoder.decode(SetItemA.self, from: data) {
                receivers.forEach({$0.setItemA(item: decoded.item)})
            }
        case .SetItemB:
            if let decoded = try? decoder.decode(SetItemB.self, from: data) {
                receivers.forEach({$0.setItemB(item: decoded.item)})
            }
        case .ForgeItems:
            receivers.forEach({$0.forgeItems()})
        case .SwitchLight:
            if let decoded = try? decoder.decode(SwitchLight.self, from: data) {
                receivers.forEach({$0.switchLight(light: decoded.light, onOff: decoded.isOn)})
            }
        case .SetSpeed:
            if let decoded = try? decoder.decode(SetSpeed.self, from: data) {
                receivers.forEach({$0.setSpeed(speed: decoded.speed)})
            }
        case .Reset:
            receivers.forEach({$0.reset()})
        case .EnableEquipAlerts:
            if let decoded = try? decoder.decode(EnableEquipAlerts.self, from: data) {
                receivers.forEach({$0.enableEquipAlerts(enabled: decoded.enabled, autoEquip: decoded.autoEquip)})
            }
        case .PlayMachineSound:
            if let decoded = try? decoder.decode(PlayMachineSound.self, from: data) {
                receivers.forEach({$0.playMachineSound(sound: decoded.sound)})
            }
        case .EnableAutoPlayCelebrationDance:
            if let decoded = try? decoder.decode(EnableAutoPlayCelebrationDance.self, from: data) {
                receivers.forEach({$0.enableAutoPlayCelebrationDance(enabled: decoded.value)})
            }
        }
    }
}

struct SetItemA: Sendable {
    var item : Thing
}

struct SetItemB: Sendable {
    var item : Thing
}

struct ForgeItems: Sendable { }

struct SwitchLight: Sendable {
    var light : Light
    var isOn : SwitchState
}

struct SetSpeed: Sendable {
    var speed : Speed
}

struct Reset: Sendable { }

struct EnableEquipAlerts: Sendable {
    var enabled: Bool
    var autoEquip: Bool
}

struct PlayMachineSound: Sendable {
    var sound : SoundFX
}

struct EnableAutoPlayCelebrationDance: Sendable {
    var value : Bool
}
