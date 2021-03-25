//
//  CategoryHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit


/*
Use this protocal to communicate to the FlashcardVCH (or other header controller)
*/
protocol CategorySelectedDelegate: class {
	func categorySelected (categoryID: Int)
}

/*
Use this protocol call to communicate back to the home controller
*/
protocol CategoryHomeDelegate: class {
	//will shoot functions to the CategoryHomeVHC
	func pressedInfoButtonOnStandardCategory ()
	func pressedEditButtonOnCustomCategory (categoryID: Int, name: String)
	func requestDeleteCategory (categoryID: Int, name: String)
	func reloadTable ()
}

class CategoryHomeVCH: NSObject, UITableViewDataSource, UITableViewDelegate {
		
	var displayMode = CategoryViewMode.selectCategory
	var currentCategoryID = 1	//just simulation, need to load in the segue
	
	// use to refer to the section of the table
	let sectionCustom = 0
	let sectionStandard = 1
	
	// controllers
	let cc = CategoryController2()
	
	// categories
	var standardCategories = [Category2]()
	var customCategories = [Category2]()
	
	weak var categorySelectedDelegate: CategorySelectedDelegate?
	
	override init () {
		super.init()
		fillCategoryLists()
	}
	
	func fillCategoryLists () {
		standardCategories = cc.getCategories(categoryType: .standard)
		customCategories = cc.getCategories(categoryType: .custom)
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
		if section == sectionCustom {
			return customCategories.count + 1
		} else {
			return standardCategories.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
				
		// address the case if this is the last (add) row in the custom section
		if indexPath.section == sectionCustom && indexPath.row == customCategories.count {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddCell
			return cell!
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryCell
		
		// determine category
		var category: Category2
		
		if indexPath.section == sectionStandard {
			category = standardCategories[indexPath.row]
		} else {
			category = customCategories[indexPath.row]
		}
	
		// determine item count
		category.count = cc.getCountOfTerms(categoryID: category.categoryID)
		
		cell?.formatCellSelectCategory(displayCategory: category, currentCatetory: self.currentCategoryID)
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// address the case if this is the last (add) row in the custom section
		if indexPath.section == sectionCustom && indexPath.row == customCategories.count {
			print("add code to add a catetory")
			return
		}
		
		// determine category
		var category: Category2
		
		if indexPath.section == sectionStandard {
			category = standardCategories[indexPath.row]
		} else {
			category = customCategories[indexPath.row]
		}
		
		categorySelectedDelegate?.categorySelected(categoryID: category.categoryID)
		
	}
	
	
	
	
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
}
