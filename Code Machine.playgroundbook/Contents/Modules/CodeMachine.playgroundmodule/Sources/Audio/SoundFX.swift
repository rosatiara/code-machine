//
//  SoundFX.swift
//  
//  Copyright © 2016-2020 Apple Inc. All rights reserved.
//

import Foundation
import AVFoundation
import SPCAudio
import PlaygroundSupport

/// Plays the given sound. Optionally specify a volume from 0 (silent) to 100 (loudest), with 80 being the default.
///
/// - Parameter sound: The sound to play.
/// - Parameter volume: The volume for the sound, ranging from 0 to 100.
///
/// - localizationKey: playSoundFX(_:volume:)
public func playSoundFX(_ sound: SoundFX, volume: Int = 80) {
    guard
        audioController.isBackgroundAudioEnabled,
        let url = sound.url
        else { return }

    // NOTE: We are testing the isBackgroundAudioEnabled property
    //       because Code Machine is using the SPCAudio mute switch
    //       in toggleBackgroundAudioOnly mode to toggle all audio.
    //
    //       Code Machine has had a simple mute switch in the past,
    //       and that is what people expect.

    audioController.playSound(url, volume: volume)
}

public enum SoundFX: Sound, Codable {
    
    case clank, entering3, entering4, equipped1, equipped2, lightSwitchOn, newIngredient1, newIngredient2, newIngredient3, newIngredient5, newIngredient6, newIngredient7, newIngredient8, newIngredient9, newIngredient10, processing1, processing2, processing3, processing4, processing8, stretchProcess, huffProcess, switch1, switch2, whistle, poppingOut1, poppingOut2, poppingOut3, poppingOut4, brick1, brick2, brick3, brick4, finalProduct1, finalProduct2, finalProduct3, finalProduct4, finalProduct5, finalProduct6, finalProduct7, machineIdling1, itemRemoved1, itemRemoved2, tray1, tray2, tray3, tray4, oldProduct1, oldProduct2, machineNoise1, machineNoise2, machineNoise3, machineNoise4, machineNoise5, machineNoise6, machineNoise7, machineNoise8, machineNoise9, machineNoise10, fastForging1, fastForging2, fastForging3, fastEntering, vocalHello, vocalHiThere, vocalCongrats, vocalMiniGrats, vocalExcuseMe, idleVocal1, idleVocal2, idleVocal3, idleVocal4, celebration
    
    var fileName : String {
        switch self {
        case .tray1:
            return "Organic Attach_001"
        case .tray2:
            return "Organic Attach_002"
        case .tray3:
            return "Organic Attach_005"
        case .tray4:
            return "Organic Attach_008"
        case .clank:
            return "Clank"
        case .entering3:
            return "entering1"
        case .entering4:
            return "entering2"
        case .equipped1:
            return "itemEquipped1"
        case .equipped2:
            return "itemEquipped2"
        case .finalProduct1:
            return "finalProduct1"
        case .finalProduct2:
            return "finalProduct2"
        case .finalProduct3:
            return "finalProduct3"
        case .finalProduct4:
            return "finalProduct4"
        case .finalProduct5:
            return "finalProduct5"
        case .finalProduct6:
            return "092717_New final product created, electronic rkv1"
        case .finalProduct7:
            return "092717_New final product created, electronic rkv2"
        case .lightSwitchOn:
            return "Light_Switch_On"
        case .newIngredient1:
            return "New_Ingredient_001"
        case .newIngredient2:
            return "New_Ingredient_002"
        case .newIngredient3:
            return "New_Ingredient_003"
        case .oldProduct1:
            return "Organic Attach_012"
        case .oldProduct2:
            return "Organic Attach_013"
        case .newIngredient5:
            return "newIngredient5"
        case .newIngredient6:
            return "newIngredient6"
        case .newIngredient7:
            return "newIngredient7"
        case .newIngredient8:
            return "newIngredient8"
        case .newIngredient9:
            return "newIngredient9"
        case .newIngredient10:
            return "newIngredient10"
        case .machineIdling1:
            return "machineIdling1"
        case .brick1:
            return "Comedy_Low_Honk"
        case .brick2:
            return "brick2"
        case .brick3:
            return "brick3"
        case .brick4:
            return "brick4"
        case .processing1:
            return "Processing_001"
        case .processing2:
            return "Processing_002"
        case .processing3:
            return "Processing_003"
        case .processing4:
            return "Processing_004"
        case .processing8:
            return "Processing_008"
        case .stretchProcess:
            return "Stretch_Process_001"
        case .huffProcess:
            return "Huff_Process_001"
        case .switch1:
            return "Switch_001"
        case .switch2:
            return "Light_Switch_001"
        case .whistle:
            return "Comedy_Whistle"
        case .poppingOut1:
            return "poppingOut1short"
        case .poppingOut2:
            return "poppingOut2short"
        case .poppingOut3:
            return "poppingOut3short"
        case .poppingOut4:
            return "poppingOut4short"
        case .itemRemoved1:
            return "itemRemoved1"
        case .itemRemoved2:
            return "itemRemoved2"
        case .machineNoise1:
            return "092917_Machine noise rkv1"
        case .machineNoise2:
            return "092917_Machine noise rkv2"
        case .machineNoise3:
            return "Machine Noises_001"
        case .machineNoise4:
            return "Machine Noises_002"
        case .machineNoise5:
            return "Machine Noises_005"
        case .machineNoise6:
            return "092917_Machine noise rkv6"
        case .machineNoise7:
            return "092917_Machine noise rkv7"
        case .machineNoise8:
            return "092717_Random machine sounds rkv1"
        case .machineNoise9:
            return "092717_Random machine sounds rkv2"
        case .machineNoise10:
            return "092717_Random machine sounds rkv3"
        case .fastForging1:
            return "fastForging1"
        case .fastForging2:
            return "fastForging2"
        case .fastForging3:
            return "fastForging3"
        case .fastEntering:
            return "fastEntering"
        case .vocalHello:
            return "vocalHello"
        case .vocalHiThere:
            return "vocalHiThere"
        case .vocalCongrats:
            return "vocalCongrats"
        case .vocalMiniGrats:
            return "vocalMiniGrats"
        case .vocalExcuseMe:
            return "vocalExcuseMe"
        case .idleVocal1:
            return "idleVocal1"
        case .idleVocal2:
            return "idleVocal2"
        case .idleVocal3:
            return "idleVocal3"
        case .idleVocal4:
            return "idleVocal4"
        case .celebration:
            return "Up_Sweeper"
        }
    }
    
    var resourcePath: String {
        return "Sounds/\(fileName)"
    }
    
    var url: URL? {
        return Bundle.main.url(forResource: resourcePath, withExtension: "m4a")
    }
    
    // The machine appears
    static var machineAppearingSound: SoundFX { return [.machineNoise4].randomItem }

    // First, items are taken from the tray
    static var addItemSound: SoundFX { return [.tray1, .tray2, .tray3, .tray4].randomItem }
    
    static var currentAddItemSound: SoundFX = .tray1
    
    // Second, items enter into the funnel (this will occur in sequence with the tray sound for each item)
    static var enteringFunnel: SoundFX { return [.entering3, .entering4].randomItem }
    
    // A light is switched on, if applicable.
    static var switchLight: SoundFX { return .switch2 }
    
    // The machine then processes the items
    static var forgingSound: SoundFX { return [.stretchProcess, .huffProcess, .processing1, .processing2, .processing3, .processing4, .processing8].randomItem }
    
    // The machine then processes the items faster
    static var fastForgingSound: SoundFX { return [.fastForging1, .fastForging2, .fastForging3].randomItem }

    // The machine then shoots the product out
    static var poppingOut: SoundFX { return [.poppingOut1, .poppingOut2, .poppingOut3, .poppingOut4].randomItem }
    
    // Depending on the product, a different sound plays
    static var forgedBrickSound: SoundFX { return [.brick1, .brick2, .brick3, .brick4].randomItem }
    
    static var forgedBaseMaterialSound: SoundFX { return .newIngredient3 }
    
    static var forgedNewSecondaryItemSound: SoundFX { return [.newIngredient5, .newIngredient6, .newIngredient7, .newIngredient7, .newIngredient8, .newIngredient9, .newIngredient10].randomItem}
    static var forgedSecondaryItemSound: SoundFX { return [.oldProduct1, .oldProduct2].randomItem }
    
    static var forgedFinalProductSound: SoundFX { return [.finalProduct1, .finalProduct2, .finalProduct3, .finalProduct4, .finalProduct5, .finalProduct6, .finalProduct7].randomItem }
    static var forgedOldFInalProductSound: SoundFX { return [.newIngredient1, .newIngredient2].randomItem }
    
    
    // Equipping and Unequipping
    static var equippedItemSound: SoundFX { return [.equipped1, .equipped2].randomItem }
    static var removedItemSound: SoundFX { return [.itemRemoved1, .itemRemoved2].randomItem }
    
    // Idling
    static var idling: SoundFX { return .machineIdling1 }
    static var idlingVocalization: SoundFX { return [.machineNoise10, .vocalHello, .vocalExcuseMe, .idleVocal1, .idleVocal2, .idleVocal3, .idleVocal4].randomItem }

    // Random machine sounds (
    static var machineSounds: SoundFX { return [.machineNoise1, .machineNoise2, .machineNoise3, .machineNoise9].randomItem }
    
    // Congrats
    public static var congrats: SoundFX { return [.vocalMiniGrats, .machineNoise5, .vocalHiThere, .vocalExcuseMe].randomItem }

    // Vocalizations (could be used after tap gestures or when a successful assessment has occurred)
    public static var machineVocalizations: SoundFX { return [.machineNoise4, .machineNoise5, .machineNoise6, .machineNoise7, .machineNoise8, .machineNoise10].randomItem }
    
    static func playForgedSound(for forgedItem: ForgedItem) {
        // Play the appropriate sound.
        if forgedItem.item == .brick {
            playSoundFX(.forgedBrickSound)
        } else if forgedItem.item.isBaseMaterial {
            playSoundFX(.forgedBaseMaterialSound)
        } else if forgedItem.item.isFinalProduct {
            if forgedItem.isForgedFirstTime {
                playSoundFX(.forgedFinalProductSound)
            } else {
                playSoundFX(.forgedOldFInalProductSound)
            }
        } else if forgedItem.item.isSecondaryItem {
            if forgedItem.isForgedFirstTime {
                playSoundFX(.forgedNewSecondaryItemSound)
            } else {
                playSoundFX(.forgedSecondaryItemSound)
            }
        } else {
            playSoundFX(.clank)
        }
    }

}
