//
//  ZUIRoundedButton.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class ZUIRoundedButton: UIButton {

	// custom fields to show in the IB
	@IBInspectable var enabledBackgroundColor : UIColor?
	@IBInspectable var disabledBackgroundColor : UIColor?
	@IBInspectable var disabledTintColor : UIColor?
	@IBInspectable var enabledTintColor : UIColor?
	
	override func awakeFromNib() {
		self.layer.cornerRadius = myConstants.button_cornerRadius
	}
	
	/**
	Will apply the background color based on enable/disable state
	*/
	func updateBackgroundColor () {
		if self.isEnabled {
			self.backgroundColor = enabledBackgroundColor
		} else {
			self.backgroundColor = disabledBackgroundColor
		}
	}
	
	func updateTintColor () {
		if self.isEnabled {
			self.tintColor = enabledTintColor
		} else {
			self.tintColor = disabledTintColor
		}
	}
	
	override var isEnabled: Bool {
		didSet {
			updateBackgroundColor()
			updateTintColor()
		}
	}
	

}
