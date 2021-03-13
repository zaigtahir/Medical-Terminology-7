//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class FlashCardVCH {
	
	private var favoriteMode = false
	private var categoryToView = 0
	
	var viewMode : FlashCardViewMode = .both
	
	var listFull = [Int]()	// full list of the given category
	var listFavorite = [Int]()	// favorite list of the given category
	
	let dIC  = DItemController()
	let dIC2 = DItemController2()
	
	init() {
		
		//listFull  = dIC.getItemIDs(favoriteState: -1, learnedState: -1)
		//listFavorite  = dIC.getItemIDs(favoriteState: 1, learnedState: -1)
	
		makeLists(categoryType: .standard, categoryID: 1)
	}
	
	func makeLists (categoryType: CategoryType, categoryID: Int) {
		
		// make full list
		let query = dIC2.whereString(catetoryType: categoryType, categoryID: categoryID, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		
		print (query)
		listFull = dIC2.getItemIDs(categoryType: categoryType, whereQuery: query)
		
		// make favorite list
		let queryFavorite = dIC2.whereString(catetoryType: categoryType, categoryID: categoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		listFavorite = dIC2.getItemIDs(categoryType: categoryType, whereQuery: queryFavorite)
		
	}
	
	func setFavoriteMode (isFavoriteMode: Bool) {
		if isFavoriteMode {
			self.favoriteMode = true
			listFavorite = dIC.getItemIDs(favoriteState: 1, learnedState: -1)
		} else {
			self.favoriteMode = false
		}
	}
	
	func getFavoriteMode () -> Bool {
		return favoriteMode
	}
	
}
