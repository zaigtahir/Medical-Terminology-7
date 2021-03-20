//
//  CategoryHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

protocol CategoryHomeVCHDelegate: class {
	//will shoot functions to the CategoryHomeVHC
	func pressedInfoButtonOnStandardCategory ()
	func pressedEditButtonOnCustomCategory (categoryID: Int, name: String)
	func requestDeleteCategory (categoryID: Int, name: String)
	
	func shouldReloadTable ()
}

class CategoryHomeVCH: NSObject, UITableViewDataSource, UITableViewDelegate {
	
	// manage the datatable source
	// get the categories and display them in the table
	// at the bottom of section 2, display a cell that says "add a category"
	
	// view state variables init to a default value, but need to set the in the segue
	
	var displayMode = CategoryViewMode.selectCategory
	var sectionName = SectionName.flashcards
	
	private var sectionCategoryID = 0
	

	var itemID 		: Int!
	

	var categoryID  = 0 	//set this when using the assignCategory mode
	

	
	let cC = CategoryController()
	
	var standardCategories = [Category]()
	
	//this is same as the standard categories except that it won't contain category 0 which is "All Standard Categories)
	var standardCategoriesAssign = [Category] ()
	
	var customCategories = [Category]()
	
	let sectionCustom = 0
	let sectionStandard = 1
	
	let dIC = DItemController3()
	
	weak var delegate : CategoryHomeVCHDelegate?
	
	override init (){
		//any init functions here
		super.init()
		getCategories()
		
		sectionCategoryID = cC.getSectionCategoryID(sectionName: sectionName)
	}
	
	func getCategories () {
		standardCategories = cC.getCategories(categoryType: .standard)
		
		standardCategoriesAssign = cC.getCategories(categoryType: .standard)
		standardCategoriesAssign.remove(at: 0)	// removing the category 0 as it is at index 0
		
		customCategories = cC.getCategories(categoryType: .custom)
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
	
	/*
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		//determine the category the user selected
	
		let category = self.getCatetory(indexPath: indexPath)
		
		// toggle the categories
		
		switch displayMode {
		
		case .selectCategory:
			
			if category.selected {
				//user clicked on a category that's already selected
				return
			}
			
			if cC.toggleSelectCategory(categoryID: category.categoryID) {
				// change to the category was made
				//need to refresh local copy of the categories
				getCategories()
				delegate?.categoryChanged(categoryID: category.categoryID)
				delegate?.shouldReloadTable()
			}
			
		case .assignCategory:
			
			print ("passing in case .assignCategory")
			
			if cC.isCategoryStandard(categoryID: category.categoryID) {
				//assign standard category
				let changed = cC.changeStandardCategory(categoryID: category.categoryID, itemID: itemID)
				
				if changed {
					// change to the category was made
					// need to refresh local copy of the categories
					
					//need to update this item not categories
					delegate?.itemCategoryChanged()
					return
				}
			}
			
			// of here, the selected category is a custom category
			print("need to assign custom category")
			
		}
	}
	*/
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print ("implement didSelecRowAt")
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
			
			let category = self.getCatetory(indexPath: indexPath)
			category.count = cC.getItemCountInCategory(categoryID: category.categoryID)
			
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
	private func getCatetory (indexPath: IndexPath) -> Category {
		
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
		
		cell.countLabel.text = String (category.count)
		cell.nameLabel.text = category.name
		
		switch displayMode {
		
		case .selectCategory:
			cell.formatCellSelectCategory(category: category, sectionCategoryID: sectionCategoryID)
			
		case .assignCategory:
			let dItem = dIC.getDItem(itemID: itemID)
			cell.formatCellAssignCategory(category: category, dItem: dItem)
		}
		
	}
	
	// End support functions for table cell for row at
	
	/*
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		if indexPath.section == sectionCustom {
			let name = self.customCategories[indexPath.row].name
			let categoryID = self.customCategories[indexPath.row].categoryID
			
			let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
				//completionHandler(false)
				self.delegate?.requestDeleteCategory(categoryID: categoryID, name: name)
			}
			
			let actionEdit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
				
				self.delegate?.pressedEditButtonOnCustomCategory(categoryID: categoryID, name: name)
				
			}
			
			actionEdit.backgroundColor = myTheme.colorEditButton
			
			// check if the category is already selected. In that case, do not allow deletion of the category
			
			if customCategories[indexPath.row].selected {
				return UISwipeActionsConfiguration(actions: [actionEdit])
			} else {
				return UISwipeActionsConfiguration(actions: [actionDelete, actionEdit])
			}
			
		} else {
			//make info button for the standard categories
			
			let actionInfo = UIContextualAction(style: .normal, title: "Info") { (_, _, _) in
				self.delegate?.pressedInfoButtonOnStandardCategory()
			}
			
			actionInfo.backgroundColor = myTheme.colorInfoButton
			
			return UISwipeActionsConfiguration(actions: [actionInfo])
		}
	}
	*/
	
	
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
		cC.addCustomCategory(name: name)
		getCategories()
		delegate?.shouldReloadTable()
	}
	
	func deleteCategory (categoryID: Int) {
		cC.deleteCategory(categoryID: categoryID)
		getCategories()
		delegate?.shouldReloadTable()
	}
	
	func changeCategoryName (categoryID: Int, nameTo: String) {
		//place holder
		cC.changeCategoryName(categoryID: categoryID, nameTo: nameTo)
		getCategories()
		delegate?.shouldReloadTable()
	}
}
