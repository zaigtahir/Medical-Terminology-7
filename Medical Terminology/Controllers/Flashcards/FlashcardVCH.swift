//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FlashcardHomeDelegate: AnyObject {
	func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	func shouldRefreshCollectionView()	// reload all the data
	func shouldRefreshCurrentCell()
	func shouldReloadCellAtIndex (termIDIndex: Int)
	func shouldRemoveCellAt(indexPath: IndexPath)
}

class FlashcardVCH: NSObject, UICollectionViewDataSource, FlashcardCellDelegate, FlashcardOptionsDelegate,  ScrollControllerDelegate {
	
	// holds state of the view
	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var viewMode : FlashcardViewMode = .both
	
	// which tab to show: learning vs learned
	var learnedStatus = false
	
	weak var delegate: FlashcardHomeDelegate?
	
	// controllers
	let tc = TermController()
	let cc = CategoryController2()
	let utilities = Utilities()
	
	var termIDs = [Int]()	// list to show
	
	override init() {
		super.init()
		
		updateData()
		
		/*
		Notification keys this controller will need to respond to
		
		currentCategoryChangedKey
		setFavoriteStatusKey
		assignCategoryKey
		unassignCategoryKey
		deleteCategoryKey
		changeCategoryNameKey
		*/
		
		let nameCCCN = Notification.Name(myKeys.currentCategoryChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryChangedN(notification:)), name: nameCCCN, object: nil)
		
		let nameSFK = Notification.Name(myKeys.setFavoriteStatusKey)
		NotificationCenter.default.addObserver(self, selector: #selector(setFavoriteStatusN (notification:)), name: nameSFK, object: nil)
		
		let nameACK = Notification.Name(myKeys.assignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(assignCategoryN(notification:)), name: nameACK, object: nil)
		
		let nameUCK = Notification.Name(myKeys.unassignCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignCategoryN(notification:)), name: nameUCK, object: nil)
		
		let nameDCK = Notification.Name(myKeys.deleteCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteCategoryN (notification:)), name: nameDCK, object: nil)
		
		let nameCCN = Notification.Name(myKeys.changeCategoryNameKey)
		NotificationCenter.default.addObserver(self, selector: #selector(changeCategoryNameN(notification:)), name: nameCCN, object: nil)
		
		let nameTIC = Notification.Name(myKeys.termInformationChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termInformationChangedN(notification:)), name: nameTIC, object: nil)
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	
	@objc func currentCategoryChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : Int] {
			
			//there will be only one data here, the categoryID
			currentCategoryID = data["categoryID"]!
			updateDataAndDisplay()
		}
	}
	
	@objc func setFavoriteStatusN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			switch showFavoritesOnly {
			
			case true:
				// seeing favorites only, and a term may have been added or removed from this list so need to reload the whole list
				
				let favoriteStatus = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: affectedTermID)
				
				switch favoriteStatus {
				case true:
					// term is made favorite from elsewhere in the program, need to reload all data and update the display
					updateData()
					delegate?.shouldRefreshCollectionView()
					delegate?.shouldUpdateDisplay()
					
				case false:
					// term was made unfavorite, need to remove just that data from the model, and animate the removal of the cell in the table
					
					if let firstIndex = termIDs.firstIndex(of: affectedTermID) {
						termIDs = utilities.removeIndex(index: firstIndex, array: termIDs)
						
						delegate?.shouldRemoveCellAt (indexPath: IndexPath(row: firstIndex, section: 0))
						
						delegate?.shouldUpdateDisplay()
					}
					
				}
				
				
			case false:
				// if this term id exists in termIDs, need to reload that term from the database and then reload just that term in the collection
				
				if let termIDIndex = termIDs.firstIndex(of: affectedTermID) {
					delegate?.shouldReloadCellAtIndex(termIDIndex: termIDIndex)
					delegate?.shouldUpdateDisplay()
				}
			}
		}
	}
	
	
	// MARK: ADD notification for term information changed (different than favorite status changed)
	
	@objc func termInformationChangedN (notification: Notification) {
	
		print ("got term informtion changed notification in flashcardVCH")
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			if let termIDIndex = termIDs.firstIndex(of: affectedTermID) {
				delegate?.shouldReloadCellAtIndex(termIDIndex: termIDIndex)
				delegate?.shouldUpdateDisplay()
			}

		}
		
	}
	
	@objc func assignCategoryN (notification : Notification) {
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				updateDataAndDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		
		print("fcVCH got unassignCategoryN")
		
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				updateDataAndDisplay()
			}
		}
	}
	
	@objc func deleteCategoryN (notification: Notification){
		// if the current category is deleted, then change the current category to 1 (All Terms) and reload the data
		if let data = notification.userInfo as? [String: Int] {
			
			let deletedCategoryID = data["categoryID"]
			if deletedCategoryID == currentCategoryID {
				currentCategoryID = myConstants.dbCategoryAllTermsID
				updateDataAndDisplay()
			}
		}
	}
	
	@objc func changeCategoryNameN (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.shouldUpdateDisplay()
			}
		}
		
	}
	
	// MARK: - update data functions
	
	/**
	Will update just the termIDs array
	*/
	func updateData () {
		
		termIDs = tc.getTermIDs(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: learnedStatus, orderByName: true)
	}
	
	/**
	Will update the termIDs array and will reload the collection view and display
	*/
	func updateDataAndDisplay () {
		updateData()
		delegate?.shouldRefreshCollectionView()
		delegate?.shouldUpdateDisplay()
	}
	
	func getFcLearnedCount () -> Int {
		
		return tc.getCount(categoryID: currentCategoryID, isFavorite: showFavoritesOnly ? true : .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: true)
	}
	
	func getFcLearningCount () -> Int {
		return tc.getCount(categoryID: currentCategoryID, isFavorite: showFavoritesOnly ? true : .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: false)
		
	}
	
	func relearnFlashcards () {
		tc.resetLearnedFlashcards(categoryID: currentCategoryID)
		updateDataAndDisplay()
	}
	
	// MARK: - count functions
	func getFavoriteTermsCount () -> Int {
		//return the count of favorites or this catetory
		return tc.getCount(categoryID: currentCategoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
	}
	
	func getAllTermsCount () -> Int {
		return tc.getCount(categoryID: currentCategoryID, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
	}
	
	// MARK: - CollectionViewDataSource Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		// if no termIDs are availabe, return one for showing the noFlashcardCell
		
		termIDs.count == 0 ? 1 : termIDs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if termIDs.count == 0 {
			print("termIDs count = 0, sending back NoFlashCardCell")
			let noFC = collectionView.dequeueReusableCell(withReuseIdentifier: "noFlashcardCell", for: indexPath) as! NoFlashCardCell
			configureNoFlashCardCell(cell: noFC)
			
			return noFC
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flashCardCell", for: indexPath) as! FlashcardCell
		
		// prepare the cell to configure
		let term = tc.getTerm(termID: termIDs[indexPath.row])
		let countText = "Flashcard: \(indexPath.row + 1) of \(termIDs.count)"
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: term.termID)
		
		let fcls = tc.getLearnedFlashcard(categoryID: currentCategoryID, termID: term.termID)
		
		cell.configure(term: term, fcvMode: viewMode, isFavorite: isFavorite, learnedFlashcard: fcls , counter: countText)
		
		cell.delegate = self
		
		return cell
	}
	
	func configureNoFlashCardCell (cell: NoFlashCardCell) {
		
		// if no terms available in this category
		
		let termCount = cc.getCountOfTerms(categoryID: currentCategoryID)
		
		if termCount == 0 {
			cell.headingLabel.text = "No Terms To Show."
			cell.subheadingLabel.text = "There are no terms in this category. When you add terms to this category, they will show here."
			cell.redoButton.isHidden = true
			cell.headerIcon.image = myTheme.imageInfo!
			return
		}
		
		// if showFavoritesOnly == true and there are no favorites in this category
		
		let favoriteCount = tc.getCount(categoryID: currentCategoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
		
		if showFavoritesOnly && favoriteCount == 0 {
			
			cell.headingLabel.text = "No Favorite Terms To Show."
			cell.subheadingLabel.text = "There are no favorite terms in this category. When you choose some terms to be favorites, they will show here."
			cell.redoButton.isHidden = true
			cell.headerIcon.image = myTheme.imageInfo!
			return
		}
		
		switch learnedStatus {
		
		case false:
			// learnING tab
			if showFavoritesOnly {
				// show favorites only, you learned all favorite terms
				cell.headingLabel.text = "You learned all favorite terms in this category!"
				cell.subheadingLabel.text = "You can relearn all the terms again by pressing the redo button."
				cell.redoButton.isHidden = false
				cell.headerIcon.image = myTheme.imageDone!
				return
				
			} else {
				// show all, learned all terms
				cell.headingLabel.text = "You learned all terms in this category!"
				cell.subheadingLabel.text = "You can relearn all the terms again by pressing the redo button."
				cell.redoButton.isHidden = false
				cell.headerIcon.image = myTheme.imageDone!
				return
				
			}
		case true:
			// learnED tab
			if showFavoritesOnly {
				// show favorites only, you have not learned any favorite terms yet
				cell.headingLabel.text = "You have not learned any favorite terms in this category yet."
				cell.subheadingLabel.text = "When you learn some favoite terms, they will show here."
				cell.redoButton.isHidden = true
				cell.headerIcon.image = myTheme.imageInfo!
				return
				
			} else {
				// show all, no have not learned any terms yet
				cell.headingLabel.text = "You have not learned any terms in this category yet."
				cell.subheadingLabel.text = "When you learn some terms, they will show here."
				cell.redoButton.isHidden = true
				cell.headerIcon.image = myTheme.imageInfo!
				return
			}
		}
	}
	
	
	// MARK: - Cell delegate protocol
	
	func pressedFavoriteButton(termID: Int) {
		// when the user clicks the heart button, it toggles locally, but need to change the value in the database
		
		let _ = tc.toggleFavoriteStatusPN(categoryID: currentCategoryID, termID: termID)
		
		// Note the TermController will broadcast the itemInformationChanged notification when the favorite setting is changed so that all the components of this program can react.
		// The VCH will listen for that and tell the home view to refresh it's current cell. This is redundant for this case where the user changed the value of the term favorite status on the flash card itself. However, it will be relavent to react to when the user changes this term's favorite status on an other part of the program.
		
	}
	
	func pressedGotItButton(termID: Int) {
		// the got it button changes state locally, so just need to update the db here
		let fcls = !tc.getLearnedFlashcard(categoryID: currentCategoryID, termID: termID)
		
		tc.setLearnedFlashcard(categoryID: currentCategoryID, termID: termID, learnedStatus: fcls)
		
		updateData()
		delegate?.shouldUpdateDisplay()
	}
	
	// MARK: - Scroll delegate protocol
	
	func CVCellChanged(cellIndex: Int) {
		delegate?.shouldUpdateDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		// here to meet the delegate requirement, but will not be using this function here
	}
	
	// MARK: -Flashcard options delegate
	func flashCardViewModeChanged(fcvMode: FlashcardViewMode) {
		self.viewMode = fcvMode
		delegate?.shouldRefreshCurrentCell()
	}
	
}
