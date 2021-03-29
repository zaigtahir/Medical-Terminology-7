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
	@IBOutlet weak var commitButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	let categoryVCH = CategoryVCH()
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		// setup the view based on the categoryDisplayMode in the header file
		
		textField.delegate = self
	//	textField.addTarget(self, action: #selector(myTextfieldFunction(textfield:)), for: .editingChanged)
		
		// format button
		commitButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		let utilities = Utilities()
		
		switch categoryVCH.categoryDisplayMode {
		
		case .add:
			headerImage.image = myTheme.imageHeaderAdd
			promptLabel.text = "Add a New Category"
			messageLabel.text = "After you add a new category, you can assign terms to it to help organize your learning"
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
			commitButton.backgroundColor = myTheme.colorAddButton
			//commitButton.isEnabled = false
			
		case .edit:
			headerImage.image = myTheme.imageHeaderEdit
			promptLabel.text = "Edit This Category"
			messageLabel.text = "Make changes to the category name"
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
			commitButton.backgroundColor = myTheme.colorEditButton
			
		case .delete:
			headerImage.image = myTheme.imageHeaderDelete
			promptLabel.text = "Delete This Category?"
			messageLabel.text = "When you delete a category, no terms are deleted"
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = false
			commitButton.setTitle("Delete", for: .normal)
			commitButton.backgroundColor = myTheme.colorDeleteButton
		}
		
		// format the commit button as it has custom colors
		myTheme.formatButtonColor(button: commitButton, enabledColor: myTheme.colorMain!)
		
	}
	
	@objc func myTextfieldFunction (textfield: UITextField) {
		// do somethign
		if tu.validateString(string: textField.text!) {
			commitButton.isEnabled = true
			myTheme.formatButtonColor(button: commitButton, enabledColor: myTheme.colorMain!)
			
		} else {
			commitButton.isEnabled = false
			myTheme.formatButtonColor(button: commitButton, enabledColor: myTheme.colorMain!)
			print ("The category name may only contain letters, numbers")
		}
	}
	
	
	// MARK: - UITextFieldDelegate

	let allowedCharacters = CharacterSet(charactersIn:"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz ").inverted

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let components = string.components(separatedBy: allowedCharacters)
		let filtered = components.joined(separator: "")
		
		if string == filtered {
			
			return true

		} else {
			
			return false
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
