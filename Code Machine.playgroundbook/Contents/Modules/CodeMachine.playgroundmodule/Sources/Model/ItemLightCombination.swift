//
//  ItemLightCombination.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import Foundation

struct ItemCombination: Hashable {
    let a: Thing
    let b: Thing
}

struct ItemLightCombination: Hashable {
    let a: Thing
    let b: Thing
    let c: Light
}

// Item combination code generated from HoCCraftingCombinationTable.csv and CraftCSVToCode.py
let itemCombinationDictionary: [ItemCombination: Thing] = [
    ItemCombination(a: Thing.metal, b: Thing.stone) : Thing.spring,
    ItemCombination(a: Thing.cloth, b: Thing.metal) : Thing.wire,
    ItemCombination(a: Thing.dirt, b: Thing.metal) : Thing.spring,
    ItemCombination(a: Thing.DNA, b: Thing.metal) : Thing.cyborgEyeballs,
    ItemCombination(a: Thing.DNA, b: Thing.dirt) : Thing.tree,
    ItemCombination(a: Thing.DNA, b: Thing.stone) : Thing.egg,
    ItemCombination(a: Thing.metal, b: Thing.spring) : Thing.gear,
    ItemCombination(a: Thing.metal, b: Thing.wire) : Thing.spring,
    ItemCombination(a: Thing.metal, b: Thing.unidentifiedLifeForm) : Thing.cyborgEyeballs,
    ItemCombination(a: Thing.dirt, b: Thing.wire) : Thing.wire,
    ItemCombination(a: Thing.dirt, b: Thing.seed) : Thing.tree,
    ItemCombination(a: Thing.dirt, b: Thing.mushroom) : Thing.unidentifiedLifeForm,
    ItemCombination(a: Thing.dirt, b: Thing.unidentifiedLifeForm) : Thing.tree,
    ItemCombination(a: Thing.cloth, b: Thing.spring) : Thing.extendoHat,
    ItemCombination(a: Thing.cloth, b: Thing.wire) : Thing.spring,
    ItemCombination(a: Thing.cloth, b: Thing.tree) : Thing.seed,
    ItemCombination(a: Thing.cloth, b: Thing.gear) : Thing.extendoHat,
    ItemCombination(a: Thing.cloth, b: Thing.seed) : Thing.tree,
    ItemCombination(a: Thing.cloth, b: Thing.mushroom) : Thing.unidentifiedLifeForm,
    ItemCombination(a: Thing.cloth, b: Thing.unidentifiedLifeForm) : Thing.mushroom,
    ItemCombination(a: Thing.stone, b: Thing.wire) : Thing.spring,
    ItemCombination(a: Thing.stone, b: Thing.unidentifiedLifeForm) : Thing.egg,
    ItemCombination(a: Thing.DNA, b: Thing.wire) : Thing.spring,
    ItemCombination(a: Thing.DNA, b: Thing.egg) : Thing.unidentifiedLifeForm,
    ItemCombination(a: Thing.DNA, b: Thing.tree) : Thing.seed,
    ItemCombination(a: Thing.DNA, b: Thing.mushroom) : Thing.unidentifiedLifeForm,
    ItemCombination(a: Thing.egg, b: Thing.spring) : Thing.ostrichLegs,
    ItemCombination(a: Thing.egg, b: Thing.tree) : Thing.seed,
    ItemCombination(a: Thing.egg, b: Thing.seed) : Thing.unidentifiedLifeForm,
    ItemCombination(a: Thing.tree, b: Thing.tree) : Thing.seed,
    ItemCombination(a: Thing.mushroom, b: Thing.tree) : Thing.dirt,
    ItemCombination(a: Thing.mushroom, b: Thing.seed) : Thing.dirt,
    ItemCombination(a: Thing.crystal, b: Thing.crystal) : Thing.stone,
    ItemCombination(a: Thing.unidentifiedLifeForm, b: Thing.unidentifiedLifeForm) : Thing.egg
]

let itemLightCombinationDictionary: [ItemLightCombination: Thing] = [
    ItemLightCombination(a: Thing.metal, b: Thing.metal, c: Light.red) : Thing.gear,
    ItemLightCombination(a: Thing.dirt, b: Thing.stone, c: Light.green) : Thing.seed,
    ItemLightCombination(a: Thing.dirt, b: Thing.stone, c: Light.blue) : Thing.crystal,
    ItemLightCombination(a: Thing.cloth, b: Thing.stone, c: Light.blue) : Thing.stoneMask,
    ItemLightCombination(a: Thing.stone, b: Thing.stone, c: Light.blue) : Thing.stoneMask,
    ItemLightCombination(a: Thing.stone, b: Thing.stone, c: Light.red) : Thing.crystal,
    ItemLightCombination(a: Thing.DNA, b: Thing.stone, c: Light.red) : Thing.brick,
    ItemLightCombination(a: Thing.DNA, b: Thing.DNA, c: Light.green) : Thing.seed,
    ItemLightCombination(a: Thing.metal, b: Thing.spring, c: Light.red) : Thing.electricHoolahoop,
    ItemLightCombination(a: Thing.metal, b: Thing.wire, c: Light.red) : Thing.electricHoolahoop,
    ItemLightCombination(a: Thing.metal, b: Thing.wire, c: Light.green) : Thing.mechanicalWig,
    ItemLightCombination(a: Thing.egg, b: Thing.metal, c: Light.red) : Thing.friedEggs,
    ItemLightCombination(a: Thing.gear, b: Thing.metal, c: Light.red) : Thing.chromeShredderWheels,
    ItemLightCombination(a: Thing.crystal, b: Thing.metal, c: Light.blue) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.metal, b: Thing.mushroom, c: Light.blue) : Thing.mushroomHelmet,
    ItemLightCombination(a: Thing.dirt, b: Thing.egg, c: Light.green) : Thing.flamingoBouquet,
    ItemLightCombination(a: Thing.dirt, b: Thing.seed, c: Light.green) : Thing.pumpkinHand,
    ItemLightCombination(a: Thing.dirt, b: Thing.mushroom, c: Light.blue) : Thing.glowingMushroomShoes,
    ItemLightCombination(a: Thing.dirt, b: Thing.mushroom, c: Light.green) : Thing.glowingMushroomShoes,
    ItemLightCombination(a: Thing.cloth, b: Thing.wire, c: Light.blue) : Thing.extendoHat,
    ItemLightCombination(a: Thing.cloth, b: Thing.gear, c: Light.red) : Thing.turboFanBladePropeller,
    ItemLightCombination(a: Thing.cloth, b: Thing.seed, c: Light.green) : Thing.snapPeaTutu,
    ItemLightCombination(a: Thing.cloth, b: Thing.crystal, c: Light.blue) : Thing.flowyRainbowRibbon,
    ItemLightCombination(a: Thing.cloth, b: Thing.crystal, c: Light.red) : Thing.diamondJacket,
    ItemLightCombination(a: Thing.cloth, b: Thing.mushroom, c: Light.green) : Thing.glowingMushroomShoes,
    ItemLightCombination(a: Thing.cloth, b: Thing.mushroom, c: Light.blue) : Thing.flowyRainbowRibbon,
    ItemLightCombination(a: Thing.cloth, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.dragonWings,
    ItemLightCombination(a: Thing.cloth, b: Thing.unidentifiedLifeForm, c: Light.red) : Thing.meatballSleeve,
    ItemLightCombination(a: Thing.spring, b: Thing.stone, c: Light.red) : Thing.springLoadedFist,
    ItemLightCombination(a: Thing.egg, b: Thing.stone, c: Light.green) : Thing.dragonWings,
    ItemLightCombination(a: Thing.gear, b: Thing.stone, c: Light.red) : Thing.chromeShredderWheels,
    ItemLightCombination(a: Thing.crystal, b: Thing.stone, c: Light.blue) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.DNA, b: Thing.spring, c: Light.green) : Thing.ostrichLegs,
    ItemLightCombination(a: Thing.DNA, b: Thing.egg, c: Light.green) : Thing.flamingoBouquet,
    ItemLightCombination(a: Thing.DNA, b: Thing.tree, c: Light.green) : Thing.mushroom,
    ItemLightCombination(a: Thing.DNA, b: Thing.seed, c: Light.green) : Thing.pumpkinHand,
    ItemLightCombination(a: Thing.DNA, b: Thing.crystal, c: Light.blue) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.DNA, b: Thing.crystal, c: Light.green) : Thing.octopusTentacle,
    ItemLightCombination(a: Thing.DNA, b: Thing.unidentifiedLifeForm, c: Light.blue) : Thing.blu,
    ItemLightCombination(a: Thing.DNA, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.flamingoBouquet,
    ItemLightCombination(a: Thing.spring, b: Thing.wire, c: Light.red) : Thing.electricHoolahoop,
    ItemLightCombination(a: Thing.spring, b: Thing.wire, c: Light.blue) : Thing.extendoHat,
    ItemLightCombination(a: Thing.spring, b: Thing.tree, c: Light.red) : Thing.purplePressurePistons,
    ItemLightCombination(a: Thing.gear, b: Thing.spring, c: Light.red) : Thing.purplePressurePistons,
    ItemLightCombination(a: Thing.crystal, b: Thing.spring, c: Light.red) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.spring, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.octopusTentacle,
    ItemLightCombination(a: Thing.wire, b: Thing.wire, c: Light.red) : Thing.electricHoolahoop,
    ItemLightCombination(a: Thing.wire, b: Thing.wire, c: Light.green) : Thing.mechanicalWig,
    ItemLightCombination(a: Thing.egg, b: Thing.wire, c: Light.green) : Thing.eagleSunglasses,
    ItemLightCombination(a: Thing.gear, b: Thing.wire, c: Light.green) : Thing.mechanicalWig,
    ItemLightCombination(a: Thing.seed, b: Thing.wire, c: Light.green) : Thing.snapPeaTutu,
    ItemLightCombination(a: Thing.crystal, b: Thing.wire, c: Light.blue) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.unidentifiedLifeForm, b: Thing.wire, c: Light.blue) : Thing.octopusTentacle,
    ItemLightCombination(a: Thing.egg, b: Thing.tree, c: Light.green) : Thing.ostrichLegs,
    ItemLightCombination(a: Thing.egg, b: Thing.tree, c: Light.blue) : Thing.eagleSunglasses,
    ItemLightCombination(a: Thing.egg, b: Thing.gear, c: Light.green) : Thing.mechanicalWig,
    ItemLightCombination(a: Thing.crystal, b: Thing.egg, c: Light.green) : Thing.dragonWings,
    ItemLightCombination(a: Thing.egg, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.flamingoBouquet,
    ItemLightCombination(a: Thing.gear, b: Thing.tree, c: Light.red) : Thing.purplePressurePistons,
    ItemLightCombination(a: Thing.seed, b: Thing.tree, c: Light.green) : Thing.mushroom,
    ItemLightCombination(a: Thing.tree, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.mushroom,
    ItemLightCombination(a: Thing.crystal, b: Thing.gear, c: Light.red) : Thing.purplePressurePistons,
    ItemLightCombination(a: Thing.gear, b: Thing.mushroom, c: Light.blue) : Thing.mushroomHelmet,
    ItemLightCombination(a: Thing.seed, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.snapPeaTutu,
    ItemLightCombination(a: Thing.crystal, b: Thing.mushroom, c: Light.blue) : Thing.spiralingStalactites,
    ItemLightCombination(a: Thing.crystal, b: Thing.unidentifiedLifeForm, c: Light.green) : Thing.octopusTentacle,
    ItemLightCombination(a: Thing.unidentifiedLifeForm, b: Thing.unidentifiedLifeForm, c: Light.blue) : Thing.blu
]
