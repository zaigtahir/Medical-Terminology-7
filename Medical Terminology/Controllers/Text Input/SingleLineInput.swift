//
//  TextInputVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/7/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

/**
Will display the input view, and prefill the inputFieldText
Will enable/disable save button based on the validitity of the input
If the text input is invalid, will make it red, and will disable the save button
If the text input is blank, it will show (required or optional as  place holder text)
*/
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
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var validationLabel: UILabel!
	@IBOutlet weak var counterLabel: UILabel!
	
	var fieldTitle: String = "DEFAULT"
	var inputFieldText: String?
	var validationText: String = "DEFAULT"
	var validationAllowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789"
	var inputIsRequired = true
	var maxLength = 20
	
	private var inputIsValid = false
	
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		textField.delegate = self
		
		//adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		titleLabel.text = fieldTitle
		textField.text = inputFieldText
		validationLabel.text = validationText
		updateAndFormatCounter()
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		
		let textIsValid = tu.validateAndFormatField(textField: textField, allowedCharacters: validationAllowedCharacters, maxLength: myConstants.maxLengthCategoryName, accessoryButton: nil)
		
		let lengthIsValid = updateAndFormatCounter()
		
		
		
	}
	
	private func updateAndFormatCounter () -> Bool {
		counterLabel.text = String (maxLength - Int(textField.text?.count ?? 0))
		
		if textField.text?.count ?? 0 > maxLength {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
			return false
		} else {
			counterLabel.textColor = myTheme.colorText
			return true
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
