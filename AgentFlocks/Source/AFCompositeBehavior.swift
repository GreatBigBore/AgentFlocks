//
// Created by Rob Bishop on 1/3/18
//
// Copyright © 2018 Rob Bishop
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import GameplayKit

class AFCompositeBehavior_Script: Codable {
    var enabled = true
    var behaviors: [AFBehavior_Script]
}

class AFCompositeBehavior: GKCompositeBehavior {
    var enabled = true
    var savedState: (weight: Float, behavior: GKBehavior)?
    
    init(prototype: AFCompositeBehavior_Script, agent: AFAgent2D) {
        
        enabled = prototype.enabled
        
        super.init()
        
        for protoBehavior in prototype.behaviors {
            let newBehavior = AFBehavior(prototype: protoBehavior, agent: agent)
            
            // Note: attaches new behavior to the composite
            setWeight(newBehavior.weight, for: newBehavior)
        }
    }
    
    init(agent: AFAgent2D) {
        enabled = true
    }
    
    func addBehavior(_ newBehavior: AFBehavior) {
        setWeight(newBehavior.weight, for: newBehavior)
    }
    
    func enableBehavior(behavior: AFBehavior, on: Bool = true) {
        if on {
            enabled = true
            
            setWeight(savedState!.weight, for: savedState!.behavior)
            savedState = nil
        } else {
            enabled = false
            
            let weight = self.weight(for: behavior)
            savedState = (weight: weight, behavior: behavior)
            
            remove(behavior)
        }
    }
    
    func getChild(at index: Int) -> AFBehavior {
        return self[index] as! AFBehavior
    }
    
    func hasChildren() -> Bool {
        return behaviorCount > 0
    }
    
    func howManyChildren() -> Int {
        return behaviorCount
    }
    
    func toString() -> String {
        return "You've found a bug"
    }
}
