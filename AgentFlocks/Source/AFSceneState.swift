//
// Created by Rob Bishop on 1/19/18
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

protocol AFSceneUIState {
    func click(name: String?, flags: NSEvent.ModifierFlags?)
    func deselect(_ name: String)
    func deselectAll()
    func flagsChanged(to newFlags: NSEvent.ModifierFlags)
    func mouseMove(to position: CGPoint)
    func select(_ index: Int, primary: Bool)
    func select(_ name: String, primary: Bool)
    func updateDrawIndicator(_ position: CGPoint)
}

extension AFSceneUI {
    var drone: AFSceneUIState { return currentState! as! AFSceneUIState }
    
    func mouseUp(name: String?, flags: NSEvent.ModifierFlags?) {
        upNodeName = name
        guard upNodeName == downNodeName else { return }
        
        downNodeName = nil
        
        drone.click(name: name, flags: flags)
    }
    
    class BaseState: GKState, AFSceneUIState {
        let sceneUI: AFSceneUI
        
        init(sceneUI: AFSceneUI) {
            self.sceneUI = sceneUI
            super.init()
        }
        
        func click(name: String?, flags: NSEvent.ModifierFlags?) {}
        func deselect(_ name: String) {}
        func deselectAll() {}

        func flagsChanged(to newFlags: NSEvent.ModifierFlags) {
            showFullPathHandle(allPaths: true, show: true)
        }
        
        func showFullPathHandle(allPaths: Bool, show: Bool) {
            if allPaths {
                sceneUI.data.paths.forEach { $0.showPathHandle(show) }
            } else {
                sceneUI.activePath?.showPathHandle(show)
            }
        }

        func mouseMove(to position: CGPoint) {}
        func select(_ index: Int, primary: Bool) {}
        func select(_ name: String, primary: Bool) {}
        
        func updateDrawIndicator(_ position: CGPoint) { }
    }
}