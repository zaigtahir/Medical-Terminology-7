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
		
		// add observers
		let name1 = Notification.Name(myKeys.categoryChanged)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryChanged(notification:)), name: name1, object: nil)
		
		let name2 = Notification.Name(myKeys.termInformationChanged)
		NotificationCenter.default.addObserver(self, selector: #selector(termInformationChanged(notification:)), name: name2, object: nil)
	
		updateData(categoryID: currentCategoryID)
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func termInformationChanged (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"] ?? 0
			
			if termIDs.contains(affectedTermID) {
				delegate?.refreshCollectionView()
				delegate?.updateHomeDisplay()	// to update favorite counts
			}
		}
	}
	
	@objc func categoryChanged (notification : Notification) {
		
		if let data = notification.userInfo as? [String : Int] {
			for d in data {
				//there will be only one data here, the categoryID
				print("flashcardVCH got notification of category change")
				updateData(categoryID: d.value)
			}
		}
	}
	
	func updateData (categoryID : Int?) {
		
		if let newID = categoryID {
			currentCategoryID = newID
		}
		
		termIDs = tc.getTermIDs(categoryID: currentCategoryID, showOnlyFavorites: showFavoritesOnly, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
		
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
	
	func userPressedFavoriteButton(termID: Int) {
		print("in vch userPressedFavoriteButton")
		
		let favoriteStatus = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		tc.setFavoriteStatus(categoryID: currentCategoryID, termID: termID, isFavorite: !favoriteStatus)
		
		//note the TermController will broadcast the itemInformationChanged notification when the favorite setting is changed. The VCH will listen for that and tell the home view to refresh it's current cell
		
	}
	
	// MARK: - Scroll delegate protocol
	
	func CVCellChanged(cellIndex: Int) {
		delegate?.updateHomeDisplay()
	}
	
	func CVCellDragging(cellIndex: Int) {
		// here to meet the delegate requirement, but will not be using this function here
	}
	
	// MARK: Flashcard options delegate
	func flashCardViewModeChanged(fcvMode: FlashcardViewMode) {
		self.viewMode = fcvMode
		delegate?.refreshCurrentCell()
	}
	
}
