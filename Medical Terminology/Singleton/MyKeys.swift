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
	
	let currentCategoryIDsChanged = "com.theappgalaxy.currentCategoresChanged"
	
	// MARK: - notifications for categories
	
	let categoryNameChangedKey = "com.theappgalaxy.categoryNameUpdatedNotification"
	
	let categoryAdded = "com.theappgalaxy.categoryAdded"
	
	let categoryDeleted = "com.theappgalaxy.categoryDeleted"
	
	// MARK: - notifications for terms

	
	let termAddedKey = "com.theappgalaxy.termAdded"

	let termChangedKey = "com.theappgalaxy.termChanged"
	
	let termDeletedKey = "com.theappgalaxy.termDeleted"
	
	let termFavoriteStatusChanged = "com.theappgalaxy.termFavoriteStatusChanged"
	
	
	// thi is used in CategoryListVCH... just check ..
	// im using it when assignign categories to a term.. probably don't need it
	let termCategoryIDsChanged = "com.theappgalaxy.termCategoryIDsChanged"
	
	
	//REMOVE
	// MARK: - CategoryVCH notifications (TO REMOVE)
	let currentCategoryChangedKey = "com.theappgalaxy.currentCategoryChanged"
	
	// MARK: - Term Controller notifications
	let setFavoriteStatusKey = "com.theappgalaxy.termInformationChangedNotification"
	
}

