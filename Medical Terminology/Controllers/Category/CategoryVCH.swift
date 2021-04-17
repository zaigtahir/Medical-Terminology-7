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
	func duplicateCatetoryName()
}

class CategoryVCH: SingleLineInputDelegate, MultiLineInputDelegate {
	
	// if catetory id = -1, you are adding a new catetory
	
	var category : Category2!
	
	weak var delegate: CategoryVCHDelegate?

	private var singleLineInputVC : SingleLineInputVC!
	
	private var multiLineInputVC : MultiLineInputVC!
	
	private let cc = CategoryController2()
	
	init () {
		
	}
		
	func saveCategory() {
		let _ = cc.addCategoryPN (category: category)
	}

	func prepareSingleLineInputVC (segue: UIStoryboardSegue) {

		// setting the class variable
		singleLineInputVC = segue.destination as? SingleLineInputVC
		
		singleLineInputVC.textInputVCH.fieldTitle = "CATEGORY NAME"
		singleLineInputVC.textInputVCH.initialText = category.name
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
		multiLineInputVC.textInputVCH.initialText = category.description
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthCategoryDescription
		multiLineInputVC.textInputVCH.propertyReference = .definition
		multiLineInputVC.delegate = self
		
	}


	// MARK: - delegate functions
	func shouldUpdateSingleLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if category.name == cleanString {
			// nothing changed, just pop off the input vc
			singleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		if !cc.categoryNameIsUnique(name: cleanString, notIncludingCategoryID: category.categoryID) {
			// this is a duplicate category name
			delegate?.duplicateCatetoryName()
			return
		}
		
		category.name = cleanString
		
		if category.categoryID != -1 {
			cc.updateCategoryNamePN(categoryID: category.categoryID, newName: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
		singleLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	func shouldUpdateMultiLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if category.description == cleanString {
			// nothing changed, just pop off the input vc
			singleLineInputVC.navigationController?.popViewController(animated: true)
		}
		
		category.description = cleanString
		
		// no notification sent as this is the only VC that will show a category description and it is modal
		
		if category.categoryID != -1 {
			cc.updateCategoryDescription(categoryID: category.categoryID, description: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
	
		multiLineInputVC.navigationController?.popViewController(animated: true)
	}
	
	
}


