//
//  AgentGoalsController.swift
//  AgentFlocks
//
//  Created by Gergely Sánta on 21/10/2017.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import Cocoa

class AgentGoalsController: NSViewController {
	
	enum GoalType {
		case Wander
		case Align
		case Cohere
		case Avoid
	}

	// MARK: - Attributes (public)
	
	var delegate:AgentGoalsDelegate?
	var dataSource:AgentGoalsDataSource?

	// MARK: - Attributes (private)
	
	@IBOutlet private weak var outlineView: NSOutlineView!
	@IBOutlet weak var addButton: NSButton!
	@IBOutlet private weak var playButton: NSButton!
	
	@IBOutlet var addContextMenu: NSMenu!
	
	// MARK: - Initialization
	
	init() {
		super.init(nibName: NSNib.Name(rawValue: "AgentGoalsView"), bundle: nil)
	}
	
	required convenience init?(coder: NSCoder) {
		self.init()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		playButton.image = NSImage(named: NSImage.Name(rawValue: "Play"))
		
		outlineView.target = self
		outlineView.doubleAction = #selector(onItemDoubleClicked)
		
		outlineView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
	}
	
	// MARK: - Public methods
	
	func refresh() {
		outlineView.reloadData()
	}
	
	func selectedIndex() -> Int {
		return outlineView.selectedRow
	}
	
	// MARK: - Actions and methods (private)
	
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
	
	@IBAction func playButtonPressed(_ sender: NSButton) {
		delegate?.agentGoalsPlayClicked(self)
	}
	
	@IBAction func addBehaviorItemSelected(_ sender: NSMenuItem) {
		delegate?.agentGoals(self, newBehaviorShowForRect: addButton.bounds)
	}
	
	@IBAction func addGoalItemSelected(_ sender: NSMenuItem) {
		var goalType = GoalType.Wander
		switch sender.tag {
		case 1:
			goalType = GoalType.Wander
		case 2:
			goalType = GoalType.Align
		case 3:
			goalType = GoalType.Cohere
		case 4:
			goalType = GoalType.Avoid
		default:
			goalType = GoalType.Wander
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
		if let cellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "GoalsCellView"), owner: self) as? AgentGoalsCellView {
			cellView.textField?.stringValue = dataSource?.agentGoals(self, labelOfItem: item) ?? ""
			cellView.checkButton.target = self
			cellView.checkButton.action = #selector(onItemChecked(_:))
			cellView.checkButton.item = item
			if let enabled = dataSource?.agentGoals(self, isItemEnabled: item) {
				cellView.checkButton.state = enabled ? .on : .off
			}
			else {
				cellView.checkButton.state = .off
			}
			return cellView
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
