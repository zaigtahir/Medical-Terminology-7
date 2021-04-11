//
//  TextInputVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/7/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol MultiLineInputDelegate: AnyObject {
	func shouldUpdateMultiLineInfo(propertyReference: PropertyReference?, cleanString: String)
}

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
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var counterLabel: UILabel!
	@IBOutlet weak var validationLabel: UILabel!
	@IBOutlet weak var saveButton: ZUIRoundedButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	var textInputVCH = TextInputVCH()
	
	weak var delegate: MultiLineInputDelegate?
	
	let tu = TextUtilities()
	
	override func viewDidLoad() {
	
		super.viewDidLoad()
		
		textView.delegate = self
		
		// adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		
		// add a border to the text view
		textView.layer.borderWidth = 1
		textView.layer.borderColor = myTheme.colorCardBorder?.cgColor
		
		
		titleLabel.text = textInputVCH.fieldTitle
		validationLabel.text = textInputVCH.validationPrompt
		textView.text = textInputVCH.initialText
	
		// perform initial validation and set up of controls
		textViewDidChangeSelection(textView)
		
		// no change is made yet as the information is just loaded, so disable the save button
		saveButton.isEnabled = false
		
	}
	
	func textViewDidChangeSelection(_ textView: UITextView) {
		// check for valid text
		if textInputVCH.textMeetsAllCriteria(inputString: textView.text) {
			textView.textColor = myTheme.colorText
			saveButton.isEnabled = true
		} else {
			textView.textColor = myTheme.invalidFieldEntryColor
			saveButton.isEnabled = false
		}
		
		// update counter
		counterLabel.text = String (textInputVCH.maxLength - textInputVCH.getCleanText(inputString: textView.text).count)
		
		if textInputVCH.meetsMaxLengthCriteria(inputString: textView.text) {
			counterLabel.textColor = myTheme.colorText
		} else {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
		}
	}
	
	@IBAction func saveButtonAction(_ sender: Any) {
		
		// if the text field contains nothing, default to empty string ""
		
		let cleanText = textInputVCH.getCleanText(inputString: textView.text)
		
		delegate?.shouldUpdateMultiLineInfo (propertyReference: textInputVCH.propertyReference, cleanString: cleanText)
	}
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
}
