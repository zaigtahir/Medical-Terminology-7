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
	
	
	// MARK: - CategoryVCH notifications
	let currentCategoryChangedKey = "com.theappgalaxy.currentCategoryChanged"
	
	// MARK: - Term Controller notifications
	let termFavoriteStatusChangedKey = "com.theappgalaxy.termInformationChangedNotification"
	
	let assignCategoryKey = "com.theappgalaxy.termAssignedCategoryNotification"
	
	let unassignCategoryKey = "com.theappgalaxy.termUnassignedCategoryNotification"
	
	// MARK: - Category controller notifications
	let addCategoryNK = "com.theappgalaxy.categoryAddedNotification"
	
	let deleteCategoryKey = "com.theappgalaxy.categoryDeletedNotification"
	
	let changeCategoryNameKey = "com.theappgalaxy.categoryNameUpdatedNotification"
}

