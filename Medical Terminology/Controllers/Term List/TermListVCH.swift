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

protocol TermListVCHDelegate: AnyObject {
	//func shouldUpdateDisplay()		// update state of other controls on the flashcard home screen
	//func reloadTableView()	// reload all the data
	
	func shouldReloadTable()
	func shouldUpdateDisplay()
	func shouldReloadRowAt (indexPath: IndexPath)
	func shouldRemoveRowAt (indexPath: IndexPath)
	func shouldClearSearchText()
	func shouldSegueToTermVC()
}


class TermListVCH: NSObject, UITableViewDataSource, UITableViewDelegate, ListCellDelegate

{
	
	// term based variables
	var currentCategoryIDs = [1]
	
	// TO REMOVE
	var currentCategoryID = 1
	
	var showFavoritesOnly = false
	
	
	var searchText : String?
	
	var termsList = TermsList()
	
	/// initialize with the termID when the user clicks a row so that termListVC can access it for performing the seque
	var termIDForSegue : Int!
	
	// set this value when the user clicks a row to view a current term or when clicks the add term button. Use this value to determine the display mode of the TermVC when it is displayed to view or add a term
	var termEditMode = TermEditMode.view
	
	weak var delegate: TermListVCHDelegate?
	
	let tcTB = TermControllerTB()
	
	let cc = CategoryController()
	
	let tu = TextUtilities()
	
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
		
		
		// MARK: term based categorIES changed
		
		let nameCCCNK = Notification.Name(myKeys.currentCategoryIDsChanged)
		NotificationCenter.default.addObserver(self, selector: #selector(currentCategoryIDsChangedN(notification:)), name: nameCCCNK, object: nil)
		
		
		
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	
	
	// CATEGORIES changed
	@objc func currentCategoriesChangedN (notification : Notification) {
		
		if let data = notification.userInfo as? [String : [Int]] {
			
			//there will be only one data here, the categoryID
			currentCategoryIDs = data["categoryIDs"]!
			updateDataAndDisplay()
			
		}
	}
		
	// updated for CATEGORIES
	@objc func setFavoriteStatusN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			// if this term id exists in termIDs, need to reload that term from the database and then reload just that term cell in the table
			
			switch showFavoritesOnly {
			
			case true:
				// showing favorites only
				
				
				let affectedTerm = tcTB.getTerm(termID: affectedTermID)

				switch affectedTerm.isFavorite {
				
				case true:
					// term is made favorite from elsewhere in the program, need to reload all data and update the display
					updateData()
					delegate?.shouldReloadTable()
					delegate?.shouldUpdateDisplay()
					
				case false:
					// term was made unfavorite, need to remove just that data from the model, and animate the removal of the cell in the table
					if let indexPath = termsList.findIndexOf(termID: affectedTermID) {
						
						termsList.removeIndex(indexPath: indexPath)
						delegate?.shouldRemoveRowAt(indexPath: indexPath)
						delegate?.shouldUpdateDisplay()
					}
				}
				
			case false:
				
				if let _ = termsList.findIndexOf(termID: affectedTermID) {
					// updating just the row causes some misalignment issues unless I use an animation of .fade, but then the row has a slight faid flicker animation which I don't want
					// don't have to reload the data, as the termsList will only contain termIDs. When the cell refreshes, it will get the new term information from the database
					
					delegate?.shouldReloadTable()
					delegate?.shouldUpdateDisplay()
				}
			}
			
		}
		
	}
	
	
	
	
	
	
	@objc func termInformationChangedN (notification: Notification) {
		
		if let data = notification.userInfo as? [String: Int] {
			let affectedTermID = data["termID"]!
			
			if let _ = termsList.findIndexOf(termID: affectedTermID) {
				// updating just the row causes some misalignment issues unless I use an animation of .fade, but then the row has a slight faid flicker animation which I don't want
				// don't have to reload the data, as the termsList will only contain termIDs. When the cell refreshes, it will get the new term information from the database
				
				delegate?.shouldReloadTable()
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
				
				delegate?.shouldClearSearchText()
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
	
	// MARK: - Update data function
	
	/**
	Will update the internal termsList
	*/
	func updateData () {
		
		// MARK: add code to remove more than 1 space also?
		// Clean up the search text
		if let nonCleanText = searchText {
			
			let cleanText = tu.removeLeadingTrailingSpaces(string: nonCleanText)
			
			self.termsList.makeList(categoryIDs: currentCategoryIDs, showFavoritesOnly: showFavoritesOnly, containsText: cleanText)
			
			
		} else {
			
			self.termsList.makeList(categoryIDs: currentCategoryIDs, showFavoritesOnly: showFavoritesOnly, containsText: .none)
		}
		
		
		
	}
	
	/**
	Will update the internal termsList and also use the delegate functions to update the home tableView and display
	*/
	func updateDataAndDisplay () {
		
		updateData()
		delegate?.shouldReloadTable()
		delegate?.shouldUpdateDisplay()
		
	}
	
	// MARK: - count functions
	func getFavoriteTermsCount () -> Int {
		//return the count of favorites or this catetory
		return tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: true)
	}
	
	func getAllTermsCount () -> Int {
		return tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: false)
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
			configureNoTermCell(cell: cell!)
			
			return cell!
		}
		
		
		let termCell = tableView.dequeueReusableCell(withIdentifier: "termCell", for: indexPath) as? TermCell
		
		let termID = termsList.getTermID(indexPath: indexPath)
		let term = tcTB.getTerm(termID: termID)
		
		termCell!.configure(term: term, indexPath: indexPath)
		termCell?.delegate = self
		
		return termCell!
	}
	
	private func configureNoTermCell (cell: NoTermsCell) {
		// if no terms available in this category
		
		let termCount = cc.getCountOfTerms(categoryID: currentCategoryID)
		
		if termCount == 0 {
			cell.headingLabel.text = myConstants.noTermsHeading
			cell.subheadingLabel.text = myConstants.noTermsSubheading
			return
		}
		
		// if favoritesOnly == true and there are no favorites in this category
		
		let favoriteCount = tcTB.getTermCount(categoryIDs: currentCategoryIDs, showFavoritesOnly: true)
		
		if showFavoritesOnly && favoriteCount == 0 {
			cell.headingLabel.text = myConstants.noFavoriteTermsHeading
			cell.subheadingLabel.text = myConstants.noFavoriteTermsSubheading
			return
		}
		
		// if here the search text is leading to no matches
		
		cell.headingLabel.text = "No Matching Terms."
		cell.subheadingLabel.text = "There are no terms that match your search."
		
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// will need to determine the termID then tell the termListVC to perform the seque to the termVC
		let termID = termsList.getTermID(indexPath: indexPath)
		self.termIDForSegue = termID
		delegate?.shouldSegueToTermVC()
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if termsList.getRowCount(section: section) > 0 {
			return termsList.getSectionName(section: section)
		} else {
			return nil
		}
	}
	
	
	// MARK: - ListCellDelegate functions
	
	func pressedFavoriteButton(termID: Int) {
		
		// when the user clicks the heart button, it toggles locally, but need to change the value in the database
	
		let _ = tcTB.toggleFavoriteStatusPN(termID: termID)
		
		// Note the TermController will broadcast the itemInformationChanged notification when the favorite setting is changed so that all the components of this program can react.
		// The VCH will listen for that and tell the home view to refresh it's current cell. This is redundant for this case where the user changed the value of the term favorite status on the flash card itself. However, it will be relavent to react to when the user changes this term's favorite status on an other part of the program.
		
		
		
		
		
		
		
		/*
		
		
		
		
		
		
		
		
		
		
		
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		
		tc.setFavoriteStatusPN(categoryID: currentCategoryID, termID: termID, isFavorite: !isFavorite)
		
		// after the save method broadcasts the notification, this VCH will instruct the homeVC to update it's cell


		*/
	}
}

