//
//  TextInputVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/7/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit


class SingleLineInput: UIViewController, UITextFieldDelegate {
	
	//
	//  textInputVC.swift
	//  Medical Terminology
	//
	//  Created by Zaigham Tahir on 4/7/21.
	//  Copyright © 2021 Zaigham Tahir. All rights reserved.
	//
	@IBOutlet weak var saveButton: ZUIRoundedButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var headerImage: UIImageView!
	@IBOutlet weak var inputBox: UITextField!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var validationLabel: UILabel!
	@IBOutlet weak var counterLabel: UILabel!
	
	var fieldTitle: String = "DEFAULT"
	var inputFieldText: String?
	var validationText: String = "DEFAULT"
	var validationAllowedCharacters = "DEFAULT"
	var inputIsRequired = true
	var maxLength = 20
	
	private var originalText : String?
	
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		inputBox.delegate = self
		
		//adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		titleLabel.text = fieldTitle
		inputBox.text = inputFieldText
		validationLabel.text = validationText
	
		// backed up original to compare to the textbox.text when validating
		originalText = inputFieldText
		
		// initital setting of the counter
		let _ = meetsMaxLengthCriteria()
		fillInputPlaceHolder()
		
		// initial setting of the save button state
		saveButton.isEnabled = false
		saveButton.updateBackgroundColor()
		
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		
		// check for valid characters
		let textContainsValidCharacters = tu.textIsValid(inputString: inputBox.text ?? "", allowedCharacters: validationAllowedCharacters)

		if textContainsValidCharacters {
			inputBox.textColor = myTheme.colorText
		} else {
			inputBox.textColor = myTheme.invalidFieldEntryColor
		}
		
		
		print("changed from original: \(hasChangedFromOriginal())")
		print ("meets min criteria: \(meetsMinCriteria())")
		
		
		// check to see if meeting other criteria
		if (textContainsValidCharacters && meetsMinCriteria() && meetsMaxLengthCriteria() && hasChangedFromOriginal()){
			
			saveButton.isEnabled = true
		} else {
			
			saveButton.isEnabled = false
		}
		
		// working
		fillInputPlaceHolder()
		
		// format custom colors
		saveButton.updateBackgroundColor()
		
	}
	
	private func hasChangedFromOriginal () -> Bool {
		let cleanText = tu.removeLeadingTrailingSpaces(string: inputBox.text ?? "")
		if originalText ?? "" == cleanText {
			return false
		} else {
			return true
		}
	}
	
	/**
	will return true/false and also format the counter label color
	*/
	private func meetsMaxLengthCriteria () -> Bool {
		counterLabel.text = String (maxLength - Int(inputBox.text?.count ?? 0))
		
		if inputBox.text?.count ?? 0 > maxLength {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
			return false
		} else {
			counterLabel.textColor = myTheme.colorText
			return true
		}	}
	
	private func meetsMinCriteria () -> Bool {
		
		let cleanText = tu.removeLeadingSpaces(input: inputBox.text ?? "")
		
		print("count: \(cleanText.count)")
		
		if inputIsRequired {
			if cleanText.count > 1 {
				return true
			} else {
				return false
			}
		} else {
			return true
		}
	}
	
	private func fillInputPlaceHolder () {
		if tu.isBlank(string: inputBox.text) {
			if inputIsRequired {
				inputBox.placeholder = "Required"
			} else {
				inputBox.placeholder = "Optional"
			}
		}
	}
	
}




















/*

func textFieldDidChangeSelection(_ textField: UITextField) {

let validResult = tu.validateAndFormatField(textField: textField, allowedCharacters: validationAllowedCharacters, maxLength: myConstants.maxLengthCategoryName, accessoryButton: nil)

let isBlank = tu.isBlank(string: textField.text ?? "")

switch validResult {

case true:
// the input is valid

switch inputIsRequired {

case true:
// input is required

if isBlank {
saveButton.isEnabled = false
textField.placeholder = "Required"
} else {
saveButton.isEnabled = true
}

case false:
// input is not requried

saveButton.isEnabled = true

if isBlank {
textField.placeholder = "Optional"
}
}

case false:

// the input is not valid
saveButton.isEnabled = false

if textField.text?.count ?? 0 > maxLength {
counterLabel.textColor = myTheme.invalidFieldEntryColor
} else {
textField.textColor = myTheme.colorText
}
}











updateCounterText()

saveButton.isEnabled = inputIsValid
saveButton.updateBackgroundColor()
}

*/
