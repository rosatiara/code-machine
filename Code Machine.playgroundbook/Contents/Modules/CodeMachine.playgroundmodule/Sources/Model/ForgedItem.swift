//
//  ForgedItem.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation

public struct ForgedItem: Codable {
    public var item = Thing.undefined
    public var recipe = Recipe.undefined
    public var isForgedFirstTime = false
    
    static let undefined = ForgedItem(item: .undefined, recipe: .undefined, isForgedFirstTime: false)
    
    var code: String {
        var snippet = ""
        snippet += "// \(item.name) \n"
        snippet += "setItemA(.\(recipe.itemA.rawValue)) \n"
        snippet += "setItemB(.\(recipe.itemB.rawValue)) \n"
        if let light = recipe.light {
            snippet += "switchLightOn(.\(light.rawValue)) \n"
        }
        snippet += "let \(item.rawValue) = forgeItems() \n"
        
        return snippet
    }
    
    init(item: Thing, recipe: Recipe, isForgedFirstTime: Bool = false) {
        self.item = item
        self.recipe = recipe
        self.isForgedFirstTime = isForgedFirstTime
    }
}

