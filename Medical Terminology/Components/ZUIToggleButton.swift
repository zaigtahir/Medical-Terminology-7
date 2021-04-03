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

class ZUIToggleButton: UIButton {
	
	@IBInspectable var highlightedSelectedImage:UIImage?
	
	@IBInspectable var onTintColor: UIColor?
	@IBInspectable var offTintColor: UIColor?
	
	private var iIsOn = false
	
	override func awakeFromNib() {
		self.addTarget(self, action: #selector(btnClicked(_:)),
					   for: .touchUpInside)
		
		self.tintColor = offTintColor
	
	}
	
	var isOn : Bool {
		set {
			iIsOn = newValue
			self.tintColor = iIsOn ? onTintColor : offTintColor
		}
		
		get {
			return iIsOn
		}
	}
	
	@objc func btnClicked (_ sender:UIButton) {
		iIsOn.toggle()
		self.tintColor = iIsOn ? onTintColor : offTintColor
		
	}
}

