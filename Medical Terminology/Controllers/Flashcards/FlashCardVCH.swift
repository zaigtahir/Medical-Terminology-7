//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class FlashCardVCH {
	
	// holds state of the view
	var currentCategory : Category! 	// will need to initialze it with the current category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var viewMode : FlashcardViewMode = .both
	
	// controllers
	let dIC = DItemController3()
	let cC = CategoryController()
	
	var itemIDs = [Int]()	// list to show
	
	
	init() {
		refreshCategory()
	}
	
	func refreshCategory () {
		// get the current category from the db
		// set as the local current category
		currentCategory = cC.getCurrentCategory()
		makeList()
	}
	
	func makeList () {
		//make the list based on the view state values
		itemIDs  = dIC.getItemIDs(categoryID: currentCategory.categoryID, showOnlyFavorites: showFavoritesOnly)
	}
	
	func getFavoriteCount () -> Int {
		//return the count of favorites or this catetory
		return dIC.getCount(catetoryID: currentCategory.categoryID, isFavorite: true)
	}
	
}
