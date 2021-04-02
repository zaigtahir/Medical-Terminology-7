//
//  ListTC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/7/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

//Have to incude NSObject to that TermListVCH can implement the table view and search bar delegates
class TermListVCH: NSObject, UITableViewDataSource, UISearchBarDelegate

{

	var currentCategoryID = 1 			// default starting off category
	var showFavoritesOnly = false		// this is different than saying isFavorite = false
	var termsList =
	var searchText : String? = nil
	
	let tc = TermController()
	
	override init() {
		super.init()
		makeTermsList()
	}
	
	func makeTermsList () {
		termsList.makeList(categoryID: currentCategoryID, showFavoritesOnly: showFavoritesOnly, nameContains: searchText)
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return termsList.getRowCount(section: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let termID = termsList.getTermID(indexPath: indexPath)
		let term = tc.getTerm(termID: termID)
		
		cell.textLabel!.text = term.name
		
		return cell
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
private var alphaList = AlphaList()
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

//search bar delegate functions
func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
if searchBar.showsCancelButton == false {
searchBar.showsCancelButton = true
}
makeList(favoritesOnly: favoritesOnly, searchText: searchText)
}

func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
// Stop doing the search stuff
// and clear the text in the search bar
searchBar.text = ""
searchText = ""
// Hide the cancel button
searchBar.showsCancelButton = false
// You could also change the position, frame etc of the searchBar
searchBar.endEditing(true)

makeList(favoritesOnly: favoritesOnly, searchText: searchText)
}

}


*/
