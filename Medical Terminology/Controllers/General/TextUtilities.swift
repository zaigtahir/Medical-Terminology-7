//
//  TextUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/29/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

//
//  textUtilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/28/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class TextUtilities {
	
	public func validateString(string: String) -> Bool {
	   let otherRegexString = "^[a-zA-Z0-9 -!:.]*$"
	   let trimmedString = string.trimmingCharacters(in: .whitespaces)
	   let validateOtherString = NSPredicate(format: "SELF MATCHES %@", otherRegexString)
	   let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
	   return isValidateOtherString
	}
	
	func removeNewLines (string: String) -> String {
		
		var stringNew = string
		
		while let rangeToReplace = string.range(of: "\n") {
			stringNew.replaceSubrange(rangeToReplace, with: " ")
		}
		return stringNew
	}
	
	func cleanString (string: String) -> String {
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
	
	func isBlank (string: String) -> Bool {
		// return true if the string is just space characters
		return string.allSatisfy({ $0.isWhitespace})
	}
	
	func ztIsTextValid (inputString: String, allowedCharacters: String, maxLength: Int) -> Bool {
	
		let cs = CharacterSet(charactersIn: allowedCharacters).inverted
		
		let components = inputString.components(separatedBy: cs)
		let filtered = components.joined(separator: "")
		
		if inputString != filtered {
			return false
		}
		
		if inputString.count <= maxLength {
			return true
		} else {
			return false
		}
		
	}
}
