//
//  textInputVCC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit
/**
Use this class as controller for the single or multiline input VCs
*/
class TextInputVCH  {
	
	var fieldTitle: String = "DEFAULT"
	var initialText: String? // setter for originalText also
	var validationPrompt: String = "DEFAULT"
	var allowedCharacters = "DEFAULT"
	
	var maxLength = 20
	var minLength = 0
	
	var propertyReference: PropertyReference!
	
	private var tu = TextUtilities()
	
	// Will clean the input text
	private func meetsMinCriteria (inputString: String?) -> Bool {
		
		let cleanText = tu.removeLeadingSpaces(input: inputString ?? "")
		
		if cleanText.count > minLength {
			return true
		} else {
			return false
		}
		
	}
	
	private func textIsValid (inputString: String?) -> Bool {
		return tu.textIsValid(inputString: inputString ?? "", allowedCharacters: 	allowedCharacters)
	}
	
	/**
	Will check for valid text, meets min and max criteria
	*/
	func textMeetsAllCriteria (inputString: String?) -> Bool {
		let isValid = textIsValid(inputString: inputString)
		let meetsMin = meetsMinCriteria(inputString: inputString)
		let meetsMax = meetsMaxLengthCriteria(inputString: inputString)
		
		return (isValid && meetsMin && meetsMax)
	}
	
	/// Will clean the input text
	func meetsMaxLengthCriteria (inputString: String?) -> Bool {
		let cleanText = tu.removeLeadingSpaces(input: inputString ?? "")
		if cleanText.count > maxLength {
			return false
		} else {
			return true
		}
	}
	
	/**
	Get the text not including any leading or trailing spaces
	Will return nil as empty string
	*/
	func getCleanText (inputString: String?) -> String {
		return tu.removeLeadingSpaces(input: inputString ?? "")
	}
	
}
