//
//  TermVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol TermVCHDelegate: AnyObject {
	func shouldUpdateDisplay()
}

class TermVCH {
	
	var termID : Int!
	var currentCategoryID : Int!
	var displayMode = DisplayMode.view
	
	weak var delegate: TermVCHDelegate?
	
	///set this to true when the user is in edit/add mode and the data is valid to save as a term
	var isReadyToSaveTerm = false
	
	private let tc = TermController()
	
	private let cc = CategoryController2()
	
	init () {

		/*
		Notification keys this controller will need to respond to
		This is a modal view controller, and the only thing that will affect it is when the user assigns/unassigns categories and when the term information is edited
		
		assignCategoryKey
		unassignCategoryKey
		
		*/
		
		let nameACK = Notification.Name(myKeys.assignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(assignCategoryN(notification:)), name: nameACK, object: nil)
		
		let nameUCK = Notification.Name(myKeys.unassignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignCategoryN(notification:)), name: nameUCK, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	@objc func assignCategoryN (notification : Notification) {
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			let currentTermID = tc.getTerm(termID: termID).termID
			
			if currentTermID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		if let data = notification.userInfo as? [String : Int] {
			delegate?.shouldUpdateDisplay()
			
			let affectedTermID = data["termID"]!
			let currentTermID = tc.getTerm(termID: termID).termID
			
			if currentTermID == affectedTermID {
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	func getCategoryNamesText () -> String {
		
		// make list of categories
		let categoryIDs = tc.getTermCategoryIDs(termID: termID)
		var categoryList = ""
		
		for id in categoryIDs {
			if (id != myConstants.dbCategoryMyTermsID) && (id != myConstants.dbCategoryAllTermsID) {
				// note not including id 1 = All terms and 2 = My Terms
				
				let category = cc.getCategory(categoryID: id)
				categoryList.append("\(category.name)\n")
			}
		}
		
		return categoryList
	}
}
