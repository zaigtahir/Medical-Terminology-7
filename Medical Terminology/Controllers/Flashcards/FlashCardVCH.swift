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
	var currentCategory = Category()
	var showFavoritesOnly = false
	var viewMode : FlashcardViewMode = .both
	
	let categoryC = CategoryController()
	
	var itemIDs = [Int]()	// list to show
	

	let dIC2 = DItemController2()
	
	init() {
		updateCategory()
	}
	
	func updateCategory () {
		let categoryC = CategoryController()
		currentCategory = categoryC.getCurrentCategory()
		makeList()
	}
	
	func makeList () {
		//make the list based on the view state values
		
		itemIDs  = [1,2,3,4,5,6]
	}
	
	func getFavoriteCount () -> Int {
		//return the count of favorites or this catetor

		return 777
	}
	
}
