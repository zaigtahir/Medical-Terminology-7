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
	let newCategorySelectedNotification = "com.theappgalaxy.newCategorySelectedNotification"
	
	// MARK: - Term Controller notifications
	let termInformationChangedNotification = "com.theappgalaxy.termInformationChangedNotification"
	
	let termAssignedCategoryNotification = "com.theappgalaxy.termAssignedCategoryNotification"
	
	let termUnassignedCategoryNotification = "com.theappgalaxy.termUnassignedCategoryNotification"
	
	// MARK: - Category controller notifications
	let categoryAddedNotification = "com.theappgalaxy.categoryAddedNotification"
	
	let categoryDeletedNotification = "com.theappgalaxy.categoryDeletedNotification"
	
	let categoryNameUpdatedNotification = "com.theappgalaxy.categoryNameUpdatedNotification"
}

