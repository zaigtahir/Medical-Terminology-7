//
//  ListViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 10/27/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit
import SQLite3

class TermListVC: UIViewController, UISearchBarDelegate, TermListVCHDelegate {
	
	//will use ListTC as the table datasource
	//use this VC to use as the table delegate as lots of actions happen based on selection including segue
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var showFavoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	
	let termListVCH = TermListVCH()
	let cc = CategoryController2()
	let tc = TermController()
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		termListVCH.delegate = self
		tableView.delegate = termListVCH
		tableView.dataSource = termListVCH
		tableView.tableFooterView = UIView()
		showFavoritesOnlyButton.isOn = termListVCH.showFavoritesOnly
		updateDisplay()
	}
	
	func updateDisplay () {
		
		let category = cc.getCategory(categoryID: termListVCH.currentCategoryID)
		
		let count = termListVCH.getAllTermsCount()
		
		categoryNameLabel.text = ("\(category.name) (\(count))")
		
		favoritesCountLabel.text = String (termListVCH.getFavoriteTermsCount())
		
		showFavoritesOnlyButton.isOn = termListVCH.showFavoritesOnly
	}
	
	// MARK: - TermListVCHDelegate functions
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldReloadCellAt(indexPath: IndexPath) {
		print("in TermListVC reloadCellAt delegate function")
		//tableView.reloadData()
		tableView.reloadRows(at: [indexPath], with: .fade)
		
	}
	
	func shouldClearSearchText () {
		searchBar.text = ""
	}
	
	func shouldSegueToTermVC() {
		termListVCH.termEditMode = .view
		performSegue(withIdentifier: myConstants.segueTerm, sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueSelectCatetory:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			
			vc.categoryHomeVCH.displayMode = .selectCategory
			
			vc.categoryHomeVCH.currentCategoryID = termListVCH.currentCategoryID
			
		case myConstants.segueTerm:
			
			// need to determine with displayMode to show the TermVC in
			// displayMode = view if the user clicked a row to view a term
			// displayMode = add if the user clicked the add term button
			// use the variable termListVCH.displayModeForTermVC
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! TermVC
			vc.termVCH.currentCategoryID = termListVCH.currentCategoryID
			
			switch termListVCH.termEditMode {
			
			case .view:
				vc.termVCH.term = tc.getTerm(termID: termListVCH.termIDForSegue)
				
			case .add:
				vc.termVCH.term = Term()
			}
	
			
		default:
			print("fatal error no matching segue in termListVC prepare function")
		}
	}
	
	// MARK: - Search bar functions and delegates
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if searchBar.showsCancelButton == false {
			searchBar.showsCancelButton = true
		}
		
		termListVCH.searchText = searchBar.text
		termListVCH.updateData()
		tableView.reloadData()
		updateDisplay()
		
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.text = nil
		searchBar.showsCancelButton = false
		searchBar.endEditing(true)
		
		termListVCH.searchText = .none
		termListVCH.updateData()
		updateDisplay()
	}
	
	@IBAction func ShowFavoritesOnlyButtonAction(_ sender: ZUIToggleButton) {
		print("here at button action")
		termListVCH.showFavoritesOnly.toggle()
		termListVCH.updateData ()
		tableView.reloadData()
		updateDisplay()
		
	}
	
	@IBAction func addTermButtonAction(_ sender: Any) {
		termListVCH.termEditMode = .add
		performSegue(withIdentifier: myConstants.segueTerm, sender: self)
	}
	
}


/*
working on search function
// remove any leading spaces and if blank, make search text nil and return

let noLeading = tu.removeLeadingSpaces(input: searchBar.text ?? "")

if noLeading == "" {
	// the search box is empty spaces only
	searchBar.text = .none
	termListVCH.searchText = .none
	return
} else {
	
}

// when here there is some text in the search box.

termListVCH.searchText = cleanText

termListVCH.updateData()
tableView.reloadData()
updateDisplay()
*/




/*

var dItem: DItem! //to hold the dItem for the segue
var listTC: TermListVCH! //need to keep a reference here

let dIC = DItemController()

override func viewDidLoad() {

super.viewDidLoad()

//setting my ListTC class as the tableview datasource and delegate
listTC = TermListVCH()
tableView.dataSource = listTC
tableView.delegate = self

//formatting
favoritesSwitch.layer.cornerRadius = 16
favoritesSwitch.clipsToBounds = true
favoritesSwitch.onTintColor = myTheme.colorFavorite
favoritesSwitch.isOn = listTC.isFavoritesOnly()

//setting the same instance of ListTC and set its delegate to SELF to it can message back to me here
listTC.delegate = self

noFavoritesLabel.text = myConstants.noFavoritesAvailableText

//need this here so cancel button does not get hidden.... seems like a hack
searchBar.searchBarStyle = .prominent
searchBar.delegate = listTC
updateDisplay()
}

override func viewDidAppear(_ animated: Bool) {
updateDisplay()
}

private func updateDisplay () {
//call this function to update the display
//remember to use listTC.makeList function to refresh the data before using tableView.reload
updateCounter()
tableView.reloadData()
let favCount = dIC.getCount(favoriteState: 1, learnedState: -1)

if listTC.isFavoritesOnly() {
favoritesSwitch.isOn = true
} else {
favoritesSwitch.isOn = false
}

//  if you are searching, you have to show a table regardless with some or no results
//  regardless of the favorite button

if listTC.isSearching() {
//in search mode
tableView.isHidden = false
noFavoritesLabel.isHidden = true
heartImage.isHidden = true


} else {
//not in search mode. need to see if we are showing only favorites and the favorite count is 0

if favCount == 0 && listTC.isFavoritesOnly() {
//favorite list is empty. do not show the table Need to show the list is empty message
tableView.isHidden = true
noFavoritesLabel.isHidden = false
heartImage.isHidden = false

} else {
//need to show table data
tableView.isHidden = false
noFavoritesLabel.isHidden = true
heartImage.isHidden = true
}
}
}

private func updateCounter () {
let favCount = dIC.getCount(favoriteState: 1, learnedState: -1)
favoritesLabel.text = "\(favCount)"
}

override func didReceiveMemoryWarning() {
super.didReceiveMemoryWarning()
// Dispose of any resources that can be recreated.
}

// table delegate functions
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//save the dItem user selected based on section and row

if let cell = tableView.cellForRow(at: indexPath) as? TermCell {
dItem = cell.dItem
}

performSegue(withIdentifier: "showDItemSegue", sender: self)
}

func favoriteItemChanged() {
updateCounter()
}

func tableDataChanged() {
tableView.reloadData()
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//can have only one seque so don't need to worry about testing for it

if segue.identifier == "showDItemSegue" {
let destVC = segue.destination as! DItemVC
destVC.dItem = self.dItem
} else if segue.identifier == "segueCategories" {
let vc = segue.destination as! CategoryListVC
} else {
if isDevelopmentMode {
print ("no matching segue found: error state in FlashCardHomeVC prepare")
}
}



}

@IBAction func favoritesOnlySwitchAction(_ sender: UISwitch) {
listTC.makeList(favoritesOnly: sender.isOn, searchText: searchBar.text ?? "")

updateDisplay()
}

*/
