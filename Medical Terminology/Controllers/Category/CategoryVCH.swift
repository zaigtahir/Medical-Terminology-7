//
//  CategoryVCH2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol CategoryVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
	func shouldAlertDuplicateCategoryName()
}

// this will be used by the CategoryListVCH
protocol CategoryEditDelegate: AnyObject {
	func categoryDeleted (categoryID: Int)
	func categoryAdded ()
}

class CategoryVCH: SingleLineInputDelegate, MultiLineInputDelegate {
	
	// MARK: -seque variables
	
	// TO REMOVE
	//var category : Category!
	
	// need to set this so that I know what to do when deleting a category
	var currentCategoryIDs : [Int]!
	
	// end segue variables
	
	
	// updated variables
	private var initialCategory: Category!
	
	var editedCategory = Category ()

	weak var delegate: CategoryVCHDelegate?
	
	weak var delegateEdit: CategoryEditDelegate?

	private var singleLineInputVC : SingleLineInputVC!
	
	private var multiLineInputVC : MultiLineInputVC!
	
	private let cc = CategoryController()
	
	init () {
		
	}
	
	func setInitialCategory (category: Category) {
		self.initialCategory = category
		editedCategory.categoryID = category.categoryID
		editedCategory.name = category.name
		editedCategory.description = category.description
		editedCategory.isStandard = category.isStandard
	}
	
	func categoryWasEdited () -> Bool {
		
		if initialCategory.name != editedCategory.name {return true}
		if initialCategory.description != editedCategory.description {return true}
		
		return false
	}
	
	
	
	// MARK: - segue functions
	
	func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueSingleLineInput:

			prepareSingleLineInputVC(segue: segue)
	
		case myConstants.segueMultiLineInput:
		
			prepareMultiLineInputVC(segue: segue)
		default:
			print("fatal error, called with an unexpecting segue in categoryVC prepare for segue")
		}
	}
	
	private func prepareSingleLineInputVC (segue: UIStoryboardSegue) {

		// setting the class variable
		singleLineInputVC = segue.destination as? SingleLineInputVC
		
		singleLineInputVC.textInputVCH.fieldTitle = "CATEGORY NAME"
		singleLineInputVC.textInputVCH.initialText = editedCategory.name
		singleLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		singleLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
		singleLineInputVC.textInputVCH.minLength = 1
		singleLineInputVC.textInputVCH.maxLength = myConstants.maxLengthCategoryName
		singleLineInputVC.textInputVCH.propertyReference = .none
		singleLineInputVC.delegate = self

	}
	
	func prepareMultiLineInputVC (segue: UIStoryboardSegue) {
		
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "DESCRIPTION"
		multiLineInputVC.textInputVCH.initialText = editedCategory.description
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthCategoryDescription
		multiLineInputVC.textInputVCH.propertyReference = .definition
		multiLineInputVC.delegate = self
		
	}

	func saveNewCategory() {
		cc.addCategory (category: editedCategory)
		
		// CategoryListVCH will be the delegate
		delegateEdit?.categoryAdded()
	}
	
	func updateCategoryPN () {
		
		// will update the db with values from the edited category, and set the edited category as the initial term so that when the display refreshes, the VC will show the saved state
		
		let originalName = initialCategory.name
	
		// reset the editedCategory as the initialCategory
		setInitialCategory(category: editedCategory)
		
		cc.updateCategory(category: editedCategory)
		
		if originalName != editedCategory.name {
				let nName = Notification.Name(myKeys.categoryNameChangedKey)
				NotificationCenter.default.post(name: nName, object: self, userInfo: ["categoryID" : editedCategory.categoryID])
		}
		
		
		delegate?.shouldUpdateDisplay()
		
	}
	
	func deleteCategory () {
		
		// delete the category
		cc.deleteCategory(categoryID: editedCategory.categoryID)
		
		// CategoryListVCH will be the delegate
		delegateEdit?.categoryDeleted(categoryID: editedCategory.categoryID)
		
	}
	
	// MARK: - delegate functions
	func shouldUpdateSingleLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if editedCategory.name == cleanString {
			// nothing changed, just pop off the input vc
			singleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		if !cc.categoryNameIsUnique(name: cleanString, notIncludingCategoryID: editedCategory.categoryID) {
			// this is a duplicate category name
			delegate?.shouldAlertDuplicateCategoryName()
			return
		}
		
		editedCategory.name = cleanString
		delegate?.shouldUpdateDisplay()
		singleLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	func shouldUpdateMultiLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if editedCategory.description == cleanString {
			// nothing changed, just pop off the input vc
			singleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		editedCategory.description = cleanString
	
		delegate?.shouldUpdateDisplay()
	
		multiLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	
}


