import PlaygroundSupport
import Foundation

public class Page1Assessment: Evaluator {
    
    public init() { }
    
    var createdNewEyes = false
    var createdHat = false
    var passedSpring = false
    
    let learningTrails = LearningTrailsProxy()
    
    let checker = ContentsChecker(contents: PlaygroundPage.current.text)
    
    // Conform to Evaluator - messages is how we'll send hints based upon runtime data.
    public var successMessage: String? = nil
    
    public func failureMessage() -> FailureMessage? {
        
        return FailureMessage(hints: [], solution: nil)
    }
    public var messages: [AssessmentMessage] = []
    
    
    public func evaluate(assessmentInfo: AssessmentInfo) -> Bool? {
        
        var pageExecutionCompleted = false
        
        if checker.passedArguments.contains(".spring") {
            passedSpring = true
        }
        
        for event in assessmentInfo.events {
            if case .forgedItem(let forgedItem) = event {
                
                if forgedItem.item == Thing.cyborgEyeballs && !createdNewEyes {
                    // Passed step 3
                    createdNewEyes = true
                    learningTrails.sendMessageOnce("newEyes-success")
                    learningTrails.setAssessment("newEyes", passed: true)
                    playSoundInLiveView(SoundFX.congrats)
                } else if (forgedItem.item == Thing.ostrichLegs || forgedItem.item == Thing.extendoHat) && !createdHat {
                    createdHat = true
                    let extendoHatSuccess = String(format: NSLocalizedString("<b>Woo-hoo! %1$@!</b>\n\nYou passed in %2$@ and %3$@. Can you think of a reason why the machine created what it did (%4$@)? Passing in <a href=\"glossary://argument\">arguments</a> lets you customize a function to do something different, depending on what you give it. That’s quite handy!\n\n<a href=\"@next\">Next</a>", comment: "Created one of the goal items"), forgedItem.item.name, String(describing: forgedItem.recipe.itemA), String(describing: forgedItem.recipe.itemB), forgedItem.item.name)
                    messages.append(AssessmentMessage(name: "somethingStylish", content: extendoHatSuccess, passed: true, sentOnce: true))
                    
                    playSoundInLiveView(SoundFX.congrats)
                    
                } else if learningTrails.currentStep == "newEyes" && forgedItem.item.isFinalProduct && !createdNewEyes  {
                    // Created a different final product than eyes, but we want them to keep trying to create the ones we ask for.
                    let thingName: String = forgedItem.item.name
                    let forTheFirstTime = forgedItem.isForgedFirstTime ? NSLocalizedString(" for the first time", comment: "") : ""
                    let forgedSomethingOtherThanEyes = String(format: NSLocalizedString("<b>Phenomenal job!</b>\n\n You created %1$@%2$@! You must be pretty good at using the machine. Now can you try to make the machine some metallic eyes?  \n\n<a href=\"@nextStep\">Next</a>", comment: "Forged something other than cyborg eyeballs"), thingName, forTheFirstTime)
                    messages.append(AssessmentMessage(name: "newEyes", content: forgedSomethingOtherThanEyes, passed: false, sentOnce: false))
                } else if learningTrails.currentStep == "somethingStylish" && forgedItem.item.isFinalProduct && forgedItem.item != Thing.extendoHat && forgedItem.item != Thing.cyborgEyeballs  {
                    // Created a different final product than hat, but we want them to keep trying to create the ones we ask for.
                    let thingName: String = forgedItem.item.name
                    let forTheFirstTime = forgedItem.isForgedFirstTime ? NSLocalizedString(" for the first time", comment: "") : ""
                    let forgedSomethingOtherThanHat = String(format: NSLocalizedString("<b>Awesome work!</b>\n\n You created %1$@%2$@! Now how about creating the machine a new hat?\n\n<a href=\"@next\">Next</a>", comment: "Forged something other than extendo hat"), thingName, forTheFirstTime)
                    messages.append(AssessmentMessage(name: "somethingStylish", content: forgedSomethingOtherThanHat, passed: false, sentOnce: false))
                }
            } else if case .pageExecutionCompleted = event {
                pageExecutionCompleted = true
            }
            
            
        }
        
        if pageExecutionCompleted {
            if (Thing.ostrichLegs.hasBeenForged || Thing.extendoHat.hasBeenForged) && !createdHat {
                createdHat = true
                learningTrails.sendMessageOnce("somethingStylish-success2")
                learningTrails.setAssessment("somethingStylish", passed: true)
                playSoundInLiveView(SoundFX.congrats)
            }
            
            if Thing.cyborgEyeballs.hasBeenForged && !createdNewEyes {
                learningTrails.sendMessageOnce("newEyes-success")
                learningTrails.setAssessment("newEyes", passed: true)
            }
            
            if learningTrails.currentStep == "firstRun" {
                learningTrails.sendMessageOnce("firstRun-success")
                learningTrails.setAssessment("firstRun", passed: true)
            }
            
            if learningTrails.currentStep == "newEyes" && !createdNewEyes {
                if learningTrails.hasSentMessage("newEyes-hint") {
                    learningTrails.sendMessageOnce("newEyes-hint2")
                }
                learningTrails.sendMessageOnce("newEyes-hint")
            }
            
            if learningTrails.currentStep == "somethingStylish" && !createdHat {
                if !passedSpring {
                    learningTrails.sendMessageOnce("somethingStylish-hint1")
                    
                } else {
                    learningTrails.sendMessageOnce("somethingStylish-hint2")
                }
            }
            
        }
        
        return false
        
    }
}


public class Page3Assessment: Evaluator {
    
    public init() { }
    
    let learningTrails = LearningTrailsProxy()
    
    var madeCrystal = false
    var madeArm = false
    var madePumpkinHand = false
    var usedCrystal = false
    var usedSeedAndDirt = false
    
    let checker = ContentsChecker(contents: PlaygroundPage.current.text)
    
    // Conform to Evaluator - messages is how we'll send hints based upon runtime data.
    public var successMessage: String? = nil
    
    public func failureMessage() -> FailureMessage? {
        
        return FailureMessage(hints: [], solution: nil)
    }
    public var messages: [AssessmentMessage] = []
    
    public func evaluate(assessmentInfo: AssessmentInfo) -> Bool? {
        var pageExecutionCompleted = false
        
        if checker.passedArguments.contains(".crystal") {
            usedCrystal = true
        }
        
        if checker.passedArguments.contains(".seed") && checker.passedArguments.contains(".dirt")  {
            usedSeedAndDirt = true
        }
        
        for event in assessmentInfo.events {
            if case .forgedItem(let forgedItem) = event {
                if (forgedItem.item == Thing.flowyRainbowRibbon || forgedItem.item == Thing.spiralingStalactites || forgedItem.item == Thing.octopusTentacle) && !madeArm {
                    madeArm = true
                    let forgedCorrectProduct = String(format: NSLocalizedString("<b>You created: %1$@!</b>\n\nYou’re learning quickly! Here are some quick tips for using colors to forge items:\n\n * <b>Red light</b>: Heats items. Good for making mechanical objects.\n\n * <b>Blue light</b>: Cools and transforms items. Good for making clothing.\n\n * <b>Green light</b>: Gives life. Good for making living things.\n\n<a href=\"@nextStep\"><b>Next</b></a>", comment: "Created the ribbon, stalactites, or tentacle."), forgedItem.item.name)
                    messages.append(AssessmentMessage(name: "newArms", content: forgedCorrectProduct, passed: true, sentOnce: true))
                    playSoundInLiveView(SoundFX.congrats)
                }
                
                if forgedItem.item == Thing.pumpkinHand && !madePumpkinHand {
                    madePumpkinHand = true
                    learningTrails.sendMessageOnce("grow-success")
                    learningTrails.setAssessment("grow", passed: true)
                    playSoundInLiveView(SoundFX.congrats)
                }
                
                if forgedItem.item == Thing.crystal && !madeCrystal {
                    madeCrystal = true
                    learningTrails.sendMessageOnce("combiningColors-success")
                    learningTrails.setAssessment("combiningColors", passed: true)
                }
            } else if case .pageExecutionCompleted = event {
                pageExecutionCompleted = true
            }
        }
        
        if pageExecutionCompleted {
            if (Thing.flowyRainbowRibbon.hasBeenForged || Thing.spiralingStalactites.hasBeenForged || Thing.octopusTentacle.hasBeenForged) && !madeArm && learningTrails.currentStep == "newArms" {
                madeArm = true
                learningTrails.sendMessageOnce("newArms-success")
                learningTrails.setAssessment("newArms", passed: true)
                playSoundInLiveView(SoundFX.congrats)
            }
            
            if Thing.pumpkinHand.hasBeenForged && !madePumpkinHand {
                madePumpkinHand = true
                learningTrails.sendMessageOnce("grow-success")
                learningTrails.setAssessment("grow", passed: true)
                playSoundInLiveView(SoundFX.congrats)
            }
            
            if !madeCrystal && learningTrails.currentStep == "combiningColors" {
                learningTrails.sendMessageOnce("combiningColors-hint")
            }
            
            if !madeArm && learningTrails.currentStep == "newArms" {
                if !usedCrystal {
                    learningTrails.sendMessageOnce("newArms-hint2")
                } else {
                    learningTrails.sendMessageOnce("newArms-hint")
                }
            }
            
            if !madePumpkinHand && learningTrails.currentStep == "grow" {
                if usedSeedAndDirt {
                    learningTrails.sendMessageOnce("grow-hint2")
                } else {
                    learningTrails.sendMessageOnce("grow-hint1")
                }
            }
            
        }
        return false
    }
}

public class Page4Assessment: Evaluator {
    
    public init() { }
    
    var forgedFinal = false
    var ranInitialLoop = false
    
    let learningTrails = LearningTrailsProxy()
    
    let checker = ContentsChecker(contents: PlaygroundPage.current.text)

    
    // Conform to Evaluator - messages is how we'll send hints based upon runtime data.
    public var successMessage: String? = nil
    
    public func failureMessage() -> FailureMessage? {
        
        return FailureMessage(hints: [], solution: nil)
    }
    public var messages: [AssessmentMessage] = []
    
    public func evaluate(assessmentInfo: AssessmentInfo) -> Bool? {
        var pageExecutionCompleted = false
        
        let possibleFinalProducts: [Thing] = [.mushroomHelmet, .mechanicalWig, .chromeShredderWheels, .blu, .friedEggs, .stoneMask, .eagleSunglasses, .diamondJacket, .dragonWings, .snapPeaTutu, .electricHoolahoop, .springLoadedFist, .turboFanBladePropeller, .flamingoBouquet, .meatballSleeve, .glowingMushroomShoes, .purplePressurePistons]
        
        for event in assessmentInfo.events {
            if case .forgedItem(let forgedItem) = event {
                
                if forgedItem.item.isFinalProduct && possibleFinalProducts.contains(forgedItem.item) && !forgedFinal {
                    forgedFinal = true
                    let forgedFinalText = String(format: NSLocalizedString("<b>Huzzah! You created: %1$@!</b>\n\n<a href=\"glossary://loop\">Loops</a> sure make things faster, don’t they? If you’re feeling adventurous, you could also try putting one loop inside another, a process known as <a href=\"glossary://nest\">nesting</a>.\n\n<a href=\"@next\">Next</a>", comment: "Success for creating a new final product"), forgedItem.item.name)
                    messages.append(AssessmentMessage(name: "array", content: forgedFinalText, passed: true, sentOnce: true))
                    playSoundInLiveView(SoundFX.congrats)
                }
                
            } else if case .pageExecutionCompleted = event {
                pageExecutionCompleted = true
            }
        }
        
        if pageExecutionCompleted {
            if learningTrails.currentStep == "loop" && checker.hasForLoop {
                learningTrails.sendMessageOnce("loop-success")
                learningTrails.setAssessment("loop", passed: true)
            }
            
            if !forgedFinal && learningTrails.currentStep == "array" {
                if checker.accessedVariables.contains("items") {
                    learningTrails.sendMessageOnce("array-hint2")
                } else {
                    learningTrails.sendMessageOnce("array-hint1")
                }
            }
        }
        
        return false
    }
}

public class Page6Assessment: Evaluator {
    
    public init() { }
    
    let learningTrails = LearningTrailsProxy()
    
    let checker = ContentsChecker(contents: PlaygroundPage.current.text)
    
    var sentFinalSuccess = false
    var definedColorsArray = false
    var nestedLoops = false
    
    // Conform to Evaluator - messages is how we'll send hints based upon runtime data.
    public var successMessage: String? = nil
    
    public func failureMessage() -> FailureMessage? {
        
        return FailureMessage(hints: [], solution: nil)
    }
    public var messages: [AssessmentMessage] = []
    
    public func evaluate(assessmentInfo: AssessmentInfo) -> Bool? {
        var pageExecutionCompleted = false
        
        if checker.accessedVariables.contains("colors") {
            definedColorsArray = true
        }
        
        if checker.containsNestedLoop() {
            nestedLoops = true
        }
        
        if case .forgedItem(let forgedProduct) = assessmentInfo.events.last {
            if !Robot.isFullyEquipped && !sentFinalSuccess && forgedProduct.item.isFinalProduct && forgedProduct.isForgedFirstTime {
                let forgedProductHint = String(format: NSLocalizedString("<b>Yeehaw! You created: %1$@!</b>\n\nYou have equipped %2$@ out of 6 body parts. Keep going!", comment: "Created a final product"), forgedProduct.item.name, String(Robot.equippedBodyParts.count))
                learningTrails.sendMessage("nestedLoops", sender: "hopper", scope: "trail", content: forgedProductHint)
            }
        }
        
        
        for event in assessmentInfo.events {
            if case .forgedItem(let forgedItem) = event {
                if Robot.isFullyEquipped && !sentFinalSuccess {
                    sentFinalSuccess = true
                    learningTrails.sendMessageOnce("nestedLoops-success")
                    learningTrails.setAssessment("nestedLoops", passed: true)
                }
            } else if case .pageExecutionCompleted = event {
                pageExecutionCompleted = true
            }
        }
        
        if pageExecutionCompleted {
            if Robot.isFullyEquipped && !sentFinalSuccess {
                sentFinalSuccess = true
                learningTrails.sendMessageOnce("nestedLoops-success")
                learningTrails.setAssessment("nestedLoops", passed: true)
                playSoundInLiveView(SoundFX.vocalCongrats)
            }
            
            if !Robot.isFullyEquipped && !sentFinalSuccess {
                if !definedColorsArray && !nestedLoops {
                    learningTrails.sendMessageOnce("nestedLoops-hint1")
                } else if definedColorsArray && !nestedLoops {
                    learningTrails.sendMessageOnce("nestedLoops-hint2")
                } else {
                    learningTrails.sendMessageOnce("nestedLoops-hint3")
                }
            }
        }
        
        return false
    }
}
