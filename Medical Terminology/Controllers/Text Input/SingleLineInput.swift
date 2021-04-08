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
	
	var fieldTitle: String = "DEFAULT"
	var inputFieldText: String = "DEFAULT"
	var validationText: String = "DEFAULT"
	var validationAllowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789"
	var isRequired = true
	var maxLength = 100
	
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
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
				
		let result = tu.formatTextField(textField: textField, allowedCharacters: validationAllowedCharacters, maxLength: myConstants.maxLengthCategoryName, accessoryButton: nil)
		
		if result {
			if !tu.isBlank(string: textField.text ?? "") {
				inputIsValid = true
			} else {
				inputIsValid = false
			}
		} else {
			inputIsValid = false
		}
		
		saveButton.isEnabled = inputIsValid
		saveButton.updateBackgroundColor()
	}
	
}

