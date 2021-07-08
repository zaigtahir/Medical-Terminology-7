//
//  Keys.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 2/26/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class MyKeys {
    
    //keys to save data in the userDefaults
	
	let appVersion = "appVersion"
	let appBuild =  "appBuild"
	let showWelcomeScreen = "showWelcomeScreen"
	let appPurchaseStatus = "appPurchaseStatus"
	
	
	// MARK: - notifications for currentCategoryIDs
	
	let currentCategoryIDsChangedKey = "com.theappgalaxy.currentCategoresChanged"
	
	// MARK: - notifications for categories
	
	let categoryNameChangedKey = "com.theappgalaxy.categoryNameUpdatedNotification"
	
	let categoryAddedKey = "com.theappgalaxy.categoryAdded"
	
	// MARK: - notifications for terms
	
	let termAddedKey = "com.theappgalaxy.termAdded"

	/**
	Trigger this notification when any term fields (including favorite) changes
	*/
	let termFieldsChangedKey = "com.theappgalaxy.termFieldsChanged"
	
	/**
	Trigger this if the category changes it's id. the category is changing it's categoryID's AND other fields,
	just trigger the termCategoryIDsChangedN as that function will refresh the data and display
	
	TermController.updateTerm
	AssignTermsVCH.didSelectRow
	*/
	let termCategoryIDsChangedKey = "com.theappgalaxy.termCategoryIDsChanged"
	
	let termDeletedKey = "com.theappgalaxy.termDeleted"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// GET RID OF THIS
	/// When favorite is set or unset on a term
	let termFavoriteStatusChanged = "com.theappgalaxy.termFavoriteStatusChanged"
	
}

