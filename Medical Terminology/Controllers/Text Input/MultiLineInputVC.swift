//
//  TextInputVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/7/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol MultiLineInputDelegate: AnyObject {
	func shouldUpdateMultiLineInfo(inputVC: MultiLineInputVC, editingPropertyType: EditingPropertyType?, cleanString: String)
}

// shouldUpdateMultiLineInfo

class MultiLineInputVC: UIViewController, UITextViewDelegate {
	
	//
	//  textInputVC.swift
	//  Medical Terminology
	//
	//  Created by Zaigham Tahir on 4/7/21.
	//  Copyright © 2021 Zaigham Tahir. All rights reserved.
	//
	
	@IBOutlet weak var headerImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var inputBox: UITextView!
	@IBOutlet weak var counterLabel: UILabel!
	@IBOutlet weak var validationLabel: UILabel!
	@IBOutlet weak var saveButton: ZUIRoundedButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	var fieldTitle: String = "DEFAULT"
	var inputFieldText: String?
	var validationText: String = "DEFAULT"
	var validationAllowedCharacters = "DEFAULT"
	var inputIsRequired = true
	var maxLength = 20
	var editingPropertyType: EditingPropertyType?
	
	private var originalText : String?
	
	
	weak var delegate: MultiLineInputDelegate?
	
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		inputBox.delegate = self
		
		// adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		
		// add a border to the text view
		inputBox.layer.borderWidth = 1
		inputBox.layer.borderColor = myTheme.colorCardBorder?.cgColor
		
		
		titleLabel.text = fieldTitle
		inputBox.text = inputFieldText
		validationLabel.text = validationText
		
		// backed up original to compare to the textbox.text when validating
		originalText = inputFieldText
		
		// perform initial validation and set up of controls
		
		// no change is made yet as the information is just loaded, so disable the save button
		saveButton.isEnabled = false
		
	}
	
	func textViewDidChange(_ textView: UITextView) {
		print("info changed")
	}
	
	
	/*
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
	textField.resignFirstResponder()
	return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
	
	print("called textFieldDidChangeSelection")
	
	// check for valid characters
	let textContainsValidCharacters = tu.textIsValid(inputString: inputBox.text ?? "", allowedCharacters: validationAllowedCharacters)
	
	if textContainsValidCharacters {
	inputBox.textColor = myTheme.colorText
	} else {
	inputBox.textColor = myTheme.invalidFieldEntryColor
	}
	
	// calling these separately. Important to do this if I want them all to run, which they won't do if I place them in a multi-and statement
	
	let meetsMax = meetsMaxLengthCriteria()
	let meetsMin = meetsMinCriteria()
	let isValid = textContainsValidCharacters
	
	// check to see if meeting other criteria
	if (isValid && meetsMin && meetsMax){
	
	saveButton.isEnabled = true
	} else {
	
	saveButton.isEnabled = false
	}
	
	}
	
	*/
	
	
	func hasChangedFromOriginal () -> Bool {
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
			inputBox.textColor = myTheme.invalidFieldEntryColor
			counterLabel.textColor = myTheme.invalidFieldEntryColor
			return false
		} else {
			inputBox.textColor = myTheme.colorText
			counterLabel.textColor = myTheme.colorText
			return true
		}
		
		
	}
	
	private func meetsMinCriteria () -> Bool {
		
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
	
	
	@IBAction func saveButtonAction(_ sender: Any) {
		
		// if the text field contains nothing, default to empty string ""
		delegate?.shouldUpdateMultiLineInfo(inputVC: self, editingPropertyType: self.editingPropertyType, cleanString: inputBox?.text ?? "")
	}
}
