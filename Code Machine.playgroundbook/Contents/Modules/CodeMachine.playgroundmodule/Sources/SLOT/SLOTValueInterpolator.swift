//
//  SLOTValueInterpolator.swift
//
// The source code contained in this file originated from 'lottie-ios' has been modified by Apple. The original source code is licensed under the Apache 2.0 license, available here:
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// and the original source code for 'lottie-ios' is available for download here:
//
//      https://github.com/airbnb/lottie-ios
//
// Modifications made by Apple are licensed under the Swift Playgrounds Software License, located at the root of this playground document.
//
// Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import CoreGraphics

class SLOTValueInterpolator {
    
    weak var leadingKeyframe: SLOTKeyframe?
    weak var trailingKeyframe: SLOTKeyframe?
    
    private var keyframes: [SLOTKeyframe]
    
    init(keyframes: [SLOTKeyframe]) {
        self.keyframes = keyframes
    }
    
    func keyframeData(for value: Any) -> Any? {
        print("\(#function): Unsupported Keyframe Data: \(value)")
        return nil
    }
    
    func set(value: Any, atFrame: Double?) -> Bool {
        guard let data = keyframeData(for: value) else { return false }
        
        let frame = (atFrame == nil) ? 0 : atFrame!
        
        updateKeyframeSpan(frame: frame)
        
        if frame == leadingKeyframe?.keyframeTime {
            let newKeyframe = leadingKeyframe!.copy(data: data)
            var keyframes = Array(self.keyframes)
            let idx = keyframes.firstIndex(of: leadingKeyframe!)!
            keyframes[idx] = newKeyframe
            leadingKeyframe = newKeyframe
            self.keyframes = keyframes
        } else if frame == trailingKeyframe?.keyframeTime {
            let newKeyframe = trailingKeyframe!.copy(data: data)
            var keyframes = Array(self.keyframes)
            let idx = keyframes.firstIndex(of: trailingKeyframe!)!
            keyframes[idx] = newKeyframe
            trailingKeyframe = newKeyframe
            self.keyframes = keyframes
        } else {
            
            // Is between leading and trailing. Either can be nil.
            // For now added keyframes will default to linear interpolation.
            let keyframeDict = ["s" : data, "t" : frame]
            let keyframe = SLOTKeyframe(keyframe: keyframeDict)
            var newKeyframes = Array(self.keyframes)
            if trailingKeyframe == nil || trailingKeyframe == newKeyframes.last {
                newKeyframes.append(keyframe)
            } else {
                let idx = newKeyframes.firstIndex(of: trailingKeyframe!)!
                newKeyframes.insert(keyframe, at: idx)
            }
            self.keyframes = newKeyframes
            leadingKeyframe = nil
            trailingKeyframe = nil
        }
        
        return true
    }
    
    func updateKeyframeSpan(frame: Double) {
        if leadingKeyframe == nil && trailingKeyframe == nil {
            let first = keyframes.first
            if let first = first, first.keyframeTime > 0 {
                trailingKeyframe = first
            } else {
                leadingKeyframe = first
                if keyframes.count > 1 {
                    trailingKeyframe = keyframes[1]
                }
            }
        }
        
        if let trailingKeyframe = trailingKeyframe, frame >= trailingKeyframe.keyframeTime {
            // Frame is after current span, can move forward
            var index = keyframes.firstIndex(of: trailingKeyframe)!
            var keyframeFound = false
            
            var testLeading: SLOTKeyframe = trailingKeyframe
            var testTrailing: SLOTKeyframe? = nil
            
            while keyframeFound == false {
                index += 1
                if index < keyframes.count {
                    testTrailing = keyframes[index]
                    if frame < testTrailing!.keyframeTime {
                        keyframeFound = true
                    } else {
                        testLeading = testTrailing!
                    }
                } else {
                    testTrailing = nil
                    keyframeFound = true
                }
            }
            self.leadingKeyframe = testLeading
            self.trailingKeyframe = testTrailing
        } else if let leadingKeyframe = leadingKeyframe, frame < leadingKeyframe.keyframeTime {
            // Frame is before current span, can move back a span
            var index = keyframes.firstIndex(of: leadingKeyframe)!
            var keyframeFound = false
            
            var testLeading: SLOTKeyframe? = nil
            var testTrailing: SLOTKeyframe = leadingKeyframe
            
            while keyframeFound == false {
                index -= 1
                if index >= 0 {
                    testLeading = keyframes[index]
                    if frame >= testLeading!.keyframeTime {
                        keyframeFound = true
                    } else {
                        testTrailing = testLeading!
                    }
                } else {
                    testLeading = nil
                    keyframeFound = true
                }
            }
            self.leadingKeyframe = testLeading
            self.trailingKeyframe = testTrailing
        }
    }
    
    func progress(frame: Double) -> CGFloat {
        updateKeyframeSpan(frame: frame)
        // At this point frame definitely exists between leading and trailing keyframes
        if leadingKeyframe?.keyframeTime == frame {
            // Frame is leading keyframe
            return 0
        }
        
        guard let trailingKeyframe = trailingKeyframe else {
            // Frame is after end of keyframe timeline
            return 0
        }
        
        if let leadingKeyframe = leadingKeyframe, leadingKeyframe.isHold {
            return 0
        }
        
        guard let leadingKeyframe = leadingKeyframe else {
            return 1
        }
        
        var progression = SLOT_RemapValue(value: CGFloat(frame), low1: CGFloat(leadingKeyframe.keyframeTime), high1: CGFloat(trailingKeyframe.keyframeTime), low2: 0, high2: 1)
        
        if (leadingKeyframe.outTangent.x != leadingKeyframe.outTangent.y ||
        trailingKeyframe.inTangent.x != trailingKeyframe.inTangent.y) &&
        (!SLOT_CGPointIsZero(leadingKeyframe.outTangent) &&
            !SLOT_CGPointIsZero(trailingKeyframe.inTangent)) {
            // Bezeir Time Curve
            progression = SLOT_CubicBezierInterpolate(P0: CGPoint(x: 0, y: 0), P1: leadingKeyframe.outTangent, P2: trailingKeyframe.inTangent, P3: CGPoint(x: 1, y: 1), x: progression)
        }
        
        return progression
        
    }
    
    func hasUpdate(frame: Double) -> Bool {
        
        /*
         Cases we dont update keyframe
         if time is in span and leading keyframe is hold
         if trailing keyframe is nil and time is after leading
         if leading keyframe is nil and time is before trailing
         */
        
        if let leadingKeyframe = leadingKeyframe, trailingKeyframe == nil, leadingKeyframe.keyframeTime < frame {
            return false
        }
        
        if let trailingKeyframe = trailingKeyframe, leadingKeyframe == nil, trailingKeyframe.keyframeTime > frame {
            return false
        }
        
        if let leadingKeyframe = leadingKeyframe, let trailingKeyframe = trailingKeyframe, leadingKeyframe.isHold && leadingKeyframe.keyframeTime < frame && trailingKeyframe.keyframeTime > frame {
            return false
        }
        
        return true
    }
}
