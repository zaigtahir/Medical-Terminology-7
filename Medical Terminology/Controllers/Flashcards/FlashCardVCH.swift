//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class FlashCardVCH {
	
	//holds state of the view
	var showFavoritesOnly = false
	var category = Category()
	
	var viewMode : FlashCardViewMode = .both
	
	var itemIDs = [Int]()	// list to show
	
	let dIC  = DItemController()
	let dIC2 = DItemController2()
	
	init() {
		updateCategory(categoryID: 1)
	}
	
	func updateCategory (categoryID: Int) {
		let categoryC = CategoryController()
		category = categoryC.getCategory(categoryID: 1)!
		makeList()
	}
	
	func makeList () {
		//make the list based on the view state values
		let whereString = dIC2.whereString(catetoryType: category.type, categoryID: category.categoryID, isFavorite: showFavoritesOnly, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		
		itemIDs  = dIC2.getItemIDs(categoryType: category.type, whereQuery: whereString)
	}
	
	func getFavoriteCount () -> Int {
		//return the count of favorites or this catetory
		let whereString = dIC2.whereString(catetoryType: category.type, categoryID: category.categoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		
		let favoritesCount = dIC2.getCount(categoryType: category.type, whereQuery: whereString)
	
		return favoritesCount
	}
	
}
