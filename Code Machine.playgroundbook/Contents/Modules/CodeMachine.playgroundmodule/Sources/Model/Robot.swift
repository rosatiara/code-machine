//
//  Robot.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit
import PlaygroundSupport

public enum BodyPart : String, Codable {
    case face
    case head
    case torso
    case appendage1
    case appendage2
    case feet
    
    public var name: String {
        switch self {
        case .face:
            return NSLocalizedString("Face", comment: "Name for body part.")
        case .head:
            return NSLocalizedString("Head", comment: "Name for body part.")
        case .torso:
            return NSLocalizedString("Torso", comment: "Name for body part.")
        case .appendage1:
            return NSLocalizedString("Appendage One", comment: "Name for body part.")
        case .appendage2:
            return NSLocalizedString("Appendage Two", comment: "Name for body part.")
        case .feet:
            return NSLocalizedString("Feet", comment: "Name for body part.")
        }
    }
    
    var possibleFinalProducts: [Thing] {
        switch self {
        case .head:
            return [.mechanicalWig, .extendoHat, .blu, .mushroomHelmet]
        case .face:
            return [.cyborgEyeballs, .stoneMask, .eagleSunglasses, .friedEggs]
        case .torso:
            return [.electricHoolahoop, .diamondJacket, .dragonWings, .snapPeaTutu]
        case .appendage1:
            return [.springLoadedFist, .spiralingStalactites, .octopusTentacle, .pumpkinHand]
        case .appendage2:
            return [.turboFanBladePropeller, .flowyRainbowRibbon, .flamingoBouquet, .meatballSleeve]
        case .feet:
            return [.purplePressurePistons, .chromeShredderWheels, .ostrichLegs, .glowingMushroomShoes]
        }
    }
    
    private var itemKey: String { return "EquippedItem.\(self.rawValue)" }
    
    var isEquipped: Bool { return self.equippedItem != nil }
    
    var equippedItem: Thing? {
        get {
            if let playgroundValue = PlaygroundKeyValueStore.current[itemKey] {
                return Thing(playgroundValue: playgroundValue)
            }
            return nil
        }
    }
    
    func setEquippedItem(_ item: Thing?) {
        PlaygroundKeyValueStore.current[itemKey] = item?.playgroundValue
    }
}

public enum EquipmentSet : Int, Codable {
    case mechanical = 0
    case fashion
    case life
    case food
    
    public var name: String {
        switch self {
        case .mechanical:
            return NSLocalizedString("Mechanical Set", comment: "Name for mechnical equipment set")
        case .fashion:
            return NSLocalizedString("Fashion Set", comment: "Name for fashion equipment set")
        case .life:
            return NSLocalizedString("Life Set", comment: "Name for life equipment set")
        case .food:
            return NSLocalizedString("Food Set", comment: "Name for food equipment set")
        }
    }
    
    var items: [Thing] {
        var returnItems = [Thing]()
        for bodyPart in Robot.bodyParts {
            if rawValue < bodyPart.possibleFinalProducts.count {
                returnItems.append(bodyPart.possibleFinalProducts[rawValue])
            }
        }
        return returnItems
    }
    
    var isForged: Bool {
        return items.map { $0.hasBeenForged }.reduce(true) { $0 && $1 }
    }
}

public struct Robot {
    public static var bodyParts: [BodyPart] = [.head, .face, .torso, .appendage1, .appendage2, .feet]
    
    static var equipmentSets: [EquipmentSet] = [.mechanical, .fashion, .life, .food]

    static func bodyPartThatCanBeEquipped(with item: Thing) -> BodyPart? {
        for bodyPart in bodyParts {
            if bodyPart.possibleFinalProducts.contains(item) {
                return bodyPart
            }
        }
        return nil
    }
    
    public static var equippedBodyParts: [BodyPart] {
        return bodyParts.filter( { $0.isEquipped} )
    }
    
    public static var isFullyEquipped: Bool {
        return (equippedBodyParts.count == bodyParts.count)
    }
    
    static var equippedItems: [Thing] {
        return equippedBodyParts.compactMap( { $0.equippedItem } )
    }
    
    static func isFullyEquippedWith(equipmentSet: EquipmentSet) -> Bool {
        guard equipmentSet.items.count == bodyParts.count else { return false}
        for bodyPart in bodyParts {
            if let equippedItem = bodyPart.equippedItem, equipmentSet.items.contains(equippedItem) {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    public static func resetState() {
        for bodyPart in bodyParts {
            bodyPart.setEquippedItem(nil)
        }
    }
}
