//
//  textInputVCC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

/**
Use this class as controller for the single or multiline input VCs
*/
class TextInputVCC {
	
	var fieldTitle: String = "DEFAULT"
	var inputFieldText: String?
	var validationText: String = "DEFAULT"
	var validationAllowedCharacters = "DEFAULT"
	var inputIsRequired = true
	var maxLength = 20
	var editingPropertyType: EditingPropertyType?
	
	private var originalText : String?
	

	
	
	/**
	will return true/false and also format the counter label color
	*/
	func meetsMaxLengthCriteria () -> Bool {
		
		counterLabel.text = String (maxLength - Int(inputBox.text?.count ?? 0))
		
		if inputBox.text?.count ?? 0 > maxLength {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
			return false
		} else {
			counterLabel.textColor = myTheme.colorText
			return true
		}
	}
	
	func meetsMinCriteria () -> Bool {
		
		let cleanText = tu.removeLeadingSpaces(input: inputBox.text ?? "")
		
		if inputIsRequired {
			if cleanText.count > 0 {
				return true
			} else {
				return false
			}
		} else {
			return true
		}
	}
	
	func fillInputPlaceHolder () {
		if tu.isBlank(string: inputBox.text) {
			if inputIsRequired {
				inputBox.placeholder = "Required"
			} else {
				inputBox.placeholder = "Optional"
			}
		}
	}
	
	func hasChangedFromOriginal () -> Bool {
		let cleanText = tu.removeLeadingTrailingSpaces(string: inputBox.text ?? "")
		if originalText ?? "" == cleanText {
			return false
		} else {
			return true
		}
	}
	
	
}
