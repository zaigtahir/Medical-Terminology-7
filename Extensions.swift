//
//  Extensions.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/29/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
	
	func ztIsTextValid (allowedCharacters: String, maxLength: Int) -> Bool {
	
		guard let inputText = self.text else {
			return true
		}
		
		let cs = CharacterSet(charactersIn: allowedCharacters).inverted
		
		let components = inputText.components(separatedBy: cs)
		let filtered = components.joined(separator: "")
		
		if inputText != filtered {
			return false
		}
		
		if inputText.count <= maxLength {
			return true
		} else {
			return false
		}
		
	}
}
