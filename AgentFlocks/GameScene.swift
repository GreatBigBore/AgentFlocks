//
// Created by Rob Bishop on 12/17/17.
//
// Copyright © 2017 Rob Bishop
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

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKViewDelegate {
    static var me: GameScene?

    var currentPosition: CGPoint?
    var downNodeIndex: Int?
    var entities = [AFEntity]()
    var graphs = [String : GKGraph]()
    var mouseState = MouseStates.up
    var mouseWasDragged = false
    var nodeToMouseOffset = CGPoint.zero
    var selectedIndexes = Set<Int>()
    var selectionState = SelectionStates.none
    var touchedNodes = [SKNode]()
    var upNodeIndex: Int?

    var lastUpdateTime : TimeInterval = 0
    
    var selectionIndicator: SKShapeNode!
    var multiSelectionIndicator: SKShapeNode!

    var corral = [SKShapeNode]()
    
    override func didMove(to view: SKView) {
        GameScene.me = self
    }

    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let w = 1500, h = 740/*frame.size.height*/
        let x = -w / 2/*frame.origin.x*/, y = -h / 2/*frame.origin.y*/
        
        selectionIndicator = SKShapeNode(circleOfRadius: 15)
        selectionIndicator.fillColor = .red
        
        multiSelectionIndicator = SKShapeNode(circleOfRadius: 15)
        multiSelectionIndicator.fillColor = .blue

        let adjustedOrigin = self.convertPoint(toView: CGPoint.zero)
        print(adjustedOrigin)
        
        let thickness = 50
        let offset = 0
        var specs: [(CGPoint, CGSize, NSColor)] = [
            (CGPoint(x: x, y: -y + thickness - offset), CGSize(width: w, height: thickness), .red),
            (CGPoint(x: -x - offset, y: y), CGSize(width: thickness, height: h), .yellow),
            (CGPoint(x: x, y: y + offset - 100), CGSize(width: w, height: thickness), .blue),
            (CGPoint(x: x - thickness + offset, y: y), CGSize(width: thickness, height: h), .green)
        ]
        
        func drawShape(_ ss: Int) {
            let shapeNode = SKShapeNode(rect: CGRect(origin: specs[ss].0, size: specs[ss].1))
            shapeNode.fillColor = specs[ss].2
            shapeNode.strokeColor = .black
            self.addChild(shapeNode)
            corral.append(shapeNode)
        }
        
        for i in 0..<4 { drawShape(i) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}

// MARK: mouse and selection handling

extension GameScene {
    enum MouseStates { case down, dragging, rightDown, rightUp, up }
    enum SelectionStates { case none, one, multi }

    func getAgent(at index: Int) -> AFAgent2D {
        let entity = entities[index]
        return entity.agent
    }

    func getNode(at point: CGPoint) -> Int? {
        var nodeIndex: Int?
        
        for (index, entity) in entities.enumerated() {
            if touchedNodes.contains(entity.agent.spriteContainer) {
                nodeIndex = index
                break
            }
        }
        
        return nodeIndex
    }
    
    func getSelectedNodes() -> Set<Int> {
        return selectedIndexes
    }

    func getTouchedNodeIndex() -> Int? {
        touchedNodes = nodes(at: currentPosition!)
        
        var ix: Int?
        for (index, entity) in entities.enumerated() {
            if touchedNodes.contains(entity.agent.spriteContainer) {
                ix = index
                break
            }
        }
        
        return ix
    }
    
    override func mouseDown(with event: NSEvent) {
        currentPosition = event.location(in: self)
        downNodeIndex = getTouchedNodeIndex()
        upNodeIndex = nil

        mouseState = .down
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPosition = event.location(in: self)
        mouseState = .dragging

        if let d = downNodeIndex, let c = currentPosition {
            trackMouse(nodeIndex: d, atPoint: c)
        }
    }
    
    func deselect(_ ix: Int) {
        entities[ix].agent.deselect()
        selectedIndexes.remove(ix)
        
        AppDelegate.me!.removeAgentFrames()
    }
    
    func deselectAll() {
        for entity in entities {
            entity.agent.deselect()
        }
        
        selectionState = .none
        selectedIndexes.removeAll()
        AppDelegate.me!.removeAgentFrames()
    }
    
    func select(_ ix: Int) {
        entities[ix].agent.select()
        selectedIndexes.insert(ix)
        
        AppDelegate.me!.placeAgentFrames(agentIndex: ix)
    }
    
    func toggleSelection(_ ix: Int) {
        if selectedIndexes.contains(ix) {
            selectedIndexes.remove(ix)
            entities[ix].agent.deselect()
        } else {
            selectedIndexes.insert(ix)
            entities[ix].agent.select()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        currentPosition = event.location(in: self)

        upNodeIndex = getTouchedNodeIndex()
        
        if mouseState == .down {
            updateSelectionState()
        }
        
        downNodeIndex = nil
        mouseState = .up
    }
    
    override func rightMouseDown(with event: NSEvent) {
        currentPosition = event.location(in: self)
        upNodeIndex = getTouchedNodeIndex()
        downNodeIndex = nil
        mouseState = .rightDown
    }

    override func rightMouseUp(with event: NSEvent) {
        currentPosition = event.location(in: self)
        upNodeIndex = getTouchedNodeIndex()
        downNodeIndex = nil
        mouseState = .rightUp
    }
    
    func trackMouse(nodeIndex: Int, atPoint: CGPoint) {
        let agent = getAgent(at: nodeIndex)
        agent.position = vector_float2(Float(atPoint.x), Float(atPoint.y))
        agent.position.x += Float(nodeToMouseOffset.x)
        agent.position.y += Float(nodeToMouseOffset.y)
    }
    
    func updateSelectionState() {
        if upNodeIndex == nil {
            // User clicked on a blank area of the scene
            deselectAll()
        } else {
            switch selectionState {
            case .none:
                select(upNodeIndex!)
                selectionState = .one
                
            case .one:
                let selectedIndex = selectedIndexes.first!
                
                deselect(selectedIndex)
                selectionState = .none
                
                // If he clicked on a node other than the one that we just deselected
                if upNodeIndex != selectedIndex {
                    select(upNodeIndex!)
                    selectionState = .one
                }
                
            case .multi:
                toggleSelection(upNodeIndex!)
            }
        }
    }
}
