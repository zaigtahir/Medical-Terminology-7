//
//  zUIButton.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/2/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

//
//  ZUIToggleButton.swift
//  Testing
//
//  Created by Zaigham Tahir on 4/2/21.
//

import UIKit

/**
This class works as a toggle button with an image. It will change the color of the image based on the onTintColor and offTintColor custom properties in the IB
You can get/set the isOn property

ISSUE this action is triggered AFTER the original button clickec action. So when the original button click action is triggered, the isOn value is still the original value.

*/

class ZUIToggleButton: UIButton {
	
	// custom fields to show on the IB
	@IBInspectable var onTintColor: UIColor?
	@IBInspectable var offTintColor: UIColor?
	
	private var iIsOn = false
	private var onImage : UIImage!
	
	override func awakeFromNib() {
		
		self.addTarget(self, action: #selector(btnClicked(_:)),
					   for: .touchUpInside)
		
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
	
	@objc func btnClicked (_ sender:UIButton) {
		isOn.toggle()
	}
}

