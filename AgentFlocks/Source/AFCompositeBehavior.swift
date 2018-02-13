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

class AFCompositeBehavior: GKCompositeBehavior {
    unowned let core: AFCore
    var editor: AFCompositeEditor!
    unowned let notifications: Foundation.NotificationCenter
    var savedState: (weight: Float, behavior: GKBehavior)?
    var saveMap = [AFBehavior: Float]()
    
    init(core: AFCore, editor: AFCompositeEditor) {
        self.core = core
        self.notifications = core.bigData.notifier
        
        super.init()
        
        let n = Foundation.Notification.Name.CoreTreeUpdate
        self.notifications.addObserver(self, selector: #selector(aBehaviorHasBeenCreated(notification:)), name: n, object: core)
    }
    
    @objc func aBehaviorHasBeenCreated(notification: Foundation.Notification) {
    }
}

extension AFCompositeBehavior {

    func enableBehavior(_ behavior: AFBehavior, on: Bool = true) {
        if on {
            // Although we're simply reloading data from the core json, the load function
            // will announce the rejuvenated editor as though it's a new behavior, so as
            // to be picked up by the regular notification mechanism.
//            self.editor.reloadBehavior(name: behavior.name)
        } else {
            // We don't have to save our own state; the behavior is still there in the
            // core json. So we just have to turn it off in the behaviors mechanism.
            remove(behavior)
            
            // Do we need to announce the removal? I think we do.
        }
    }

    func findParent(of theGoal: GKGoal) -> AFBehavior? {
        
        for i in 0 ..< behaviorCount {
            let behavior = self[i] as! AFBehavior
            if behavior.getAFGoalForGKGoal(theGoal) != nil {
                return behavior
            }
        }
        
        return nil
    }

    func getChild(at index: Int) -> AFBehavior { return self[index] as! AFBehavior }
    func hasChildren() -> Bool { return behaviorCount > 0 }
    func howManyChildren() -> Int { return behaviorCount }
    func toString() -> String { return "toString() not implemented for AFCompositeBehavior. Sue me." }
}

