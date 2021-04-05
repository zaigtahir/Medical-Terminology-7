//
//  VCHProtocol.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/5/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

/**
Implement this protocol for the main VCH so they have consistent variables and functions
*/

protocol VCHProtocol {
	
	// properties to contain
	var currentCatetoryID: Int {get set}
	var showFavoritesOnly: Bool {get set}
	
	// functions to implement
	func getFavoriteCount () -> Int
	func getCategoryCount () -> Int
	func getSearchCount   () -> Int
	
	// notification functions
	func currentCategoryChanged (notification: Notification)
	func catetoryAddedNotification (notification: Notification)
	func categoryInformationChanged (notification: Notification)
	func catetoryDeletedNotification (notification: Notification)
	func categoryAssignedNotification (notification: Notification)
	func categoryUnassignedNotification (notification: Notification)
	func categoryDeletedNotification (notification: Notification)

	func updateData ()
	
	
}
