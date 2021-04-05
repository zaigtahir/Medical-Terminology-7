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
	var currentCategoryID: Int {get set}
	var showFavoritesOnly: Bool {get set}
	
	// functions to implement
	func getFavoriteCount () -> Int
	func getCategoryCount () -> Int
	func getSearchCount   () -> Int
		
	// term notifications
	func setFavoriteStatusN (notification: Notification)
	
	
	// category notifications
	func currentCategoryChangedN (notification: Notification)
	func addCategoryN (notification: Notification)
	func deleteCategoryN (notification: Notification)
	func changeCategoryNameN (notification: Notification)
	func assignCategoryN (notification: Notification)
	func unassignCategoryN  (notification: Notification)

}
