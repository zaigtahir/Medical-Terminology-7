//
//  ListTC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/7/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

//Have to incude NSObject to that TermListVCH can implement the table view and search bar delegates
class TermListVCH: NSObject, UITableViewDataSource, ListCellDelegate

{

	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var termsList = TermsList()
	
	let tc = TermController()
	
	override init() {
		super.init()
		updateTermsList(searchText: "")
		
		// MARK: - Observers for category notification events
		
		let observer1 = Notification.Name(myKeys.newCategorySelectedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryChangedNotification(notification:)), name: observer1, object: nil)
		
		let observer5 = Notification.Name(myKeys.categoryDeletedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryDeletedNotification(notification:)), name: observer5, object: nil)
		
		let observer6 = Notification.Name(myKeys.categoryNameUpdatedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameUpdatedNotification(notification:)), name: observer6, object: nil)
		
		// MARK: - Observers for term notification events
		
		let observer2 = Notification.Name(myKeys.termInformationChangedNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(termInformationChangedNotification(notification:)), name: observer2, object: nil)
		
		let observer3 = Notification.Name(myKeys.termAssignedCategoryNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryAssignedNotfication(notification:)), name: observer3, object: nil)
		
		let observer4 = Notification.Name(myKeys.termUnassignedCategoryNotification)
		NotificationCenter.default.addObserver(self, selector: #selector(unassignedCategoryNotfication(notification:)), name: observer4, object: nil)
		
		
	}
	
	func updateTermsList (searchText: String) {
		
		var contains : String?
		if searchText != "" {
			contains = searchText
		}
		
		self.termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, containsText: contains)
		
	}
	
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
		
		termCell!.configure(term: term, indexPath: indexPath)
		
		return termCell!
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
	
	@objc func categoryChangedNotification (notification : Notification) {
		
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
	
	// MARK: - ListCellDelegate functions
	
	func pressedFavoriteButton(termID: Int) {
		
		let isFavorite = tc.getFavoriteStatus(categoryID: currentCategoryID, termID: termID)
		
		tc.setFavoriteStatusPostNotification(categoryID: currentCategoryID, termID: termID, isFavorite: !isFavorite)
		
		// handle this notification to refresh the screen/cell
	}
}


/*\
protocol ListTCDelagate: class {
func favoriteItemChanged()  //when the user changes the state of a favorite item
func tableDataChanged()     //when the table data is changed and the TermListVC needs to refresh the table
}

//Have to incude NSObject to that TermListVCH can implement the table view and search bar delegates
class TermListVCH: NSObject, UITableViewDataSource, UITableViewDelegate, ListCellDelegate, UISearchBarDelegate
{

private var searchText = ""
private var favoritesOnly = false
private var alphaList = TermsList()
private var dIC = DItemController()
private var searchList = [DItem]()
private let searchLists = SearchLists()
weak var delegate: ListTCDelagate?

override init() {
//Initialize the alphalist to show all
super.init()
makeList(favoritesOnly: favoritesOnly, searchText: searchText)
}

func numberOfSections(in tableView: UITableView) -> Int {


if showAlphaList() {
return alphaList.sections.count
} else {
return 1
}

}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
if showAlphaList() {
return alphaList.listItems[section].count
} else {
return searchList.count
}

}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//use a default cell with subtitle setting in the story board
let cell = tableView.dequeueReusableCell(withIdentifier: "listCell") as! TermCell
//get the dItem for which ever list is set

var dItem: DItem

if showAlphaList() {
dItem = alphaList.getDItemFromList(indexPath: indexPath)
} else {
dItem = searchList[indexPath.row]
}

cell.configure(dItem: dItem, indexPath: indexPath)
cell.delegate = self   //assigning self for deligate

return cell
}

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//assign section title(s)

if isFavoritesOnly() {

if isSearching() {
return "Searching Favorites"

}else {
return "Favorites List"
}

} else {

if isSearching() {
return "Searching"
}else {
return alphaList.sections[section]
}
}

}

func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){

/*

view.tintColor = myTheme.color_section_header
let header = view as! UITableViewHeaderFooterView
header.textLabel?.textColor = myTheme.color_section_text
*/
}

func sectionIndexTitles(for tableView: UITableView) -> [String]? {

if showAlphaList() {
return alphaList.sections
} else {
return nil
}

}

//TermCell delegate function
func pressedFavoriteButton(dItem: DItem) {
dItem.isFavorite = !dItem.isFavorite
dIC.saveFavorite(itemID: dItem.itemID, isFavorite: dItem.isFavorite)

//need to notify the TermListVC that favorites count is changed
delegate?.favoriteItemChanged()
}

// other functions for this class
func makeList (favoritesOnly: Bool, searchText: String) {

self.searchText = searchText
self.favoritesOnly = favoritesOnly

if showAlphaList() {
alphaList = searchLists.makeAlphaList(favoritesOnly: favoritesOnly)

} else {
searchList = searchLists.makeSearchList(favoritesOnly: favoritesOnly, searchText: searchText)
}

delegate?.tableDataChanged()

}

private func showAlphaList () -> Bool {
if favoritesOnly == false && searchText == "" {
return true
} else {
return false
}
}

func isSearching () -> Bool {

if searchText == "" {
return false
} else {
return true
}
}

func isFavoritesOnly () -> Bool {
return self.favoritesOnly
}


}


*/
