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
	@IBOutlet weak var scrollView: UIScrollView!
	
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
		
		textView.addDoneButton(title: "Done", target: self, selector:  #selector(tapDone(sender:)))
		
		titleLabel.text = textInputVCH.fieldTitle
		validationLabel.text = textInputVCH.validationPrompt
		textView.text = textInputVCH.initialText
	
		// perform initial validation and set up of controls
		textViewDidChangeSelection(textView)
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if self.isMovingFromParent {
			let cleanText = textInputVCH.getCleanText(inputString: textView.text)
			
			delegate?.shouldUpdateMultiLineInfo (propertyReference: textInputVCH.propertyReference, cleanString: cleanText)
		}
	}

	func textViewDidChangeSelection(_ textView: UITextView) {
		// check for valid text
		if textInputVCH.textMeetsAllCriteria(inputString: textView.text) {
			textView.textColor = myTheme.colorText
			
			// make save button enabled
			navigationItem.hidesBackButton = false
			
		} else {
			textView.textColor = myTheme.invalidFieldEntryColor
			
			// make save button enabled
			navigationItem.hidesBackButton = true
		}
		
		// update counter
		counterLabel.text = String (textInputVCH.maxLength - textInputVCH.getCleanText(inputString: textView.text).count)
		
		if textInputVCH.meetsMaxLengthCriteria(inputString: textView.text) {
			counterLabel.textColor = myTheme.colorText
		} else {
			counterLabel.textColor = myTheme.invalidFieldEntryColor
		}
	}
	
	// done button on the keyboard
	@objc func tapDone(sender: Any) {
		self.view.endEditing(true)
	}

	
	@IBAction func cancelButtonAction(_ sender: Any) {
		
		//place the original text back
		textView.text = textInputVCH.initialText
		
		self.navigationController?.popViewController(animated: true)
	}
}
