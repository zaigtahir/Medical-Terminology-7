//
//  CategoryVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/28/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var headerImage: UIImageView!
	@IBOutlet weak var promptLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var commitButton: UIButton!
	
	let categoryVCH = CategoryVCH()
	let tu = TextUtilities()
	
	var originalTextColor : UIColor!
	let invalidTextColor = UIColor.red
	
	// valid states, to use for saving field validations and enabling the save button
	
	var categoryNameIsValid = false
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		textField.delegate = self
		
		//adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		commitButton.layer.cornerRadius = myConstants.button_cornerRadius
		commitButton.isEnabled = false
		myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
		
		switch categoryVCH.categoryDisplayMode {
		
		case .add:
			headerImage.image = myTheme.imageHeaderAdd
			promptLabel.text = "Add a New Category"
			messageLabel.text = "After you add a new category, you can assign terms to it to help organize your learning"
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
	
		case .edit:
			headerImage.image = myTheme.imageHeaderEdit
			promptLabel.text = "Edit This Category"
			messageLabel.text = "Make changes to the category name"
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
			
		case .delete:
			headerImage.image = myTheme.imageHeaderDelete
			promptLabel.text = "Delete This Category?"
			messageLabel.text = "When you delete a category, no terms are deleted"
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = false
			commitButton.setTitle("Delete", for: .normal)
		}
		
	}
	
	private func setCommitButtonState() {
		
		//look at the field's validations states. If all are valid, set the commit button to enabled
		// format the commit button as it has custom colors
		
		if categoryNameIsValid {
			commitButton.isEnabled = true
			myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
			
		} else {
			commitButton.isEnabled = false
			myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
		}
	
	}
	
	func textFieldDidChangeSelection(_ textField: UITextField) {
		//don't worry about removing characters
		let ac = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789-:!?."
		
		if tu.ztIsTextValid(inputString: textField.text!, allowedCharacters: ac, maxLength: 30) {
			textField.textColor = originalTextColor
			
			if tu.isBlank(string: textField.text!) {
				categoryNameIsValid = false
			} else {
				categoryNameIsValid = true
			}

			setCommitButtonState()
		} else {
			categoryNameIsValid = false
			textField.textColor = invalidTextColor
			setCommitButtonState()
		}
	}
	
	// MARK: -Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
		
	@IBAction func commitButtonAction(_ sender: Any) {
		// should also resign the textfield first responder as the user may have pressed that before pressing /Users/zaighamtahir/Google Drive/Medical Terminology 6/Medical Terminology/Controllers/Flashcardsthe return key on the keyboard
		textField.resignFirstResponder()
		
	}
	
	@IBAction func cancelButtonAction(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
}
