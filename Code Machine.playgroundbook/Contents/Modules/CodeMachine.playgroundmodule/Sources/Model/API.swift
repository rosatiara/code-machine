//
//  API.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation
import PlaygroundSupport
import SPCCore

public enum Thing : String, Codable {
    case undefined
    
    // Base Materials
    
    /**
     A sheet of metal.
     - localizationKey: Item.metal
     */
    case metal
    /**
     A chunk of rock.
     - localizationKey: Item.stone
     */
    case stone
    /**
     A piece of fabric.
     - localizationKey: Item.cloth
     */
    case cloth
    /**
     A patch of earth.
     - localizationKey: Item.dirt
     */
    case dirt
    /**
     A strand of genetic material.
     - localizationKey: Item.DNA
     */
    case DNA
    
    // Secondary Items
    
    /**
     A length of metal wire, coiled tightly.
     - localizationKey: Item.spring
     */
    case spring
    /**
     A flexible strand of wire.
     - localizationKey: Item.wire
     */
    case wire
    /**
     A speckled bird egg.
     - localizationKey: Item.egg
     */
    case egg
    /**
     A living tree, of the pine variety.
     - localizationKey: Item.tree
     */
    case tree
    /**
     A rotating, metallic, machine part.
     - localizationKey: Item.gear
     */
    case gear
    /**
     A small seed, capable of growing in the dirt.
     - localizationKey: Item.seed
     */
    case seed
    /**
     A purple, crystalline gem.
     - localizationKey: Item.crystal
     */
    case crystal
    /**
     A brown, crimini mushroom.
     - localizationKey: Item.mushroom
     */
    case mushroom
    /**
     It’s definitely alive, but who knows what it is.
     - localizationKey: Item.unidentifiedLifeForm
     */
    case unidentifiedLifeForm
    
    // Final Products
    case mushroomHelmet
    case extendoHat
    case mechanicalWig
    case chromeShredderWheels
    case blu
    case cyborgEyeballs
    case friedEggs
    case stoneMask
    case eagleSunglasses
    case diamondJacket
    case dragonWings
    case snapPeaTutu
    case electricHoolahoop
    case octopusTentacle
    case springLoadedFist
    case pumpkinHand
    case spiralingStalactites
    case turboFanBladePropeller
    case flamingoBouquet
    case meatballSleeve
    case flowyRainbowRibbon
    case glowingMushroomShoes
    case ostrichLegs
    case purplePressurePistons
    
    // Dud product
    case brick
    
    public var name: String {
        switch self {
        case .metal:
            return NSLocalizedString("Metal", comment: "")
        case .stone:
            return NSLocalizedString("Stone", comment: "")
        case .cloth:
            return NSLocalizedString("Cloth", comment: "")
        case .dirt:
            return NSLocalizedString("Dirt", comment: "")
        case .DNA:
            return NSLocalizedString("DNA", comment: "")
        case .spring:
            return NSLocalizedString("Spring", comment: "")
        case .wire:
            return NSLocalizedString("Wire", comment: "")
        case .egg:
            return NSLocalizedString("Egg", comment: "")
        case .tree:
            return NSLocalizedString("Tree", comment: "")
        case .gear:
            return NSLocalizedString("Gear", comment: "")
        case .seed:
            return NSLocalizedString("Seed", comment: "")
        case .crystal:
            return NSLocalizedString("Crystal", comment: "")
        case .mushroom:
            return NSLocalizedString("Mushroom", comment: "")
        case .unidentifiedLifeForm:
            return NSLocalizedString("Unidentified Life Form", comment: "")
        case .mushroomHelmet:
            return NSLocalizedString("Mushroom Helmet", comment: "")
        case .extendoHat:
            return NSLocalizedString("Extendo-hat", comment: "")
        case .mechanicalWig:
            return NSLocalizedString("Mechanical Wig", comment: "")
        case .chromeShredderWheels:
            return NSLocalizedString("Chrome Shredder Wheels", comment: "")
        case .blu:
            return NSLocalizedString("Blu", comment: "")
        case .cyborgEyeballs:
            return NSLocalizedString("Cyborg Eyeballs", comment: "")
        case .friedEggs:
            return NSLocalizedString("Fried Eggs", comment: "")
        case .stoneMask:
            return NSLocalizedString("Stone Mask", comment: "")
        case .eagleSunglasses:
            return NSLocalizedString("Eagle Sunglasses", comment: "")
        case .diamondJacket:
            return NSLocalizedString("Diamond Jacket", comment: "")
        case .dragonWings:
            return NSLocalizedString("Dragon Wings", comment: "")
        case .snapPeaTutu:
            return NSLocalizedString("Snap-pea Tutu", comment: "")
        case .electricHoolahoop:
            return NSLocalizedString("Electric Hoop", comment: "")
        case .octopusTentacle:
            return NSLocalizedString("Octopus Tentacle", comment: "")
        case .springLoadedFist:
            return NSLocalizedString("Spring-loaded Fist", comment: "")
        case .pumpkinHand:
            return NSLocalizedString("Pumpkin Hand", comment: "")
        case .spiralingStalactites:
            return NSLocalizedString("Spiraling Stalactites", comment: "")
        case .turboFanBladePropeller:
            return NSLocalizedString("Turbo Fan Blade Propeller", comment: "")
        case .flamingoBouquet:
            return NSLocalizedString("Flamingo Bouquet", comment: "")
        case .meatballSleeve:
            return NSLocalizedString("Meatball Sleeve", comment: "")
        case .flowyRainbowRibbon:
            return NSLocalizedString("Flowy Rainbow Ribbon", comment: "")
        case .glowingMushroomShoes:
            return NSLocalizedString("Glowing Mushroom Shoes", comment: "")
        case .ostrichLegs:
            return NSLocalizedString("Ostrich Legs", comment: "")
        case .purplePressurePistons:
            return NSLocalizedString("Purple Pressure Pistons", comment: "")
        case .undefined:
            return NSLocalizedString("Unknown item", comment: "")
        case .brick:
            return NSLocalizedString("Brick", comment: "")
        }
    }
    
    public var accessibilityDescription: String {
        switch self {
        case .metal:
            return NSLocalizedString("Metal", comment: "")
        case .stone:
            return NSLocalizedString("Stone", comment: "")
        case .cloth:
            return NSLocalizedString("Cloth", comment: "")
        case .dirt:
            return NSLocalizedString("Dirt", comment: "")
        case .DNA:
            return NSLocalizedString("DNA", comment: "")
        case .spring:
            return NSLocalizedString("Spring", comment: "")
        case .wire:
            return NSLocalizedString("Wire", comment: "")
        case .egg:
            return NSLocalizedString("Egg", comment: "")
        case .tree:
            return NSLocalizedString("Tree", comment: "")
        case .gear:
            return NSLocalizedString("Gear", comment: "")
        case .seed:
            return NSLocalizedString("Seed", comment: "")
        case .crystal:
            return NSLocalizedString("Crystal", comment: "")
        case .mushroom:
            return NSLocalizedString("Mushroom", comment: "")
        case .unidentifiedLifeForm:
            return NSLocalizedString("Unidentified life form", comment: "")
        case .mushroomHelmet:
            return NSLocalizedString("Two brown crimini mushrooms worn as a hat.", comment: "Mushroom helmet AX description")
        case .extendoHat:
            return NSLocalizedString("An orange top hat extending upward like a spring.", comment: "Extendo-hat AX description")
        case .mechanicalWig:
            return NSLocalizedString("A wig made out of thick, chrome-like, metallic hairs.", comment: "Mechanical wig AX description")
        case .chromeShredderWheels:
            return NSLocalizedString("A pair of car tires with specialized rims.", comment: "Chrome shredder wheels AX description")
        case .blu:
            return NSLocalizedString("A blue, tear-drop-shaped organism perched on the machine’s head.", comment: "Blu AX description")
        case .cyborgEyeballs:
            return NSLocalizedString("Two turquoise eye structures bolted with sheet metal across the face.", comment: "Cyborg eyeballs AX description")
        case .friedEggs:
            return NSLocalizedString("Two sunny-side up eggs arranged so the yolks look like eyes.", comment: "Fried eggs AX description")
        case .stoneMask:
            return NSLocalizedString("A mask carved out of stone with two eyeholes where the machine’s eyes peek through.", comment: "Stone mask AX description")
        case .eagleSunglasses:
            return NSLocalizedString("A pair of sunglasses ornamented with an eagle between the lenses and feathers emerging from both sides.", comment: "Eagle sunglasses AX description")
        case .diamondJacket:
            return NSLocalizedString("A high-collared jacket adorned with blue crystals.", comment: "Diamond jacket AX description")
        case .dragonWings:
            return NSLocalizedString("A pair of pink and green dragon wings emerging from the machine’s torso.", comment: "Dragon wings AX description")
        case .snapPeaTutu:
            return NSLocalizedString("A tutu made of snap peas worn around the machine’s torso.", comment: "Snap pea tutu AX description")
        case .electricHoolahoop:
            return NSLocalizedString("A pink, electrified hoop worn around the machine’s torso.", comment: "Electric hoop AX description")
        case .octopusTentacle:
            return NSLocalizedString("A purple octopus tentacle hanging from the machine like an arm.", comment: "Octopus tentacle AX description")
        case .springLoadedFist:
            return NSLocalizedString("A pink robotic arm connected to a fist with a spring.", comment: "Spring-loaded fist AX description")
        case .pumpkinHand:
            return NSLocalizedString("A pumpkin connected to the machine with its vine.", comment: "Pumpkin hand AX description")
        case .spiralingStalactites:
            return NSLocalizedString("A spiral structure of icicle-like stalactites, protruding from the body like an arm.", comment: "Spiraling stalactites AX description")
        case .turboFanBladePropeller:
            return NSLocalizedString("An airplane engine with a set of metallic blades attached to the machine like an arm.", comment: "Turbo fan blade propeller AX description")
        case .flamingoBouquet:
            return NSLocalizedString("A set of three flamingos nesting on a leaf, emerging from the machine like an arm.", comment: "Flamingo bouquet AX description")
        case .meatballSleeve:
            return NSLocalizedString("An arm piercing through a large meatball, surrounded by strands of spaghetti.", comment: "Meatball sleeve AX description")
        case .flowyRainbowRibbon:
            return NSLocalizedString("A rainbow-colored ribbon floating in a spiral pattern away from the machine’s torso.", comment: "Flowy rainbow ribbon AX description")
        case .glowingMushroomShoes:
            return NSLocalizedString("A pair of crimini mushrooms, sliced in half, emitting a yellow glow and acting as the machine’s feet.", comment: "Glowing mushroom shoes AX description")
        case .ostrichLegs:
            return NSLocalizedString("The legs and black feathers of an ostrich attached to the undercarriage of the machine.", comment: "Ostrich legs AX description")
        case .purplePressurePistons:
            return NSLocalizedString("A pair of purple pistons, attached as legs to the undercarriage of the machine.", comment: "Purple pressure pistons AX description")
        case .undefined:
            return NSLocalizedString("An unknown item", comment: "Undefined item AX description")
        case .brick:
            return NSLocalizedString("A brick", comment: "Brick AX description")
        }
    }
    
    public static var baseMaterials: [Thing] { return [.metal, .stone, .cloth, .dirt, .DNA] }
    public static var secondaryItems: [Thing] { return [.spring, .wire, .egg, .tree, .gear, .seed, .crystal, .mushroom, .unidentifiedLifeForm] }
    public static var finalProducts: [Thing] { return [.mushroomHelmet, .extendoHat, .mechanicalWig, .chromeShredderWheels, .blu, .cyborgEyeballs, .friedEggs, .stoneMask, .eagleSunglasses, .diamondJacket, .dragonWings, .snapPeaTutu, .electricHoolahoop, .octopusTentacle, .springLoadedFist, .pumpkinHand, .spiralingStalactites, .turboFanBladePropeller, .flamingoBouquet, .meatballSleeve, .flowyRainbowRibbon, .glowingMushroomShoes, .ostrichLegs, .purplePressurePistons] }

    public var isBaseMaterial: Bool { return Thing.baseMaterials.contains(self) }
    public var isSecondaryItem: Bool { return Thing.secondaryItems.contains(self) }
    public var isFinalProduct: Bool { return Thing.finalProducts.contains(self) }
}

/**
 Inputs and outputs to the machine are known as items. Some items are final products that the machine can equip.
 - localizationKey: Item
 */
public typealias Item = Thing

extension Thing: Comparable {
    public static func < (lhs: Thing, rhs: Thing) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension Thing {
    
    init?(playgroundValue: PlaygroundValue) {
        guard case let .string(rawValue) = playgroundValue else { return nil }
        self.init(rawValue: rawValue)
    }
    
    var playgroundValue: PlaygroundValue {
        get {
            return .string(self.rawValue)
        }
    }
}

extension Thing {
    
    private var forgedKey: String { return "ThingKey.\(self.rawValue)" }
    private var recipeKey: String { return "Recipe.\(self.rawValue)" }
    
    public var isEmpty: Bool {
        return self == .undefined
    }
    
    public var hasBeenForged: Bool {
        guard self.isSecondaryItem || self.isFinalProduct else { return false }
        return self.recipe != nil
    }
    
    public var isEquipped: Bool {
        guard self.isFinalProduct else { return false }
        guard let bodyPart = Robot.bodyPartThatCanBeEquipped(with: self) else { return false }
        return (bodyPart.equippedItem == self)
    }
    
    var recipe: Recipe? {
        get {
            if let playgroundValue = PlaygroundKeyValueStore.current[recipeKey] {
                return Recipe(playgroundValue: playgroundValue)
            }
            return nil
        }
    }
    
    func setRecipe(_ recipe: Recipe?) {
        guard self.isSecondaryItem || self.isFinalProduct else { return }
        PlaygroundKeyValueStore.current[recipeKey] = recipe?.playgroundValue
    }
    
    public static func resetState() {
        for thing in secondaryItems + finalProducts {
            thing.setRecipe(nil)
        }
    }
}

/**
 The lights on the machine, including red, green, and blue. Only one light can be on at a time.
 - localizationKey: Light
 */
public enum Light : String, Codable {
    /**
     This light heats items. Good for making mechanical objects.
     - localizationKey: Light.red
     */
    case red
    /**
     This light gives life. Good for making living things.
     - localizationKey: Light.green
     */
    case green
    /**
     This light cools and transforms items. Good for making clothing.
     - localizationKey: Light.blue
     */
    case blue
    
    public var name: String {
        switch self {
        case .red:
            return NSLocalizedString("Red", comment: "Red light name")
        case .green:
            return NSLocalizedString("Green", comment: "Green light name")
        case .blue:
            return NSLocalizedString("Blue", comment: "Blue light name")
        }
    }
}

public enum SwitchState : Int, Codable {
    case off = 0
    case on = 1
}

public let on = SwitchState.on
public let off = SwitchState.off

public enum Speed : Int, Codable {
    case normal = 0
    case fast = 1
    
    public var isNormal: Bool {
        return self == .normal
    }
    
    public var isFast: Bool {
        return self == .fast
    }
}

/**
Sets an item into slot A. Must also have an item in slot B before calling `forgeItems()`.
 - parameters:
     - item: An item, such as stone, cloth, dirt, gear, or wire.
 - localizationKey: setItemA(_:)
 */
public func setItemA(_ item: Item) {
    CodeMachineLiveViewProxy.shared.setItemA(item: item)
}

/**
Sets an item into slot B. Must also have an item in slot A before calling `forgeItems()`.
 - parameters:
     - item: An item, such as stone, cloth, dirt, gear, or wire.
 - localizationKey: setItemB(_:)
 */
public func setItemB(_ item: Item) {
    CodeMachineLiveViewProxy.shared.setItemB(item: item)
}

/**
Turns on a specific color of light on the machine. Lights must be set before calling `forgeItems()`.
 - parameters:
     - color: A valid color of light: `.red`, `.green`, or `.blue`.
 - localizationKey: switchLightOn(_:)
 */
public func switchLightOn(_ color: Light) {
    switchLight(light: color, onOff: on)
    switch color {
    case .red:
            switchLight(light: .green, onOff: off)
            switchLight(light: .blue, onOff: off)
        
    case .blue:
            switchLight(light: .red, onOff: off)
            switchLight(light: .green, onOff: off)
    
    case .green:
            switchLight(light: .red, onOff: off)
            switchLight(light: .blue, onOff: off)
    }
}

/**
Turns off a specific color of light on the machine. Lights must be set before `forgeItems()` is called.
 - parameters:
     - color: A valid color of light: `.red`, `.green`, or `.blue`.
 - localizationKey: switchLightOff(_:)
 */
public func switchLightOff(_ color: Light) {
    switchLight(light: color, onOff: off)
}

public func switchLightsOff() {
    switchLight(light: .red, onOff: off)
    switchLight(light: .green, onOff: off)
    switchLight(light: .blue, onOff: off)
}

private func switchLight(light: Light, onOff: SwitchState) {
    CodeMachineLiveViewProxy.shared.switchLight(light: light, onOff: onOff)
}

/**
 Sets the speed of the machine.
 - parameters:
 - speed: A valid speed: `.normal` or `.fast`.
 - localizationKey: setSpeed(_:)
 */
public func setSpeed(_ speed: Speed) {
    CodeMachineLiveViewProxy.shared.setSpeed(speed: speed)
}

var forgedItem : ForgedItem?

/**
 Forges items in slot A and slot B, then returns the result. Should be called after other properties of the machine have been set, such as item A, item B, and the lights.
 
 Example:
 
 ```
 setItemA(.stone)
 setItemB(.dirt)
 switchLightOn(.green)
 forgeItems()
 ```
 
 - Returns: An Item.
 - localizationKey: forgeItems()
 */
@discardableResult
public func forgeItems() -> Item {
    CodeMachineLiveViewProxy.shared.forgeItems()
    
    // Wait until the live view completes the forging cycle.
    // The live view then sends an itemForged message, which in turn sets forgedItem.
    repeat {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
    } while (forgedItem == nil)

    defer {
        forgedItem = nil
    }

    return forgedItem!.item
}

/**
 Reset all items to the unforged state and unequip the machine.
 - localizationKey: reset()
 */
public func reset() {
    CodeMachineLiveViewProxy.shared.reset()
}

/**
 Enable or disable equip alerts after forging new items.
 - parameters:
 - enabled: Set to `false` to turn off equip alerts. The default is `true`.
 - autoEquip: Set to `true` to automatically equip a forged item if (equip alerts) `enabled` is `false`. Optional. The default is `false`.
 - localizationKey: enableEquipAlerts(_:autoEquip:)
 */
public func enableEquipAlerts(_ enabled: Bool, autoEquip: Bool = false) {
    CodeMachineLiveViewProxy.shared.enableEquipAlerts(enabled: enabled, autoEquip: autoEquip)
}

/**
 Plays the given sound in the live view.
 - parameters:
 - sound: The sound to play.
 - localizationKey: playSoundInLiveView(_:)
 */
public func playSoundInLiveView(_ sound: SoundFX) {
    CodeMachineLiveViewProxy.shared.playMachineSound(sound: sound)
}
