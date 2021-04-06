//
//  ListTC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/7/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol TermListVCHDelegate: class {
	//func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	//func reloadTableView()	// reload all the data
	
	func shouldReloadTable()
	func shouldUpdateDisplay()
	func reloadCellAt (indexPath: IndexPath)
	func shouldClearSearchText()
}


class TermListVCH: NSObject, UITableViewDataSource, ListCellDelegate

{
	
	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	
	var termsList = TermsList()
	
	let tc = TermController()
	
	weak var delegate: TermListVCHDelegate?
	
	override init() {
		super.init()
		
		updateData (categoryID: currentCategoryID, searchText: "")
		
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
		NotificationCenter.default.addObserver(self, selector: #selector(deleteCategoryN(notification:)), name: nameCCN, object: nil)

		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	
	@objc func currentCategoryChangedN (notification : Notification) {
		
		
		if let data = notification.userInfo as? [String : Int] {
			
			// clear any search text
			delegate?.shouldClearSearchText()
			
			//there will be only one data here, the categoryID
			updateDataAndDisplay(categoryID: data["categoryID"]!, searchText: "")
		}
	}
	
	@objc func setFavoriteStatusN (notification: Notification) {
		
		/*
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			// if this term id exists in termIDs, need to reload that term from the database and then reload just that term in the collection
			if let termIDIndex = termIDs.firstIndex(of: affectedTermID) {
				
				delegate?.shouldReloadCellAtIndex(termIDIndex: termIDIndex)
				delegate?.shouldUpdateDisplay()
			}
		}
		*/
	}
	
	@objc func assignCategoryN (notification : Notification) {
		/*
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				print ("flashcardVCH is refreshing the currentCategoryID because a term got assigned to it")
				updateDataAndDisplay(categoryID: categoryID)
			}
		}
		*/
	}
	
	@objc func unassignCategoryN (notification : Notification){
		/*
		if let data = notification.userInfo as? [String : Int] {
			
			let categoryID = data["categoryID"]!
			
			if categoryID == currentCategoryID {
				print ("flashcardVCH is refreshing the currentCategoryID because a term got UNassigned from it")
				updateDataAndDisplay(categoryID: categoryID)
			}
		}
		*/
	}
	
	@objc func deleteCategoryN (notification: Notification){
		
		/*
		// if the current category is deleted, then change the current category to 1 (All Terms) and reload the data
		if let data = notification.userInfo as? [String: Int] {
			
			let deletedCategoryID = data["categoryID"]
			if deletedCategoryID == currentCategoryID {
				print ("current category deleted, will switch FC to All Terms")
				updateDataAndDisplay(categoryID: myConstants.dbCategoryAllTermsID)
			}
		}
*/
}
	
	@objc func changeCategoryNameN (notification: Notification) {
		
		/*
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.shouldUpdateDisplay()
			}
		}
		*/
	}
	
	// MARK: - Update data function
	
	/**
	Will update the internal termsList
	*/
	func updateData (categoryID: Int, searchText: String) {
		
		currentCategoryID = categoryID
		
		var contains : String?
		if searchText != "" {
			contains = searchText
		}
		
		self.termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, containsText: contains)
	}
	
	/**
	Will update the internal termsList and also use the delegat functions to update the home tableView and display
	*/
	func updateDataAndDisplay (categoryID: Int, searchText: String) {
		
		updateData(categoryID: categoryID, searchText: searchText)
		
		delegate?.shouldClearSearchText()
		delegate?.shouldReloadTable()
		delegate?.shouldUpdateDisplay()
		
	}
	
	// MARK: - count functions
	func getFavoriteTermsCount () -> Int {
		//return the count of favorites or this catetory
		return tc.getCount(categoryID: currentCategoryID, isFavorite: true, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
	}
	
	func getAllTermsCount () -> Int {
		return tc.getCount(categoryID: currentCategoryID, isFavorite: .none, answeredTerm: .none, answeredDefinition: .none, learned: .none, learnedTerm: .none, learnedDefinition: .none, learnedFlashcard: .none)
	}
	
	// MARK: - Table functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if termsList.getCount() == 0 {
			return 1
		} else {
			return 26
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if termsList.getCount() == 0 {
			return 1
		} else {
			return termsList.getRowCount(section: section)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if termsList.getCount() == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "noTermsCell", for: indexPath) as? NoTermsCell
			
			return cell!
		}
		
		
		let termCell = tableView.dequeueReusableCell(withIdentifier: "termCell", for: indexPath) as? TermCell
		
		let termID = termsList.getTermID(indexPath: indexPath)
		let term = tc.getTerm(termID: termID)
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		
		termCell!.configure(term: term, isFavorite: isFavorite, indexPath: indexPath)
		termCell?.delegate = self
		
		return termCell!
	}
	
	
	
	// MARK: - ListCellDelegate functions
	
	func pressedFavoriteButton(termID: Int) {
		
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		
		tc.setFavoriteStatusPN(categoryID: currentCategoryID, termID: termID, isFavorite: !isFavorite)
		
		// after the save method broadcasts the notification, this VCH will instruct the homeVC to update it's cell
	}
}


/*
// MARK: - notification functions
@objc func termInformationChangedNotification (notification: Notification) {
// will need to update just that cell of the table view


}

@objc func currentCategoryChangedN (notification : Notification) {
if let data = notification.userInfo as? [String : Int] {
for d in data {

print("in TermListVCH currentCategoryChangedNotification")

let categoryID = d.value
updateData(categoryID: categoryID, searchText: "")
}
}
}

@objc func categoryAssignedNotfication (notification : Notification) {
}

@objc func unassignedCategoryNotfication (notification : Notification){
}

@objc func categoryDeletedN (notification: Notification){
}

@objc func categoryNameUpdatedNotification (notification: Notification) {
}
*/




/*
// MARK: - Observers for category notification events

let observer1 = Notification.Name(myKeys.currentCategoryChangedKey)
NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryChangedN(notification:)), name: observer1, object: nil)

let observer5 = Notification.Name(myKeys.deleteCategoryKey)
NotificationCenter.default.addObserver(self, selector: #selector(categoryDeletedN(notification:)), name: observer5, object: nil)

let observer6 = Notification.Name(myKeys.changeCategoryNameKey)
NotificationCenter.default.addObserver(self, selector: #selector(categoryNameChangedN(notification:)(notification:)), name: observer6, object: nil)

// MARK: - Observers for term notification events

let observer2 = Notification.Name(myKeys.termFavoriteStatusChangedKey)
NotificationCenter.default.addObserver(self, selector: #selector(termInformationChangedNotification(notification:)), name: observer2, object: nil)

let observer3 = Notification.Name(myKeys.assignCategoryKey)
NotificationCenter.default.addObserver(self, selector: #selector(categoryAssignedNotfication(notification:)), name: observer3, object: nil)

let observer4 = Notification.Name(myKeys.unassignCategoryKey)
NotificationCenter.default.addObserver(self, selector: #selector(categoryUnassignedNotification(notification:)), name: observer4, object: nil)
*/
