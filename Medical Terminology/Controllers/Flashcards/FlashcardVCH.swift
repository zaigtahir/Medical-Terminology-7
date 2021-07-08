//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FlashcardVCHDelegate: AnyObject {
	func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	func shouldRefreshCollectionView()	// reload all the data
	func shouldRefreshCurrentCell()
	func shouldReloadCellAtIndex (termIDIndex: Int)
	func shouldRemoveCellAt(indexPath: IndexPath)
	func shouldRemoveCurrentCell()
}

class FlashcardVCH: NSObject, UICollectionViewDataSource, FlashcardCellDelegate, FlashcardOptionsDelegate,  ScrollControllerDelegate {
	
	// term based variables
	var currentCategoryIDs = [1]
	
	// TO REMOVE
	var currentCategoryID = 1
	
	var showFavoritesOnly = false
	
	// HAVE to figure out notifications for events
	
	var viewMode : TermComponent = .both
	
	// which tab to show: learning vs learned
	var learnedStatus = false
	
	weak var delegate: FlashcardVCHDelegate?
	
	// controllers
	let fc = FlashcardController()
	let tcTB = TermControllerTB()
	let cc = CategoryController()
	let utilities = Utilities()
	
	var termIDs = [Int]()	// list to show
	
	override init() {
		super.init()
		
		
		// MARK: - Category notifications
		
		let nameCCCNK = Notification.Name(myKeys.currentCategoryIDsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryIDsChangedN(notification:)), name: nameCCCNK, object: nil)
		
		// This is sent only if there is this ONE category in currentCategoryIDs, and the name is changed
		let nameCCN = Notification.Name(myKeys.categoryNameChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameChangedN(notification:)), name: nameCCN, object: nil)
		
		// MARK: - Term notifications
		let nameTAN = Notification.Name(myKeys.termAddedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termAddedN(notification:)), name: nameTAN, object: nil)
	
		let nameTDN = Notification.Name(myKeys.termDeletedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termDeletedN(notification:)), name: nameTDN, object: nil)
		
		let nameTNC = Notification.Name(myKeys.termFieldsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termFieldsChangedN (notification:)), name: nameTNC, object: nil)
		
		let nameCIC = Notification.Name(myKeys.termCategoryIDsChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(termCategoryIDsChangedN (notification:)), name: nameCIC, object: nil)
		
		// update data
		updateData()
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Category notification functions

	@objc func currentCategoryIDsChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			//there will be only one data here, the categoryIDs
			currentCategoryIDs = data["categoryIDs"]!
			updateData()
			delegate?.shouldRefreshCollectionView()
			delegate?.shouldUpdateDisplay()
			
		}
	}

	@objc func categoryNameChangedN (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		delegate?.shouldUpdateDisplay()
	}
	
	// MARK: - Term notification functions
	
	@objc func termAddedN  (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			let affectedCategoryIDs = tcTB.getTermCategoryIDs(termID: affectedTermID)
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: affectedCategoryIDs) {
				updateData()
				delegate?.shouldRefreshCollectionView()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termDeletedN  (notification: Notification) {
		// self, userInfo: ["assignedCategoryIDs" : assignedCategoryIDs])
		
		if let data = notification.userInfo as? [String: [Int]] {
			//let assignedCategoryIDs = data["assignedCategoryIDs"] as [Int]
			
			let assignedCategoryIDs = data["assignedCategoryIDs"]!
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: assignedCategoryIDs) {
				updateData()
				delegate?.shouldRefreshCollectionView()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termFieldsChangedN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			let affectedCategoryIDs = tcTB.getTermCategoryIDs(termID: affectedTermID)
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: affectedCategoryIDs) {
				updateData()
				delegate?.shouldRefreshCollectionView()
				delegate?.shouldUpdateDisplay()
			}
		}
	}
	
	@objc func termCategoryIDsChangedN (notification: Notification) {
		//userInfo: ["termID": [term.termID], "originalCategoryIDs" : [originalTerm.assignedCategories]])
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			let termID = data["termID"]![0]
			let originalCategoryIDs = data["originalCategoryIDs"]!
			let newCategoryIDs = tcTB.getTermCategoryIDs(termID: termID)
			
			// if current categories contain any of these categories, need to refresh data and display
			// this will catch any additions or removals of a term category
			
			if utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: originalCategoryIDs) || utilities.containsElementFrom(mainArray: currentCategoryIDs, testArray: newCategoryIDs) {
				// the current category IDs contain at least one of the category IDs from the originalCategoryIDs or currentCategoryIDs
				
				updateData()
				delegate?.shouldRefreshCollectionView()
				delegate?.shouldUpdateDisplay()
			}
		}
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	// MARK: - update data functions
	
	func updateData () {
	
		termIDs = fc.getFlashcardTermIDs(categoryIDs: currentCategoryIDs, showFavoritesOnly: showFavoritesOnly, learnedStatus: learnedStatus)
	}
	
	func relearnFlashcards () {
		fc.resetLearnedFlashcards(categoryIDs: currentCategoryIDs)
		updateData()
		delegate?.shouldRefreshCollectionView()
		delegate?.shouldUpdateDisplay()
	}

	
	// MARK: - CollectionViewDataSource Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		// if no termIDs are availabe, return one for showing the noFlashcardCell
		
		termIDs.count == 0 ? 1 : termIDs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if termIDs.count == 0 {
			
			let noFC = collectionView.dequeueReusableCell(withReuseIdentifier: "noFlashcardCell", for: indexPath) as! NoFlashCardCell
			configureNoFlashCardCell(cell: noFC)
			
			return noFC
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flashCardCell", for: indexPath) as! FlashcardCell
		
		// prepare the cell to configure
	
		let term = tcTB.getTerm(termID: termIDs[indexPath.row])
		let countText = "Flashcard: \(indexPath.row + 1) of \(termIDs.count)"
		let isFavorite = tcTB.getFavoriteStatus(termID: term.termID )
		
		let fcls = fc.flashcardIsLearned(termID: term.termID)
		
		cell.configure(term: term, fcvMode: viewMode, isFavorite: isFavorite, learnedFlashcard: fcls , counter: countText)
		
		cell.delegate = self
		
		return cell
	}
	
	func configureNoFlashCardCell (cell: NoFlashCardCell) {
		
		// if no terms available in this category
		
		let termCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: showFavoritesOnly)
		
		if termCount == 0 {
			cell.headingLabel.text = myConstants.noTermsHeading
			cell.subheadingLabel.text = myConstants.noTermsSubheading
			cell.redoButton.isHidden = true
			cell.headerIcon.image = myTheme.imageInfo!
			return
		}
		
		// if favoritesOnly == true and there are no favorites in this category
		
		let favoriteCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: true)
		
		if showFavoritesOnly && favoriteCount == 0 {
			cell.headingLabel.text = myConstants.noFavoriteTermsHeading
			cell.subheadingLabel.text = myConstants.noFavoriteTermsSubheading
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
				cell.headingLabel.text = "You are done!"
				cell.subheadingLabel.text = "You learned all the terms in this cateogory."
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
	
		let _ = tcTB.toggleFavoriteStatusPN(termID: termID)
		
		// Note the TermController will broadcast the itemInformationChanged notification when the favorite setting is changed so that all the components of this program can react.
		// The VCH will listen for that and tell the home view to refresh it's current cell. This is redundant for this case where the user changed the value of the term favorite status on the flash card itself. However, it will be relavent to react to when the user changes this term's favorite status on an other part of the program.
		
	}
	
	func pressedGotItButton(termID: Int) {
		// the got it button changes state locally, so just need to update the db here
		let fcls = !fc.flashcardIsLearned(termID: termID)
		
		fc.setLearnedFlashcard(termID: termID, learnedStatus: fcls)
		
		updateData()
		delegate?.shouldRemoveCurrentCell()
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
	func flashCardViewModeChanged(fcvMode: TermComponent) {
		self.viewMode = fcvMode
		delegate?.shouldRefreshCurrentCell()
	}
	
}
