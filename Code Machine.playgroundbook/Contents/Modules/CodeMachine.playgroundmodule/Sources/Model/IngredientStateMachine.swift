//
//  IngredientStateMachine.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation

typealias LightsState = (red:Bool, green:Bool, blue:Bool)

protocol StateMachineDelegate : class {
    // Called when either ItemA or ItemB is changed, but only the one that changed will be present.
    func itemDidChange(stateMachine: IngredientStateMachine, itemA: Thing?, itemB: Thing?)
    func lightsDidChange(stateMachine: IngredientStateMachine, lightState: LightsState)
    func didForgeItems(stateMachine: IngredientStateMachine, itemA: Thing, itemB: Thing, forgedItem: ForgedItem)
}

class IngredientStateMachine {
    weak var delegate : StateMachineDelegate?
    
    var itemA : Thing = .undefined {
        didSet {
            delegate?.itemDidChange(stateMachine: self, itemA: itemA, itemB: nil)
        }
    }
    
    var itemB : Thing = .undefined {
        didSet {
            delegate?.itemDidChange(stateMachine: self, itemA: nil, itemB: itemB)
        }
    }
    
    var lights : LightsState = (red:false, green:false, blue:false) {
        didSet {
            delegate?.lightsDidChange(stateMachine: self, lightState: lights)
        }
    }
    
    var currentLight: Light? {
        if lights.red {
            return .red
        }
        else if lights.green {
            return .green
        }
        else if lights.blue {
            return .blue
        }
        return nil
    }
    
    var currentRecipe: Recipe {
        return Recipe(itemA: itemA, itemB: itemB, light: currentLight)
    }

    internal func reset() {
        itemA = .undefined
        itemB = .undefined
        lights = (red:false, green:false, blue:false)
        delegate?.didForgeItems(stateMachine: self, itemA: .undefined, itemB: .undefined, forgedItem: .undefined)
    }
    
    func forgeItems() -> Thing {
        let result = _resolveState()
        let forgedFirstTime = !result.hasBeenForged
        let forgedItem = ForgedItem(item: result, recipe: currentRecipe, isForgedFirstTime: forgedFirstTime)
        delegate?.didForgeItems(stateMachine: self, itemA: itemA, itemB: itemB, forgedItem: forgedItem)
        return result
    }
     
    private func _resolveState() -> Thing {
        let items = [itemA, itemB].sorted()
        
        if let currentLight = currentLight {
            let itemLightCombination = ItemLightCombination(a: items[0], b: items[1], c: currentLight)
            if let result = itemLightCombinationDictionary[itemLightCombination] {
                return result
            }
        }
        
        let itemCombination = ItemCombination(a: items[0], b: items[1])
        return itemCombinationDictionary[itemCombination] ?? .brick
    }
}
