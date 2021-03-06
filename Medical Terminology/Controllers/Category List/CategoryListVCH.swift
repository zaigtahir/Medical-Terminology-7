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
	func shouldSegueToPreexistingCategory (category: Category)
	func shouldSegueToNewCategory ()
	func shouldDismissCategoryMenu ()
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
	let cc = CategoryController()
	let tc = TermController()
	
	// categories
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
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
		fillCategoryLists()
		delegate?.shouldReloadTable()
		
	}
	
	@objc func deleteCategoryN (notification: Notification) {
		// a category was deleted
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
	}
	
	func fillCategoryLists () {
		standardCategories = cc.getCategories(categoryType: .standard)
		
		// remove the All Terms and My Terms row if this is in the assign mode
		
		if categoryListMode == .assignCategory {
			//removing first 2 standards in fillCategoryLissts as im in assign mode
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
		var rowCategory: Category
		
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
	
	private func formatAssignCell (cell: CategoryCell, rowCategory: Category) {
		
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
			delegate?.shouldSegueToNewCategory()
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
			// selected a category to view, dismiss the menu after that selections
			self.selectedSelectRowPN(didSelectRowAt: indexPath, categoryID: rowCategory.categoryID)
			delegate?.shouldDismissCategoryMenu()
			
		} else {
			// notification happens later
			self.selectedAssignRow(didSelectRowAt: indexPath, category: rowCategory)
			
		}
	}
	
	private func getRowCategory (indexPath: IndexPath) -> Category {
		
		// determine which category the row contains
		var rowCategory: Category
		
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
	
	private func selectedAssignRow (didSelectRowAt indexPath: IndexPath, category: Category) {
		
		if term.termID == -1 {
			cc.toggleCategoriesNewTermPN(term: term, categoryID: category.categoryID)
			delegate?.shouldReloadTable()
			
		} else {
			
			// notification happens later depending on the category selection and the one being viewed
			cc.toggleCategories(term: term, categoryID: category.categoryID)
			updateData()
			delegate?.shouldReloadTable()
		}
	}
	
	
	// MARK: - CategoryCellDelegate
	func shouldSegueToCategory(category: Category) {
		
		delegate?.shouldSegueToPreexistingCategory(category: category)
	}
	
}

