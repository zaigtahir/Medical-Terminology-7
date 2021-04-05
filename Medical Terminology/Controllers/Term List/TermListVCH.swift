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
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Update data function
	func updateData (categoryID: Int, searchText: String) {
		
		currentCategoryID = categoryID
		
		var contains : String?
		if searchText != "" {
			contains = searchText
		}
		
		self.termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, containsText: contains)
		
		print("in termListVCH updateData")
		delegate?.shouldClearSearchText()
		delegate?.shouldReloadTable()
		delegate?.shouldUpdateDisplay()
		
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
