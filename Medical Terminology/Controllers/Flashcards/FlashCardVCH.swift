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
	var categoryType: CategoryType = .standard
	var categoryID = 1
	
	var viewMode : FlashCardViewMode = .both
	
	var ItemIDs = [Int]()	// list to show
	
	let dIC  = DItemController()
	let dIC2 = DItemController2()
	
	init() {
			makeList()
	}
	
	func makeList () {
		//make the list based on the view state values
		let whereString = dIC2.whereString(catetoryType: categoryType, categoryID: categoryID, isFavorite: showFavoritesOnly, answeredTerm: .none, answeredDefinition: .none, learnedState: .none)
		
		let itemIDs  = dIC2.getItemIDs(categoryType: categoryType, whereQuery: whereString)
	}
	
}
