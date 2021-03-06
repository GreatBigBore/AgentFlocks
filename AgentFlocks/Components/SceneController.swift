//
//  SceneController.swift
//  AgentFlocks
//
//  Created by Gergely Sánta on 01/11/2017.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import GameplayKit
import SpriteKit

protocol SceneDelegate {
//	func sceneView(_ controller: SceneController)
}

class SceneController: NSViewController {
	
	// MARK: - Attributes (public)
	
    var sceneNode: GameScene!
    var gameScene: GKScene!
	
	// MARK: - Attributes (private)
	
	private var nodes = [SKSpriteNode]()
	
	// MARK: - Initialization
	
	init() {
		super.init(nibName: NSNib.Name(rawValue: "SceneView"), bundle: nil)
	}
	
	required convenience init?(coder: NSCoder) {
		self.init()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameScene = GKScene(fileNamed: "GameScene")
        sceneNode = gameScene.rootNode as! GameScene?
		
		if let sceneView = view as? SKView {
			// Add SpriteKit root node to sceneView (SKView)
			sceneView.presentScene(sceneNode)
			
			// Sprite Kit applies additional optimizations to improve rendering performance
            sceneView.ignoresSiblingOrder = true
			
			sceneView.showsFPS = true
			sceneView.showsNodeCount = true
		}
    }
	
	override func viewDidLayout() {
		sceneNode.size = view.frame.size
	}
}
