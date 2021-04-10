//
//  TextInputVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/7/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol SingleLineInputDelegate: AnyObject {
	func shouldUpdateSingleLineInfo(inputVC: SingleLineInputVC, editingPropertyType: PropertyReference?, cleanString: String)
}

class SingleLineInputVC: UIViewController, UITextFieldDelegate {
	
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
	var validationAllowedCharacters = "DEFAULT"
	var inputIsRequired = true
	var maxLength = 20
	var editingPropertyType: PropertyReference?
	
	private var originalText : String?
	
	var vcc = TextInputVCC()

	weak var delegate: SingleLineInputDelegate?
	
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
		
		// backed up original to compare to the textbox.text when validating
		originalText = inputFieldText
		
		// perform initial validation and set up of controls
		textFieldDidChangeSelection(textField)
		
		// no change is made yet as the information is just loaded, so disable the save button
		saveButton.isEnabled = false
		
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		
		// check for valid characters
		let textContainsValidCharacters = tu.textIsValid(inputString: textField.text ?? "", allowedCharacters: validationAllowedCharacters)
				
		if textContainsValidCharacters {
			textField.textColor = myTheme.colorText
		} else {
			textField.textColor = myTheme.invalidFieldEntryColor
		}
		
		// calling these separately. Important to do this if I want them all to run, which they won't do if I place them in a multi-and statement
		
		let meetsMax = meetsMaxLengthCriteria()
		let meetsMin = meetsMinCriteria()
		let isValid = textContainsValidCharacters
		
		// check to see if meeting other criteria
		if (isValid && meetsMin && meetsMax){
			textField.textColor = myTheme.colorText
			saveButton.isEnabled = true
		} else {
			textField.textColor = myTheme.invalidFieldEntryColor
			saveButton.isEnabled = false
		}
		
		// working
		fillInputPlaceHolder()
	}
	
	func hasChangedFrom44Original () -> Bool {
		let cleanText = tu.removeLeadingTrailingSpaces(string: textField.text ?? "")
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
		
		counterLabel.text = String (maxLength - Int(textField.text?.count ?? 0))
		
		if textField.text?.count ?? 0 > maxLength {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
			return false
		} else {
			counterLabel.textColor = myTheme.colorText
			return true
		}
	}
	
	private func meetsMinCriteria () -> Bool {
		
		let cleanText = tu.removeLeadingSpaces(input: textField.text ?? "")
		
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
	
	private func fillInputPlaceHolder () {
		if tu.isBlank(string: textField.text) {
			if inputIsRequired {
				textField.placeholder = "Required"
			} else {
				textField.placeholder = "Optional"
			}
		}
	}
	
	@IBAction func saveButtonAction(_ sender: Any) {
		
	// if the text field contains nothing, default to empty string ""
		
		delegate?.shouldUpdateSingleLineInfo(inputVC: self, editingPropertyType: self.editingPropertyType, cleanString: textField?.text ?? "")
	}
}
