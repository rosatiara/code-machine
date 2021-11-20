//
//  Recipe.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport

public struct Recipe: Codable, Equatable {
    public var itemA: Thing
    public var itemB: Thing
    public var light: Light?
    
    static let undefined = Recipe(itemA: .undefined, itemB: .undefined)
    
    init(itemA: Thing, itemB: Thing, light: Light? = nil) {
        self.itemA = itemA
        self.itemB = itemB
        self.light = light
    }
    
    var description: String {
        var desc = "\(itemA) + \(itemB)"
        if let light = light {
            desc += " + \(light)"
        }
        return desc
    }
    
    var accessibilityDescription: String? {
        guard itemA != .undefined, itemB != .undefined else { return nil }
        let format : String
        if let _ = light {
            format = NSLocalizedString("%1$@ and %2$@ with %3$@ light", comment: "AX description for recipe including a light")
        }
        else {
            format = NSLocalizedString("%1$@ and %2$@", comment: "AX description for recipe")
        }
        return String(format: format, itemA.name, itemB.name, light?.name ?? "")
    }
    
    public static func ==(lhs: Recipe, rhs: Recipe) -> Bool {
        return (lhs.itemA == rhs.itemA) && (lhs.itemB == rhs.itemB) && (lhs.light == rhs.light)
    }
}

extension Recipe {
    
    init?(playgroundValue: PlaygroundValue) {
        guard case let .array(array) = playgroundValue,
            array.count > 2,
            case let .string(rawValueItemA) = array[0],
            case let .string(rawValueItemB) = array[1],
            case let .string(rawValueLight) = array[2],
            let newItemA = Thing(rawValue: rawValueItemA),
            let newItemB = Thing(rawValue: rawValueItemB)
            else { return nil }
        
        itemA = newItemA
        itemB = newItemB
        
        if let newLight = Light(rawValue: rawValueLight) {
            light = newLight
        }
    }
    
    var playgroundValue: PlaygroundValue {
        get {
            var ingredients: [PlaygroundValue] = [.string(itemA.rawValue), .string(itemB.rawValue)]
            var lightString = ""
            if let light = self.light {
                lightString = light.rawValue
            }
            ingredients.append(.string(lightString))
            return .array(ingredients)
        }
    }
}
