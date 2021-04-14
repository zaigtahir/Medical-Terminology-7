//
//  CategoryListVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

/*
Fires off a notification if a user changes the currentCategoryID
All controllers that are affected by that can respond to it
*/
protocol CategoryListVCHDelegate: AnyObject {
	
	func shouldReloadTable ()
	func shouldSegueToCatetory (category: Category2)
}

class CategoryListVCH: NSObject, UITableViewDataSource, UITableViewDelegate, CategoryCellDelegate {
	
	/*
	In the assign category mode:
	If the term is a standard term, disable all the standard rows
	if the term is a custom term, disable standard and my terms
	so, need to have a disabled, row view made
	*/
	
	// Set these in prepare segue
	var categoryListMode = CategoryListMode.selectCategory
	var currentCategoryID : Int!
	
	// Term to use for category assignments
	// When the termID = -1, the VCH will use the term var to read and save the categories instead of the db
	var term: Term!
	
	// use to refer to the section of the table
	let sectionCustom = 0
	let sectionStandard = 1
	
	// controllers
	let cc = CategoryController2()
	let tc = TermController()
	
	// categories
	var standardCategories = [Category2]()
	var customCategories = [Category2]()
	
	weak var delegate : CategoryListVCHDelegate?
	
	override init() {
		super.init()
		
		/*
		Need to listen to 4 notifications and address them
		addCategoryKey
		deleteCategoryKey
		changeCategoryNameKey
		*/
		
		let nameACK = Notification.Name(myKeys.addCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(addCategoryN (notification:)), name: nameACK, object: nil)
		
		let nameDCK = Notification.Name(myKeys.deleteCategoryKey)
		NotificationCenter.default.addObserver(self, selector: #selector(deleteCategoryN (notification:)), name: nameDCK, object: nil)
		
		let nameCCN = Notification.Name(myKeys.changeCategoryNameKey)
		NotificationCenter.default.addObserver(self, selector: #selector(changeCategoryNameN(notification:)), name: nameCCN, object: nil)
		
		if categoryListMode == .assignCategory {
			// if this is not a new term, add it's assigned categories to it
			if term.termID != -1 {
				term.assignedCategories = tc.getTermCategoryIDs(termID: term.termID)
			}
		}
		
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	
	@objc func addCategoryN (notification: Notification) {
		
		// refresh the data
		fillCategoryLists()
		delegate?.shouldReloadTable()
	}
	
	@objc func changeCategoryNameN (notification: Notification) {
		// refresh the lists and table
		print("categoryListVCH got changeCategoryNameN")
		fillCategoryLists()
		delegate?.shouldReloadTable()
		
	}
	
	@objc func deleteCategoryN (notification: Notification) {
		// a category was deleted
		print("categoryListVCH got deleteCategoryN")
		// if the current category was deleted, then load up All Terms category
		if let data = notification.userInfo as? [String : Int] {
			if data["categoryID"] == currentCategoryID {
				// refresh the data
				currentCategoryID = myConstants.dbCategoryAllTermsID
			}
		}
		
		//refresh the lists and table
		fillCategoryLists()
		delegate?.shouldReloadTable()
	}
	
	func updateData() {
		if term.termID == -1 {
			//refresh the term from the db
			term = tc.getTerm(termID: term.termID)
		}
		
		term.assignedCategories = tc.getTermCategoryIDs(termID: term.termID)
		
		print("categoryListVCH undateData, forcing the term = isStandard = no for testing")
	}
	
	func fillCategoryLists () {
		standardCategories = cc.getCategories(categoryType: .standard)
		
		// remove the All Terms and My Terms row if this is in the assign mode
		
		if categoryListMode == .assignCategory {
			print("removing first 2 standards in fillCategoryLissts as im in assign mode")
			standardCategories.remove(at: 0)
			standardCategories.remove(at: 0)
		}
		
		customCategories = cc.getCategories(categoryType: .custom)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if section == sectionCustom {
			return "My Categories"
		}
		else {
			return "Standard Categories"
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == sectionCustom {
			return customCategories.count + 1
		} else {
			return standardCategories.count
		}
	}
	
	// MARK: - tableview cellForRowAt
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// MARK: if this is the "add custom category row"
		if indexPath.section == sectionCustom && indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddCell
			return cell!
		}
		
		// derive the category from the row selection
		var rowCategory: Category2
		
		if indexPath.section == sectionStandard {
			rowCategory = standardCategories[indexPath.row]
		} else {
			rowCategory = customCategories[indexPath.row - 1] // -1 as for 1 is the add row
		}
		// attach count
		rowCategory.count = cc.getCountOfTerms(categoryID: rowCategory.categoryID)
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryCell {
			
			switch categoryListMode {
			
			case .selectCategory:
				
				cell.formatCellSelectCategory(rowCategory: rowCategory, currentCategory: self.currentCategoryID, isSelectable: true )
				cell.delegate = self
				return cell
				
			case .assignCategory:
				formatAssignCell(cell: cell, rowCategory: rowCategory)
				return cell
			}
			
		} else {
			print("fatal error could not dequeue resusable cell")
			return UITableViewCell()
		}
		
	}
	
	private func formatAssignCell (cell: CategoryCell, rowCategory: Category2) {
		
		/*
		need to figure out if the cell will be active or look disabled
		only the name and the selector will look dimmed, the accessory item and arrow will be normal
		I can't use make the cell non-interactable completely
		*/
		
		var rowIsEnabled  = true
		
		// if this is a standard term && this is a standard category, disable the row
		if term.isStandard && rowCategory.isStandard {
			rowIsEnabled = false
		}
		
		// if this is a custom category, disable All Terms (1) and My Terms (2) category
		if !term.isStandard && rowCategory.categoryID <= 2 {
			rowIsEnabled = false
		}
		
		cell.formatCellAssignCategory(rowCategory: rowCategory, currentCategoryID: currentCategoryID, assignedCategoryIDsForTerm: term.assignedCategories, isSelectable: rowIsEnabled)
		cell.delegate = self
		
	}
	
	
	// MARK: - tableview didSelectRowAt
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// address the case if the user pressed the add category row
		if indexPath.section == sectionCustom && indexPath.row == 0 {
			
			print("add code for adding a category categoroyListVCH didSelectRowAt")
			// self.categoryHomeDelegate?.addACategory()
			return
		}
		
		if let selectedCell = tableView.cellForRow(at: indexPath) as? CategoryCell {
			if selectedCell.isSelectable == false {
				// don't do anything. This cell is not meant to be selected
				return
			}
		}
		
		// determine which category the row contains
		let rowCategory = getRowCategory(indexPath: indexPath)
		
		if categoryListMode == .selectCategory {
			self.selectedSelectRowPN(didSelectRowAt: indexPath, categoryID: rowCategory.categoryID)
		} else {
			self.selectedAssignRow(didSelectRowAt: indexPath, category: rowCategory)
		}
		
	}
	
	private func getRowCategory (indexPath: IndexPath) -> Category2 {
		
		// determine which category the row contains
		var rowCategory: Category2
		
		if indexPath.section == sectionStandard {
			rowCategory = standardCategories[indexPath.row]
		} else {
			rowCategory = customCategories[indexPath.row - 1]
		}
		
		return rowCategory
	}
	
	private func selectedSelectRowPN (didSelectRowAt indexPath: IndexPath, categoryID: Int) {
		
		// if the user selected the same category then don't do anything
		if categoryID == currentCategoryID {
			return
		}
		
		// change current category here reload the selection table
		
		currentCategoryID = categoryID
		
		// MARK: Fire off a notification of the category change!!
		let name = Notification.Name(myKeys.currentCategoryChangedKey)
		NotificationCenter.default.post(name: name, object: self, userInfo: ["categoryID" : currentCategoryID as Any])
		
		delegate?.shouldReloadTable()
	}
	
	private func selectedAssignRow (didSelectRowAt indexPath: IndexPath, category: Category2) {
		
		if term.termID == -1 {
			
			cc.toggleCategoriesNewTermPN(term: term, categoryID: category.categoryID)
			
			delegate?.shouldReloadTable()
			
		} else {
			
			cc.toggleCategories(term: term, categoryID: category.categoryID)
			updateData()
			delegate?.shouldReloadTable()
		}
	}
	
	
	// MARK: - CategoryCellDelegate
	func shouldSegueToCategory(category: Category2) {
		
		delegate?.shouldSegueToCatetory(category: category)
	}
	
}




/*


// MARK: Make trailing swipe actions
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

// do not allow left swipe action on the add category row
if indexPath.section == sectionCustom && indexPath.row == 0 {
return nil
}

// show edit/delete in custom rows
// show info in the standard rows

let rowCategory = getRowCategory(indexPath: indexPath)

let actionInfo = UIContextualAction(style: .normal, title: "Info") { (_, _, completionHandler) in
// add action to do here
self.categoryHomeDelegate?.pressedInfoButtonOnStandardCategory()
completionHandler(false)
}
actionInfo.backgroundColor = myTheme.colorMain

let actionEdit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
// add edit code here
self.categoryHomeDelegate?.pressedEditButtonOnCustomCategory(category: rowCategory)
completionHandler(false)
}
actionEdit.backgroundColor = myTheme.colorMain

let actionDelete  = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
// add delete code here
self.categoryHomeDelegate?.pressedDeleteButtonOnCustomCatetory(category: rowCategory)
completionHandler(false)

}

if rowCategory.isStandard {
return UISwipeActionsConfiguration(actions: [actionInfo])
} else {
return UISwipeActionsConfiguration(actions: [actionDelete, actionEdit])
}
}


*/




/*

// manage the datatable source
// get the categories and display them in the table
// at the bottom of section 2, display a cell that says "add a category"

// view state variables init to a default value, but need to set the in the segue

var displayMode = CategoryViewMode.selectCategory
var sectionName = MainSectionName.flashcards

var itemID 		: Int!

let catC = CategoryController()

var standardCategories = [Category]()
var standardCategoriesAssign = [Category] () //same as standardCategories except the [0] All categories
var customCategories = [Category]()

let sectionCustom = 0
let sectionStandard = 1

let dIC = DItemController3()

weak var delegate : CategoryHomeVCHDelegate?

override init (){
//any init functions here
super.init()
getCategories()
}

func getCategories () {
standardCategories = catC.getCategories(categoryType: .standard)

standardCategoriesAssign = catC.getCategories(categoryType: .standard)
standardCategoriesAssign.remove(at: 0)	// removing the category 0 as it is at index 0

customCategories = catC.getCategories(categoryType: .custom)
}

func numberOfSections(in tableView: UITableView) -> Int {
return 2
}

func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

if section == sectionCustom {
return "Custom Categories"
}
else {
return "Standard Categories"
}
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

if section == sectionStandard {
if displayMode == .selectCategory {
return standardCategories.count
} else {
return standardCategoriesAssign.count

}

} else {
if customCategories.count == 0 {
return 1	// to use as a place holder for the row showing no categories are available
} else {
return customCategories.count
}
}
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//determine the category the user selected
let selectedCategory = self.getSelectedCatetory(indexPath: indexPath)

switch displayMode {

case .selectCategory:
print ("in selectCategoryMode, selected \(selectedCategory.name)")
catC.setSectionCategoryID(sectionName: sectionName, categoryID: selectedCategory.categoryID)
tableView.reloadData()

case .assignCategory:
print ("in assignCategoryMode, selected \(selectedCategory.name)")
}

}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
// return cell based on the display mode

// first deal with case of custom catetory is empty, and just return the empty cell type
if indexPath.section == sectionCustom && customCategories.count == 0 {
if let cell = tableView.dequeueReusableCell(withIdentifier: "cellNoCategories") as? NoCategoriesCell {
return cell
} else {
return UITableViewCell()
}
}

// at this point, the custom categories are not empty, make a cell that I can fill
if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CategoryCell {

let category = self.getSelectedCatetory(indexPath: indexPath)

self.formatCell(cell: cell, category: category)

return cell

} else {
return UITableViewCell()
}

}

// MARK: support functions for table view

/*
will return the category based on the index path and also will update the category.count
*/
private func getSelectedCatetory (indexPath: IndexPath) -> Category {

var category: Category

if indexPath.section == sectionStandard {

if displayMode == .selectCategory {

category = standardCategories[indexPath.row]

} else {

category = standardCategoriesAssign[indexPath.row]
}


} else {
category = customCategories[indexPath.row]
}


return category
}

/*
Will format and retun a cell based on the display mode
*/
private func formatCell (cell: CategoryCell, category: Category) {

//count and label probably should not be done here

//this is the what category the current home view controller is in

let mainSectionCategoryID = catC.getMainSectionCategoryID(mainSectionName: sectionName)

category.count = catC.getItemCountInCategory(categoryID: category.categoryID)

switch displayMode {

case .selectCategory:
cell.formatCellSelectCategory(category: category, tabCategoryID: mainSectionCategoryID)

case .assignCategory:
let dItem = dIC.getDItem(itemID: itemID)

//fill the default and custom category id's for this item
dItem.defaultCategoryID = catC.getItemDefaultCategoryID(itemID: dItem.itemID)
dItem.customCategoryIDs = catC.getItemCustomCategoryIDs(itemID: dItem.itemID)

cell.formatCellAssignCategory(category: category, dItem: dItem)
}

}

// End support functions for table cell for row at

func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

let selectedCategory = getSelectedCatetory(indexPath: indexPath)

// MARK: Make actions
let actionInfo = UIContextualAction(style: .normal, title: "Info") { (_, _, _) in
self.delegate?.pressedInfoButtonOnStandardCategory()
}
actionInfo.backgroundColor = myTheme.colorInfoButton

let actionEdit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
self.delegate?.pressedEditButtonOnCustomCategory(categoryID: selectedCategory.categoryID, name: selectedCategory.name)
}
actionEdit.backgroundColor = myTheme.colorEditButton

let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
//completionHandler(false)
self.delegate?.requestDeleteCategory(categoryID: selectedCategory.categoryID, name: selectedCategory.name)
}

// MARK: Assign actions to rows
if selectedCategory.categoryID < myConstants.dbCustomCategoryStartingID {
// in standard category range
return UISwipeActionsConfiguration(actions: [actionInfo])

} else {
// in custom category range

if displayMode == .selectCategory {
let sectionCategoryID = catC.getMainSectionCategoryID(mainSectionName: self.sectionName)

if selectedCategory.categoryID == sectionCategoryID {
// do not allow deletion
return UISwipeActionsConfiguration(actions: [actionEdit])
} else  {
// allow edit and deletion as this is the current section id and it is not selected
return UISwipeActionsConfiguration(actions: [actionDelete, actionEdit])
}

} else {
print("display mode is assign category, need to work on how to allow swipe actions for custom rows")
return UISwipeActionsConfiguration(actions: [actionEdit])
}

}


}

func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

//disallow swipe edit of no categories placeholder cell
if indexPath.section == sectionCustom && customCategories.count == 0 {
return false
} else {
return true
}

}

func addCustomCategoryName(name: String){
//call the add Category function from the categoryController
catC.addCustomCategory(name: name)
getCategories()
delegate?.shouldReloadTable()
}

func deleteCategory (categoryID: Int) {
catC.deleteCategory(categoryID: categoryID)
getCategories()
delegate?.shouldReloadTable()
}

func changeCategoryName (categoryID: Int, nameTo: String) {
//place holder
catC.changeCategoryName(categoryID: categoryID, nameTo: nameTo)
getCategories()
delegate?.shouldReloadTable()
}

*/
