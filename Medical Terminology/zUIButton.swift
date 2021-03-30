//
//  myButton.swift
//  Testing
//
//  Created by Zaigham Tahir on 3/29/21.
//

import UIKit

class myUIButton: UIButton {
	
	var zBackgroundColorEnabled = UIColor.blue
	var zTextColorEnabled = UIColor.white
	
	var zBackgroundColorDisabled = UIColor.systemGray6
	var zTextColorDisabled = UIColor.systemGray4
	
	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				self.setTitleColor(zTextColorEnabled, for: .normal)
				self.backgroundColor = zBackgroundColorEnabled
				self.tintColor = zTextColorEnabled
				
			} else {
				self.setTitleColor(zTextColorDisabled, for: .disabled)
				self.backgroundColor = zBackgroundColorDisabled
				self.tintColor = zTextColorDisabled
			}
		}
	}
}

