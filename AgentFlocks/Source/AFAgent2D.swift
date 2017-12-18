//
//  AFAgent2D.swift
//  AgentFlocks
//
//  Created by Rob Bishop on 12/18/17.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import GameplayKit

class AFAgent2D: GKAgent2D {
    var motivator: AFMotivatorCollection?
    let originalSize: CGSize
    let spriteContainer: SKNode
    let radiusIndicator: SKSpriteNode
    let radiusIndicatorRadius: CGFloat = 100.0
    let sprite: SKSpriteNode
    
    var walls = [GKPolygonObstacle]()
    
    var scale: Float {
        willSet(newValue) {
            let v = CGFloat(newValue)
            sprite.scale(to: CGSize(width: originalSize.width * v, height: originalSize.height * v))
        }
    }
    
    override var radius: Float {
        willSet(newValue) {
            radiusIndicator.setScale(CGFloat(newValue) / 0.5 / (radiusIndicatorRadius * 2))
        }
    }
    
    static var uniqueNameBase = 0
    
    class func makeUniqueName() -> String {
        AFAgent2D.uniqueNameBase += 1
        return String(format: "%5d", AFAgent2D.uniqueNameBase)
    }
    
    init(scene: GameScene, position: CGPoint) {
        scale = 1
        
        spriteContainer = SKNode()
        spriteContainer.position = position
        
        sprite = SKSpriteNode(imageNamed: "Agent01")
        sprite.name = AFAgent2D.makeUniqueName()
        spriteContainer.addChild(sprite)
        
        // 0.5 is the default radius for agents
        radiusIndicator = SKSpriteNode(imageNamed: "Agent01")
        radiusIndicator.alpha = 0.5
        radiusIndicator.zPosition = 1
        radiusIndicator.setScale(1 / (radiusIndicatorRadius * 2))
        spriteContainer.addChild(radiusIndicator)
        
        scene.addChild(spriteContainer)
        
        originalSize = sprite.size
        
        let m = AFBehavior(goal: AFGoal(toWander: 100, weight: 100))

        walls = SKNode.obstacles(fromNodeBounds: [scene.top, scene.right, scene.bottom, scene.left])
        m.addGoal(AFGoal(toAvoidObstacles: walls, maxPredictionTime: 5, weight: 10000))

        motivator = m
        
        super.init()
        
        applyMotivator()
    }
    
    deinit {
        spriteContainer.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        spriteContainer.position = CGPoint(x: Double(position.x), y: Double(position.y))
        spriteContainer.zRotation = CGFloat(Double(rotation) - Double.pi / 2.0)
    }
}

extension AFAgent2D {
    func applyMotivator() {
        guard motivator != nil else { return }

        switch motivator {
        case let m as AFBehavior:          behavior = createBehavior(from: m)
        case let m as AFCompositeBehavior: behavior = createComposite(from: m)

        default: fatalError()
        }
    }
    
    func createBehavior(from: AFBehavior) -> GKBehavior {
        let behavior = GKBehavior()
        
        for goal in from.goals {
            behavior.setWeight(goal.weight, for: goal.goal)
        }
        
        return behavior
    }
    
    func createComposite(from: AFCompositeBehavior) -> GKCompositeBehavior {
        let composite = GKCompositeBehavior()
        
        for mvBehavior in from.behaviors {
            let gkBehavior = createBehavior(from: mvBehavior)
            composite.setWeight(mvBehavior.weight, for: gkBehavior)
        }
        
        return composite
    }
}

