//
//  AgentGoalsController.swift
//  AgentFlocks
//
//  Created by Gergely Sánta on 21/10/2017.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import Cocoa

protocol AgentGoalsDelegate {
    func agentGoalsPlayClicked(_ agentGoalsController: AgentGoalsController, actionPlay: Bool)
    func agentGoalsDeleteItem(_ agentGoalsController: AgentGoalsController)
    func agentGoals(_ agentGoalsController: AgentGoalsController, newBehaviorShowForRect rect: NSRect)
    func agentGoals(_ agentGoalsController: AgentGoalsController, newGoalShowForRect rect: NSRect, goalType type:AgentGoalsController.GoalType)
    func agentGoals(_ agentGoalsController: AgentGoalsController, itemClicked item: Any, inRect rect: NSRect)
    func agentGoals(_ agentGoalsController: AgentGoalsController, itemDoubleClicked item: Any, inRect rect: NSRect)
    func agentGoals(_ agentGoalsController: AgentGoalsController, item: Any, setState state: NSControl.StateValue )
    // Drag & Drop
    func agentGoals(_ agentGoalsController: AgentGoalsController, dragIdentifierForItem item: Any) -> String?
    func agentGoals(_ agentGoalsController: AgentGoalsController, validateDrop info: NSDraggingInfo, toParentItem parentItem: Any?, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation
    func agentGoals(_ agentGoalsController: AgentGoalsController, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool
}

protocol AgentGoalsDataSource {
    func agentGoals(_ agentGoalsController: AgentGoalsController, getEditorFor item: Any?) -> AFMotivatorEditor
    func agentGoals(_ agentGoalsController: AgentGoalsController, numberOfChildrenOfItem item: Any?) -> Int
    func agentGoals(_ agentGoalsController: AgentGoalsController, isItemExpandable item: Any) -> Bool
    func agentGoals(_ agentGoalsController: AgentGoalsController, child index: Int, ofItem item: Any?) -> Any
    func agentGoals(_ agentGoalsController: AgentGoalsController, labelOfItem item: Any) -> String
	func agentGoals(_ agentGoalsController: AgentGoalsController, weightOfItem item: Any) -> Float
    func agentGoals(_ agentGoalsController: AgentGoalsController, isItemEnabled item: Any) -> Bool
}

class AgentGoalsController: NSViewController {
    typealias GoalType = AFGoalEditor.AFGoalType

	// MARK: - Attributes (public)
	
	var delegate:AgentGoalsDelegate?
	var dataSource:AgentGoalsDataSource?

	// MARK: - Attributes (private)
	
	@IBOutlet weak var outlineView: NSOutlineView!
	@IBOutlet weak var addButton: NSButton!
	@IBOutlet weak var removeButton: NSButton!
	@IBOutlet weak var playButton: NSButton!
    
    var playImage: NSImage?
    var pauseImage: NSImage?
	
	@IBOutlet var addContextMenu: NSMenu!
	
	// MARK: - Initialization
    
    override func keyUp(with event: NSEvent) {
        if event.keyCode == AFKeyCodes.delete.rawValue {
            delegate?.agentGoalsDeleteItem(self)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        print("keydown")
    }
	
	init() {
		super.init(nibName: NSNib.Name(rawValue: "AgentGoalsView"), bundle: nil)
	}
	
	required convenience init?(coder: NSCoder) {
		self.init()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        playImage = NSImage(named: NSImage.Name(rawValue: "Play"))
        pauseImage = NSImage(named: NSImage.Name(rawValue: "Pause"))
		playButton.image = pauseImage
		
		outlineView.target = self
        outlineView.action = #selector(onItemClicked)
		outlineView.doubleAction = #selector(onItemDoubleClicked)
		outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        
        var indexSet = IndexSet()
        indexSet.insert(0)
        outlineView.selectRowIndexes(indexSet, byExtendingSelection: false)

        let zeroItem = outlineView.item(atRow: 0)
        outlineView.expandItem(zeroItem)
	}
	
	// MARK: - Public methods
	
	func refresh() {
		outlineView.reloadData()
	}
	
	func selectedIndex() -> Int {
		return outlineView.selectedRow
	}
	
	// MARK: - Actions and methods (private)
    
    @objc private func onItemClicked() {
        if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) {
            let rect = outlineView.rect(ofRow: outlineView.selectedRow)
            delegate?.agentGoals(self, itemClicked: selectedItem, inRect: outlineView.convert(rect, to: self.view))
        }
    }
	
	@objc private func onItemDoubleClicked() {
		if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) {
			let rect = outlineView.rect(ofRow: outlineView.selectedRow)
			delegate?.agentGoals(self, itemDoubleClicked: selectedItem, inRect: outlineView.convert(rect, to: self.view))
		}
	}
	
	@objc private func onItemChecked(_ sender: Any) {
		if let checkButton = sender as? AgentGoalsCheckButton,
			let selectedItem = checkButton.item
		{
			delegate?.agentGoals(self, item: selectedItem, setState: checkButton.state)
		}
	}
	
	@IBAction func addButtonPressed(_ sender: NSButton) {
		addContextMenu.popUp(positioning: nil, at: NSMakePoint(0, 0), in: sender)
	}
	
	@IBAction func removeButtonPressed(_ sender: NSButton) {
	}
	
	@IBAction func playButtonPressed(_ sender: NSButton) {
        var actionPlay = true
        
        if playButton.image == playImage { actionPlay = true; playButton.image = pauseImage }
        else { actionPlay = false; playButton.image = playImage }

        delegate?.agentGoalsPlayClicked(self, actionPlay: actionPlay)
	}
	
	@IBAction func addBehaviorItemSelected(_ sender: NSMenuItem) {
		delegate?.agentGoals(self, newBehaviorShowForRect: addButton.bounds)
	}
	
	@IBAction func addGoalItemSelected(_ sender: NSMenuItem) {
		var goalType = GoalType.toWander
		switch addContextMenu.index(of: sender) {
		case 2: goalType = GoalType.toAlignWith
		case 3: goalType = GoalType.toAvoidAgents
        case 4: goalType = GoalType.toAvoidObstacles
        case 5: goalType = GoalType.toCohereWith
        case 6: goalType = GoalType.toFleeAgent
        case 7: goalType = GoalType.toFollow
        case 8: goalType = GoalType.toInterceptAgent
        case 9: goalType = GoalType.toSeekAgent
        case 10: goalType = GoalType.toSeparateFrom
        case 11: goalType = GoalType.toStayOn
        case 12: goalType = GoalType.toReachTargetSpeed
        case 13: goalType = GoalType.toWander
		default: fatalError()
		}
		delegate?.agentGoals(self, newGoalShowForRect: addButton.bounds, goalType: goalType)
	}
	
}

// MARK: -

extension AgentGoalsController: NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		return dataSource?.agentGoals(self, numberOfChildrenOfItem: item) ?? 0
	}
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		return dataSource?.agentGoals(self, isItemExpandable: item) ?? false
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		return dataSource?.agentGoals(self, child: index, ofItem: item) ?? ""
	}
	
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let editor = dataSource?.agentGoals(self, getEditorFor: item as? String) else { return nil }
        
        let isEnabled = editor.isEnabled
        
		if (tableColumn?.title ?? "") == "Name" {
			if let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GoalNameCellView"), owner: self) as? AgentGoalsCellView {
				cellView.textField?.stringValue = dataSource?.agentGoals(self, labelOfItem: item) ?? ""
				cellView.checkButton.target = self
				cellView.checkButton.action = #selector(onItemChecked(_:))
				cellView.checkButton.target = self
				cellView.checkButton.item = item
                cellView.checkButton.state = isEnabled ? .on : .off
                cellView.textField?.textColor = isEnabled ? NSColor.textColor : NSColor.lightGray
                cellView.checkButton?.isEnabled = isEnabled
				
				return cellView
			}
		}
		else if (tableColumn?.title ?? "") == "Weight" {
			if let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GoalWeightCellView"), owner: self) as? NSTableCellView {
                let w = editor.weight
                let formatString = (w > pow(10, 4)) ? "%.f" : (w > pow(10, 2) ? "%.1f" : "%.2f")
                cellView.textField?.stringValue = String(format: formatString, "", w)
                
                cellView.textField?.textColor = isEnabled ? NSColor.textColor : NSColor.lightGray
				
				return cellView
			}
		}
		return nil
	}
	
}

// MARK: -

extension AgentGoalsController: NSOutlineViewDelegate {
	
	func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
		if let dragID = delegate?.agentGoals(self, dragIdentifierForItem: item) {
			let pboardItem = NSPasteboardItem()
			pboardItem.setString(dragID, forType: NSPasteboard.PasteboardType.string)
			return pboardItem
		}
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
		var parentItem: Any? = nil
		if let mainView = self.view.window?.contentView {
			let destinationLocation = outlineView.convert(info.draggingLocation(), from: mainView)
			let destinationRow = outlineView.row(at: destinationLocation)
			if let destinationItem = outlineView.item(atRow: destinationRow) {
				parentItem = outlineView.parent(forItem: destinationItem)
			}
		}
		
		if let dragOperation = delegate?.agentGoals(self, validateDrop: info, toParentItem: parentItem, proposedItem: item, proposedChildIndex: index) {
			if dragOperation.rawValue != 0 {
				NSLog("-> Row \(outlineView.row(forItem: item))[parent row \(outlineView.row(forItem: parentItem))]: Index: \(index)")
			}
			return dragOperation
		}
		return NSDragOperation.init(rawValue: 0)
	}
	
	func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
		if let dragAccept = delegate?.agentGoals(self, acceptDrop: info, item: item, childIndex: index) {
			return dragAccept
		}
		return false
	}
}

// MARK: - Custom components used in Agent Behavior&Goals editor

class AgentGoalsCheckButton: NSButton {
	
	var item:Any?
	
}

class AgentGoalsCellView: NSTableCellView {
	
	@IBOutlet weak var checkButton: AgentGoalsCheckButton!

}
