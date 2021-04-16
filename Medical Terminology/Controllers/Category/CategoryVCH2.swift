//
//  CategoryVCH2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol CategoryVCH2Delegate: AnyObject {
	func shouldUpdateDisplay()
	
	/// dismiss single or multiline input vc
	func shouldDismissTextInputVC()
	func shouldDisplayDuplicateCategoryNameAlert()
}

class CategoryVCH2: SingleLineInputDelegate, MultiLineInputDelegate {
	
	// if catetory id = -1, you are adding a new catetory
	
	var category : Category2!
	
	weak var delegate: CategoryVCH2Delegate?
	
	// controllers

	private let cc = CategoryController2()
	
	init () {
		
	}
	
	// MARK: - delegate functions
	func shouldUpdateSingleLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		
		if category.name == cleanString {
			// nothing changed
			delegate?.shouldDismissTextInputVC()
		}
		
		if !cc.categoryNameIsUnique(name: cleanString, notIncludingCategoryID: category.categoryID) {
			// this is a duplicate category name
			delegate?.shouldDisplayDuplicateCategoryNameAlert()
			return
		}
		
		category.name = cleanString
		
		if category.categoryID != -1 {
			cc.updateCategoryNamePN(categoryID: category.count, newName: cleanString)
		}
		
		delegate?.shouldUpdateDisplay()
		delegate?.shouldDismissTextInputVC()
		
	}
	
	func shouldUpdateMultiLineInfo(propertyReference: PropertyReference?, cleanString: String) {
		print ("update description")
	}
	
}


