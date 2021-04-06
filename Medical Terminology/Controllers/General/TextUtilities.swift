//
//  TextUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/29/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

//
//  textUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/28/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class TextUtilities {

	func removeLeadingSpaces(input: String) -> String {
		guard let index = input.firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
				return input
			}
			return String(input[index...])
		}
	
	func removeLeadingTrailingSpaces (string: String) -> String {
		// remove surrounding spaces
		// return empty string if the input is only blank spaces
		
		let s = string.trimmingCharacters(in: .whitespaces)
		
		let isBlank = s.allSatisfy({ $0.isWhitespace})
		
		if isBlank {
			return ""
		} else {
			return s
		}
	}
	
	func ztIsTextValid (inputString: String, allowedCharacters: String) -> Bool {
	
		let cs = CharacterSet(charactersIn: allowedCharacters).inverted
		
		let components = inputString.components(separatedBy: cs)
		let filtered = components.joined(separator: "")
		
		if inputString == filtered {
			return true
		} else {
			return false
		}
	}
	
	/*
	Will check for validity of text and make the textbox.text and the accessory button red color if the text is not valid
	Will return TRUE if the text if VALID OR if it is BLANK
	Will return FALSE if the text is invalid, and will also make the text and the accessory button red color (well the invalid text color from myTheme)
	*/
	func formatTextField (textField: UITextField, allowedCharacters: String, maxLength: Int, accessoryButton: UIButton?) -> Bool {
		
		// do not allow user to start with a space
		if textField.text ?? "" == " " {
			textField.text = ""
		}
		
		// does not allow leading spaces. Would be good if the user pastes text with leading space
		let text = textField.text ?? ""
		let removedLeading = removeLeadingSpaces(input: text)
		if text != removedLeading {
			textField.text = removedLeading
		}
		
		// to get count, just count the trimmed String
		let trimmed = removeLeadingTrailingSpaces(string: text)
		if trimmed.count > maxLength {
			textField.textColor = myTheme.invalidFieldEntryColor
			accessoryButton?.tintColor = myTheme.invalidFieldEntryColor
			return false	// not valid data in the text field
		} else {
			textField.textColor = myTheme.validFieldEntryColor
		}
		
		// now look at the content of the string and check for invalid characters
		if ztIsTextValid(inputString: textField.text!, allowedCharacters: allowedCharacters) {
			textField.textColor = myTheme.validFieldEntryColor
			accessoryButton?.tintColor = myTheme.validFieldEntryColor
			return true
	
		} else {
			textField.textColor = myTheme.invalidFieldEntryColor
			accessoryButton?.tintColor = myTheme.invalidFieldEntryColor
			return false
		}
		
	}
	
	
	//MARK: -old stuff
	
	func isBlank (string: String) -> Bool {
		// return true if the string is just space characters
		return string.allSatisfy({ $0.isWhitespace})
	}
	
	
}
