//
//  myButton.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/30/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class myButton: UIButton {

	var zCornerRadius = CGFloat (5.0)
	private var zbackgroundColor: UIColor?
	
	override func awakeFromNib() {
		super.awakeFromNib()

		// add corners
		self.layer.cornerRadius = zCornerRadius
		layer.cornerRadius = zCornerRadius
	
	}
	
	
	override var isEnabled: Bool {
		didSet {
			if !isEnabled {
				self.backgroundColor = UIColor.systemGray5
				self.tintColor = self.titleColor(for: .disabled)
			}
		}
	}
	
	
	
	/*
	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				if let bgc = self.backgroundColor {
					// color will exist if it is not set to default in the IB
					self.backgroundColor = zBackgroundColorEnabled
					self.tintColor = zTextColorEnabled
				}
				
				
			} else {
				
				self.backgroundColor = zBackgroundColorDisabled
				self.tintColor = zTextColorDisabled
			}
		}
	}
	
	
	*/
}
