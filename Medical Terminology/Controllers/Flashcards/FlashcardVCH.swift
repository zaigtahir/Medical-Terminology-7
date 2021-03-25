//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FlashCardVCHDelegate: class {
	func updateHomeDisplay()		// update state of other controls on the flashcard home screen
	func refreshCollectionView()	// reload all the data
	func refreshCurrentCell()
}

class FlashcardVCH: NSObject, UICollectionViewDataSource, FlashcardCellDelegate, FlashcardOptionsDelegate,  ScrollControllerDelegate {
	
	// holds state of the view
	var currentCategory : Category2! 	// will need to initialze it with the current category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var viewMode : FlashcardViewMode = .both
	let mainSectionName = MainSectionName.flashcards
	
	weak var delegate: FlashCardVCHDelegate?
	
	// controllers
	let tc = TermController()
	let cc = CategoryController2()
	
	let dIC = DItemController3()	//to remove
	
	let cC = CategoryController()	//to remove
	
	var termIDs = [Int]()	// list to show
	
	override init() {
		super.init()
		refreshCategory()
	}
	
	func refreshCategory () {
		// get the current category from the db
		// set as the local current category
		
		// simulation
		cc.setCategoryID(mainSectionName: mainSectionName, categoryID: 1)
		let id = cc.getCategoryID(mainSectionName: mainSectionName)
		currentCategory = cc.getCategory(categoryID: id)
		makeList()
	}
	
	func makeList () {
		// make the list based on the view state values
		// have not accounted for learned/unlearned flash cards
		
		termIDs = tc.getTermIDs(categoryID: currentCategory.categoryID, showOnlyFavorites: showFavoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
		
	}
	
	func getFavoriteCount () -> Int {
		//return the count of favorites or this catetory
		return dIC.getCount(catetoryID: currentCategory.categoryID, isFavorite: true)
	}
	
	// MARK: - CollectionViewDataSource Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		termIDs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flashCardCell", for: indexPath) as! FlashcardCell
		
		//the cell should configure itself
		let dItem  = dIC.getDItem(itemID: termIDs[indexPath.row])
		let countText = "Flashcard: \(indexPath.row + 1) of \(termIDs.count)"
		cell.configure(dItem: dItem, fcvMode: viewMode, counter: countText)
		cell.delegate = self
		return cell
	}
	
	// MARK: - Cell delegate protocol
	
	func userPressedFavoriteButton(itemID: Int) {
		dIC.toggleIsFavorite (itemID: itemID)
		delegate?.updateHomeDisplay()
	}
	
	// MARK: - Scroll delegate protocol
	
	func CVCellChanged(cellIndex: Int) {
		delegate?.updateHomeDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		// here to meet the delegate requirement, but will not be using this function here
	}
	
	// MARK: Delegate fuctions for CategoryHomeVCDelegate
	
	func newCategorySelected() {
		self.refreshCategory()
		delegate?.refreshCollectionView()
		delegate?.updateHomeDisplay()
	}
	
	// MARK: Flashcard options delegate
	func flashCardViewModeChanged(fcvMode: FlashcardViewMode) {
		self.viewMode = fcvMode
		delegate?.refreshCurrentCell()
	}
}
