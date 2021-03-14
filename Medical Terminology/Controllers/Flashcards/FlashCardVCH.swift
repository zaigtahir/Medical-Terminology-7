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
	
	let categoryC = CategoryController()
	
	var itemIDs = [Int]()	// list to show
	
	let dIC  = DItemController()
	let dIC2 = DItemController2()
	
	init() {
		//set up categoryID = 1 as the initial category selection in DB and locally
		updateCategory()
	}
	
	func updateCategory () {
		let categoryC = CategoryController()
		category = categoryC.getSelectedCategory()
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
