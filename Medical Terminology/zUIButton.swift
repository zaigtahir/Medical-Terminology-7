//
//  zUIButton.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/29/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class myUIButton: UIButton {
	
	var zBackgroundColorEnabled = UIColor.blue
	var zTextColorEnabled = UIColor.white
	var zBackgroundColorDisabled = UIColor.systemGray6
	var zTextColorDisabled = UIColor.systemGray4
	var zCornerRadius = CGFloat(5)
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		zBackgroundColorEnabled = self.backgroundColor!
		zTextColorEnabled = self.titleColor(for: .normal)!
		
		// add corners
		self.layer.cornerRadius = zCornerRadius
		
	}
	
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
