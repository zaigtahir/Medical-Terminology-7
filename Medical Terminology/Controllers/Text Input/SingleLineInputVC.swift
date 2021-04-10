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
		
		titleLabel.text = vcc.fieldTitle
		textField.text = vcc.inputFieldText
		validationLabel.text = vcc.validationPrompt
		
		// backed up original to compare to the textbox.text when validating
		originalText = vcc.inputFieldText
		
		// perform initial validation and set up of controls
		textFieldDidChangeSelection(textField)
		
		// no change is made yet as the information is just loaded, so disable the save button
		saveButton.isEnabled = false
		
	}
	
	// Only appplies to the text field
	private func fillInputPlaceHolder () {
		if tu.isBlank(string: textField.text) {
			if vcc.minLength > 0 {
				textField.placeholder = "Required"
			} else {
				textField.placeholder = "Optional"
			}
		}
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		
		// check for valid text
		if vcc.textMeetsAllCriteria(inputString: textField.text) {
			textField.textColor = myTheme.colorText
			saveButton.isEnabled = true
		} else {
			textField.textColor = myTheme.invalidFieldEntryColor
			saveButton.isEnabled = false
		}
		
		// update counter
		counterLabel.text = String (vcc.maxLength - vcc.getCleanText(inputString: textField.text).count)
		
		if vcc.meetsMaxLengthCriteria(inputString: textField.text) {
			counterLabel.textColor = myTheme.colorText
		} else {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
		}
		
		// working
		fillInputPlaceHolder()
	}
	
	@IBAction func saveButtonAction(_ sender: Any) {
		
	// if the text field contains nothing, default to empty string ""
		
		delegate?.shouldUpdateSingleLineInfo(inputVC: self, editingPropertyType: vcc.propertyReference, cleanString: textField?.text ?? "")
	}
}
