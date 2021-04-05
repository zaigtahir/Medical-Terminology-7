//
//  FlashCardVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FlashcardHomeDelegate: class {
	func updateHomeDisplay()		// update state of other controls on the flashcard home screen
	func refreshCollectionView()	// reload all the data
	func refreshCurrentCell()
	func reloadCellAtIndex (termIDIndex: Int)
}

class FlashcardVCH: NSObject, UICollectionViewDataSource, FlashcardCellDelegate, FlashcardOptionsDelegate,  ScrollControllerDelegate {
	
	// holds state of the view
	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var viewMode : FlashcardViewMode = .both
	
	weak var delegate: FlashcardHomeDelegate?
	
	// controllers
	let tc = TermController()
	let cc = CategoryController2()
	
	var termIDs = [Int]()	// list to show
	
	override init() {
		super.init()
		
		// notification that do not need to be addressed
		// categoryAddedNotification
		
		// MARK: - Observers for category notification events
		
		let observer1 = Notification.Name(myKeys.currentCategoryChangedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryChanged(notification:)), name: observer1, object: nil)
		
		let observer5 = Notification.Name(myKeys.categoryDeletedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryDeletedNotification(notification:)), name: observer5, object: nil)
		
		let observer6 = Notification.Name(myKeys.categoryNameUpdatedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameUpdatedNotification(notification:)), name: observer6, object: nil)
		
		// MARK: - Observers for term notification events
		
		let observer2 = Notification.Name(myKeys.termFavoriteStatusChangedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(termInformationChangedNotification(notification:)), name: observer2, object: nil)
		
		let observer3 = Notification.Name(myKeys.assignedCategoryNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryAssignedNotfication(notification:)), name: observer3, object: nil)
		
		let observer4 = Notification.Name(myKeys.unassignedCategoryNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignedCategoryNotfication(notification:)), name: observer4, object: nil)
	
		
		updateData(categoryID: currentCategoryID)
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	@objc func termInformationChangedNotification (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"] ?? 0
			
			// if this term id exists in termIDs, need to reload that term from the database and then reload just that term in the collection
			if let termIDIndex = termIDs.firstIndex(of: affectedTermID) {
				
				delegate?.reloadCellAtIndex(termIDIndex: termIDIndex)
				delegate?.refreshCollectionView()
				delegate?.updateHomeDisplay()
				
			}
			
		}
	}
	
	@objc func currentCategoryChanged (notification : Notification) {
		
		if let data = notification.userInfo as? [String : Int] {
			for d in data {
				//there will be only one data here, the categoryID
				print("flashcardVCH got notification of category change")
				updateData(categoryID: d.value)
			}
		}
	}
	
	@objc func categoryAssignedNotfication (notification : Notification) {
		print(" flashcardVCH got a assignedCategory notification")
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]
			if categoryID == currentCategoryID {
				print ("flashcardVCH is refreshing the currentCategoryID because a term got assigned to it")
				// a term got assigned to the current category from somewhere in the program
				// will need to reload the list with the currentCategoryID and also update the home controller
				updateData(categoryID: currentCategoryID)
			}
		}
		
	}
	
	@objc func unassignedCategoryNotfication (notification : Notification){
		print ("flashcardVCH up unassignCategory notification")
		
		if let data = notification.userInfo as? [String : Int] {
			
			let categoryID = data["categoryID"]
			
			if categoryID == currentCategoryID {
				print ("flashcardVCH is refreshing the currentCategoryID because a term got UNassigned from it")
				updateData(categoryID: currentCategoryID)
			}
		}
	}
	
	@objc func categoryDeletedNotification (notification: Notification){
		// if the current category is deleted, then change the current category to 1 (All Terms) and reload the data
		if let data = notification.userInfo as? [String: Int] {
			
			let deletedCategoryID = data["categoryID"]
			if deletedCategoryID == currentCategoryID {
				print ("current category deleted, will switch FC to All Terms")
				updateData(categoryID: myConstants.dbCategoryAllTermsID)
			}
		}
	}
	
	@objc func categoryNameUpdatedNotification (notification: Notification) {
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.updateHomeDisplay()
			}
		}
		
	}
	
	func updateData (categoryID : Int?) {
		
		if let newID = categoryID {
			currentCategoryID = newID
		}
		
		termIDs = tc.getTermIDs(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none, orderByName: true)
		
		delegate?.updateHomeDisplay()
		delegate?.refreshCollectionView()
	}
	
	func getFavoriteCount () -> Int {
		//return the count of favorites or this catetory
		return tc.getCount(categoryID: currentCategoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
	}
	
	// MARK: - CollectionViewDataSource Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		termIDs.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flashCardCell", for: indexPath) as! FlashcardCell
		
		// prepare the cell to configure
		let term = tc.getTerm(termID: termIDs[indexPath.row])
		let countText = "Flashcard: \(indexPath.row + 1) of \(termIDs.count)"
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: term.termID)
		
		cell.configure(term: term, fcvMode: viewMode, isFavorite: isFavorite, counter: countText)
		
		cell.delegate = self
		
		return cell
	}
	
	// MARK: - Cell delegate protocol
	
	func pressedFavoriteButton(termID: Int) {
		// when the user clicks the heart button, it toggles locally, but need to change the value in the database
		
		print("in vch userPressedFavoriteButton")
		
		let favoriteStatus = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		tc.setFavoriteStatusAndPostNotification(categoryID: currentCategoryID, termID: termID, isFavorite: !favoriteStatus)
		
		// Note the TermController will broadcast the itemInformationChanged notification when the favorite setting is changed so that all the components of this program can react.
		// The VCH will listen for that and tell the home view to refresh it's current cell. This is redundant for this case where the user changed the value of the term favorite status on the flash card itself. However, it will be relavent to react to when the user changes this term's favorite status on an other part of the program.
		
	}
	
	// MARK: - Scroll delegate protocol
	
	func CVCellChanged(cellIndex: Int) {
		delegate?.updateHomeDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		// here to meet the delegate requirement, but will not be using this function here
	}
	
	// MARK: -Flashcard options delegate
	func flashCardViewModeChanged(fcvMode: FlashcardViewMode) {
		self.viewMode = fcvMode
		delegate?.refreshCurrentCell()
	}
	
}
