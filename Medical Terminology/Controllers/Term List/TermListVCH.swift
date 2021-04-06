//
//  ListTC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/7/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


/*

When a term is added, changed, deleted the view will keep it's search text active and refresh the screen based on the search text. So there is a chance you could add a term but it won't show on the screen due to the content of the search box

*/
import UIKit

protocol TermListVCHDelegate: class {
	//func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	//func reloadTableView()	// reload all the data
	
	func shouldReloadTable()
	func shouldUpdateDisplay()
	func shouldReloadCellAt (indexPath: IndexPath)
	func shouldClearSearchText()
}


class TermListVCH: NSObject, UITableViewDataSource, ListCellDelegate

{
	
	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	
	var searchText : String?			// use for searching. Update this when the user enters text in the search bar
	
	var termsList = TermsList()
	
	let tc = TermController()
	
	let tu = TextUtilities()
	
	weak var delegate: TermListVCHDelegate?
	
	override init() {
		super.init()
		
		updateData ()
		
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
			currentCategoryID = data ["categoryID"]!
			updateDataAndDisplay()
		}
	}
	
	@objc func setFavoriteStatusN (notification: Notification) {
		
		print("got setFavoriteStatusN in TermListVCH")
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			// if this term id exists in termIDs, need to reload that term from the database and then reload just that term cell in the table
			
			if let _ = termsList.findIndexOf(termID: affectedTermID) {
				
				// updating just the row causes some misalignment issues unless I use an animation of .fade, but then the row has a slight faid flicker animation which I don't want
				// don't have to reload the data, as the termsList will only contain termIDs. When the cell refreshes, it will get the new term information from the database
				
				delegate?.shouldReloadTable()
				delegate?.shouldUpdateDisplay()
			}
		}
		
	}
	
	@objc func assignCategoryN (notification : Notification) {
		print("got assignCategoryN in termListVCH")
		if let data = notification.userInfo as? [String : Int] {
			let categoryID = data["categoryID"]!
			if categoryID == currentCategoryID {
				
				updateDataAndDisplay()
			}
		}
	}
	
	@objc func unassignCategoryN (notification : Notification){
		
		print ("termListVCH got unassignedCategoryN")
		if let data = notification.userInfo as? [String : Int] {
			
			let categoryID = data["categoryID"]!
			
			if categoryID == currentCategoryID {
				
				updateDataAndDisplay()
			}
		}
		
	}
	
	@objc func deleteCategoryN (notification: Notification){
		
		print("termListVCH got deleteCategoryN")
		
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
		print("termListVCH got changeCategoryN")
		// if this is the current category, reload the category and then refresh the display
		
		if let data = notification.userInfo as? [String : Int] {
			let changedCategoryID = data["categoryID"]
			if changedCategoryID == currentCategoryID {
				delegate?.shouldUpdateDisplay()
			}
		}
		
	}
	
	// MARK: - Update data function
	
	/**
	Will update the internal termsList
	*/
	func updateData () {
		
		// MARK: add code to remove more than 1 space also?
		
		// Clean up the search text
		if let nonCleanText = searchText {
			
			let cleanText = tu.removeLeadingTrailingSpaces(string: nonCleanText)
			
			self.termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, containsText: cleanText)
			
		} else {
			termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, containsText: .none)
		}
		
	}
	
	/**
	Will update the internal termsList and also use the delegate functions to update the home tableView and display
	*/
	func updateDataAndDisplay () {
		
		updateData()
		
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
