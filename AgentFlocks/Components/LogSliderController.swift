//
//  LogSliderController.swift
//  AgentFlocks
//
//  Created by Gergely Sánta on 15/10/2017.
//  Copyright © 2017 TriKatz. All rights reserved.
//

import Cocoa

protocol LogSliderDelegate {
	func logSlider(_ controller: LogSliderController, newValue value:Double)
}

class LogSliderController: NSViewController {
	
	// MARK: - Attributes (public)
	
	// Name of the slider (name of value the slider changes)
	@objc dynamic var sliderName:String = "Name"
	
	// Allowed minimum and maximum exponents
	@objc dynamic var minExponent:Int = -1 {
		didSet {
			if _exponentValue < minExponent {
				_exponentValue = minExponent
			}
			refreshExponentSliderTickmarks()
		}
	}
	@objc dynamic var maxExponent:Int = 5 {
		didSet {
			if _exponentValue > maxExponent {
				_exponentValue = maxExponent
			}
			refreshExponentSliderTickmarks()
		}
	}
	
	// Exponent slider value
	
	private var _exponentValue:Int = 2
	@objc dynamic var exponentValue:Int {
		get {
			return _exponentValue
		}
		set {
			if newValue < minExponent {
				_exponentValue = minExponent
			}
			else if newValue > maxExponent {
				_exponentValue = maxExponent
			}
			else {
				_exponentValue = newValue
			}
			maxValue = pow(10.0, Double(_exponentValue))
			if _value > maxValue {
				_value = maxValue
				delegate?.logSlider(self, newValue: _value)
			}
			incrementValue = (_exponentValue > 1) ? 0.1 : pow(10.0, Double(_exponentValue - 3))
		}
	}

	// Allowed minimum value
	@objc dynamic var minValue:Double = 0.0 {
		didSet {
			if _value < minValue {
				_value = minValue
				delegate?.logSlider(self, newValue: _value)
			}
		}
	}
	@objc dynamic var maxValue:Double = 10.0

	// Slider value
	private var _value:Double = 10.0
	@objc dynamic var value:Double {
		get {
			return _value
		}
		set {
			if newValue < minValue {
				_value = minValue
			}
			else if newValue > maxValue {
				_value = maxValue
			}
			else {
				_value = newValue - newValue.remainder(dividingBy: incrementValue)
			}
//			valueLabel.sizeToFit()
		}
	}
	
	// Maximum allowed value (its maximum value and one unit when changed by stepper)
	private var _incrementValue:Double = 0.1
	var incrementValue:Double {
		get {
			return _incrementValue
		}
		set {
			_incrementValue = newValue
			if let slider = slider {
				slider.altIncrementValue = _incrementValue
			}
		}
	}

	var delegate:LogSliderDelegate?
	
	// MARK: - Attributes (private)
	
	@IBOutlet private weak var exponentSlider: NSSlider!
	@IBOutlet private weak var slider: NSSlider!
	@IBOutlet private weak var valueLabel: NSTextField!
	
	// MARK: - Initialization
	
	init() {
		ValueTransformer.setValueTransformer(LogSliderValueTransformer(), forName: .logSliderValueTransformer)
		super.init(nibName: NSNib.Name(rawValue: "LogSliderView"), bundle: nil)
	}
	
	required convenience init?(coder: NSCoder) {
		self.init()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		exponentSlider.altIncrementValue = 1.0
		slider.altIncrementValue = incrementValue
		valueLabel.formatter = LogSliderValueFormatter()
		refreshExponentSliderTickmarks()
		self.exponentValue = 2
		exponentSlider.integerValue = self.exponentValue
    }
	
	// MARK: - Private methods
	
	private func refreshExponentSliderTickmarks() {
		if let exponentSlider = self.exponentSlider {
			exponentSlider.numberOfTickMarks = self.maxExponent - self.minExponent + 1
		}
	}
	
	// MARK: - Public methods
	
	func addToView(_ superview: NSView) {
		superview.addSubview(self.view)
		self.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint(item: superview,
		                   attribute: .top,
		                   relatedBy: .equal,
		                   toItem: self.view,
		                   attribute: .top,
		                   multiplier: 1.0,
		                   constant: 0.0).isActive = true
		NSLayoutConstraint(item: superview,
		                   attribute: .bottom,
		                   relatedBy: .equal,
		                   toItem: self.view,
		                   attribute: .bottom,
		                   multiplier: 1.0,
		                   constant: 0.0).isActive = true
		NSLayoutConstraint(item: superview,
		                   attribute: .left,
		                   relatedBy: .equal,
		                   toItem: self.view,
		                   attribute: .left,
		                   multiplier: 1.0,
		                   constant: 0.0).isActive = true
		NSLayoutConstraint(item: self.view,
		                   attribute: .right,
		                   relatedBy: .equal,
		                   toItem: superview,
		                   attribute: .right,
		                   multiplier: 1.0,
		                   constant: 0.0).isActive = true
	}
	
	// MARK: - Actions and methods (private)
	
	@IBAction func sliderDidMove(_ sender: NSSlider) {
		delegate?.logSlider(self, newValue: sender.doubleValue)
	}
	
	@IBAction func exponentSliderDidMove(_ sender: NSSlider) {
		self.exponentValue = self.exponentSlider.integerValue
	}

}

// MARK: - TextField ignoring mouses clicks

class LogTextField : NSTextField {
	
	override func hitTest(_ point: NSPoint) -> NSView? {
		return nil
	}
	
}

// MARK: - TextFieldCell resizing text is needed

class LogTextFieldCell : NSTextFieldCell {
	
	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		var attributedString = self.attributedStringValue
		var stringSize = attributedString.size()
		
		if let labelFont = attributedString.attribute(NSAttributedStringKey.font, at: 0, effectiveRange: nil) as? NSFont,
			let fontSizeObj = labelFont.fontDescriptor.object(forKey: NSFontDescriptor.AttributeName.size) as? NSNumber,
			let mutableAttributedString = attributedString.mutableCopy() as? NSMutableAttributedString
		{
			var fontSize = CGFloat(fontSizeObj.floatValue)
			while stringSize.width > cellFrame.size.width {
				fontSize -= 0.5
				if let font = NSFont(name: labelFont.fontName, size: fontSize) {
					mutableAttributedString.removeAttribute(NSAttributedStringKey.font,
															range: NSMakeRange(0, mutableAttributedString.length))
					mutableAttributedString.addAttribute(NSAttributedStringKey.font,
														 value: font,
														 range: NSMakeRange(0, mutableAttributedString.length))
					attributedString = mutableAttributedString
					stringSize = mutableAttributedString.size()
				}
				else {
					break
				}
			}
		}
		
		var drawRect = cellFrame
		drawRect.size.height = stringSize.height
		drawRect.origin.x -= 1.0
		drawRect.origin.y += (cellFrame.size.height - stringSize.height) / 2
		attributedString.draw(in: drawRect)
	}
	
}

// MARK: - Value formatter

class LogSliderValueFormatter: Formatter {
	
	override func string(for obj: Any?) -> String? {
		guard let value = obj as? String else { return "" }
		return value
	}
	
	override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
		obj?.pointee = string as AnyObject
		return true
	}
	
	override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {

		if partialString.isEmpty {
			return true
		}

		// Deny change if other than number or dot entered
		var onlyNumbersAndDot = CharacterSet.decimalDigits
		onlyNumbersAndDot.insert(charactersIn: ".")
		if partialString.rangeOfCharacter(from: onlyNumbersAndDot.inverted) != nil {
			return false
		}

		// If number starts with 0, don't allow to enter additional characters
		if partialString.hasPrefix("0") && (partialString.count > 1) {
			return false
		}

		// This is a floating point number, do not allow more than one dots
		let allDots = partialString.filter { $0 == "." }
		if allDots.count > 1 {
			return false
		}

		// Correct the string for converting to Double
		let stringNumber = partialString.hasSuffix(".") ? "\(partialString)0" : partialString

		// Try to convert to Double
		return (Double(stringNumber) == nil) ? false : true
	}
	
}

// MARK: - Value transformer for XIB

class LogSliderValueTransformer: ValueTransformer {
	
	// Transformer used in slider. It's transforming Double to String and vice versa
	
	override class func transformedValueClass() -> AnyClass {
		return String.self as! AnyClass
	}
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		// Transforms Double to String
		guard let doubleValue = value as? Double else { return "" }
		return "\(doubleValue)"
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		// Transforms String to Double
		guard let stringValue = value as? String else { return 0.0 }
		// Correct the string for converting to Double
		let correctedValue = stringValue.hasSuffix(".") ? stringValue + "0" : stringValue
		if let doubleValue = Double(correctedValue) {
			return doubleValue
		}
		return 0.0
	}
	
}

extension NSValueTransformerName {
	static let logSliderValueTransformer = NSValueTransformerName(rawValue: "LogSliderValueTransformer")
}
