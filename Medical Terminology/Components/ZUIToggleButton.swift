//
//  zUIButton.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//


import UIKit

/**
This button will change it's color based on it's isOn property you can get/set. The tint color is to  be set in the IB. You basically use it to manually set the state you want and use it like a toggle
*/

class ZUIToggleButton: UIButton {
	
	// custom fields to show on the IB
	@IBInspectable var onTintColor: UIColor?
	@IBInspectable var offTintColor: UIColor?
	
	private var iIsOn = false
	private var onImage : UIImage!
	
	override func awakeFromNib() {
		
		onImage = self.image(for: .normal)
		self.tintColor = offTintColor
	}
	
	var isOn : Bool {
		set {
			iIsOn = newValue
			
			self.tintColor = iIsOn ? onTintColor : offTintColor
			self.setImage(onImage, for: .normal)
		}
		
		get {
			return iIsOn
		}
	}
	
}

