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
	@IBOutlet weak var questionButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var commitButton: UIButton!
	
	let categoryVCH = CategoryVCH()
	let tu = TextUtilities()
	
	let cc = CategoryController2()
	
	// valid states, to use for saving field validations and enabling the save button
	
	var categoryNameIsValid = true	// just to start so if the user presses the question button, it does not show a red color header icon in the ValidationVC
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		textField.delegate = self
		
		//adding a tap gesture recognizer to dismiss the keyboard
		let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
		view.addGestureRecognizer(tapGesture)
		
		commitButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		switch categoryVCH.categoryDisplayMode {
		
		case .add:
			headerImage.image = myTheme.imageHeaderAdd
			promptLabel.text = "Add a New Category"
			messageLabel.text = "After you add a new category, you can assign terms to it to help organize your learning"
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
			questionButton.isEnabled = true
			commitButton.isEnabled = false
			myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
			
		case .delete:
			headerImage.image = myTheme.imageHeaderDelete
			promptLabel.text = "Delete This Category?"
			messageLabel.text = "Terms in this category will not be deleted. They will remain in other categories."
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = false
			
			//innerSquare.leftAnchor.constraint(equalTo: outerSquare.leftAnchor, constant: 40)
			
			questionButton.isEnabled = false
			commitButton.setTitle("Delete", for: .normal)
			commitButton.isEnabled = true
			myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorButtonDelete)
			
		default:
			// add
			
			headerImage.image = myTheme.imageHeaderEdit
			promptLabel.text = "Edit This Category"
			messageLabel.text = "Make changes to the category name"
			textField.text = categoryVCH.affectedCategory.name
			textField.isUserInteractionEnabled = true
			questionButton.isEnabled = true
			commitButton.setTitle("Save", for: .normal)
			commitButton.isEnabled = true
			myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
			
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
		
		let ac = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789-:!?. "
		let result = tu.formatTextField(textField: textField, allowedCharacters: ac, maxLength: myConstants.maxLengthCategoryName, accessoryButton: questionButton)
		if result {
			if !tu.isBlank(string: textField.text ?? "") {
				categoryNameIsValid = true
			} else {
				categoryNameIsValid = false
			}
		} else {
			categoryNameIsValid = false
		}
		
		updateSaveButtonStatus()
	}
	
	private func updateSaveButtonStatus () {
		//enable it if all textfields are valid (only one in this controller)
		commitButton.isEnabled = categoryNameIsValid
		myTheme.formatButtonState(button: commitButton, enabledColor: myTheme.colorMain!)
	}
	
	private func showNameIsDuplicateAlert () {
		let ac = UIAlertController(title: "Duplicate Name", message: "There is already a category with this name. Please choose a different name", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		ac.addAction(ok)
		self.present(ac, animated: true, completion: nil)
	}
	
	// MARK: - Textfield delegate methods
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: - name saving functions
	
	// MARK: - segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// there is only one segue to validationVC
		let vc = segue.destination as? ValidationVC
		
		// trimming the content to get the count of characters without spaces on ends
		let text = textField.text ?? ""
		let trimmed = tu.trimEndSpaces(string: text)
		
		vc?.isValid = categoryNameIsValid
		vc?.message = """
			The name can contain only letters, numbers and these characters ! : , ?

			The length can be maximum of \(myConstants.maxLengthCategoryName) characters. You currently have \(trimmed.count) characters entered.
			"""
	}
	
	@IBAction func commitButtonAction(_ sender: Any) {
		// should also resign the textfield first responder as the user may have pressed that before dismissing the keyboard
		textField.resignFirstResponder()
		
		
		// trimming the content to remove spaces
		let text = textField.text ?? ""
		let trimmedName = tu.trimEndSpaces(string: text)
		
		switch categoryVCH.categoryDisplayMode {
					
		case .delete:
			cc.deleteCategoryAndPostNotification(categoryID: categoryVCH.affectedCategory.categoryID)
			self.navigationController?.popViewController(animated: true)
			
		case .edit:
			
			if cc.isCategoryNameDuplicate(name: trimmedName) {
				showNameIsDuplicateAlert()
			}
			
			let cID = categoryVCH.affectedCategory.categoryID
			
			cc.updateCategoryNameAndPostNotification (categoryID: cID, newName: trimmedName)
			
			self.navigationController?.popViewController(animated: true)
			
		default:
			// add
			if cc.isCategoryNameDuplicate(name: trimmedName) {
				showNameIsDuplicateAlert()
				return
			}
			cc.addCategoryAndPostNotification(categoryName: trimmedName)
			self.navigationController?.popViewController(animated: true)
			
		}
	}
	
	@IBAction func cancelButtonAction(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
}
