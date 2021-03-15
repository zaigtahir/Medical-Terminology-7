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
	func newCategorySelected ()
	func shouldReloadTable ()
}

class CategoryHomeVCH: NSObject, UITableViewDataSource, UITableViewDelegate{
	
	// manage the datatable source
	// get the categories and display them in the table
	// at the bottom of section 2, display a cell that says "add a category"
	
	let categoryC = CategoryController()
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
	let sectionCustom = 0
	let sectionStandard = 1
	
	let displayMode = CategoryViewMode.assignCategory
	
	weak var delegate : CategoryHomeVCHDelegate?
	
	override init (){
		//any init functions here
		super.init()
		getCategories()
	}
	
	func getCategories () {
		standardCategories = categoryC.getCategories(categoryType: 0)
		customCategories = categoryC.getCategories(categoryType: 1)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		if displayMode == .assignCategory {
			return 1	// just need 1 section if showing assignCategory mode for the custom category
		} else {
			return 2
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if section == sectionCustom {
			
			if customCategories.count == 0 {
				return nil
			} else {
				return "Custom Categories"
			}
		} else {
			return "Standard Categories"
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == sectionStandard {
			return standardCategories.count
		} else {
			return customCategories.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CategoryCell {
			
			if indexPath.section == sectionStandard {
				cell.formatCell(category: standardCategories[indexPath.row], indexPath: indexPath)
			} else {
				cell.formatCell(category: customCategories[indexPath.row], indexPath: indexPath)
			}
			
			return cell
			
		} else {
			return UITableViewCell()
		}
		
	}
	
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
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var categoryID: Int
		
		if indexPath.section == sectionStandard {
			categoryID = standardCategories[indexPath.row].categoryID
		} else {
			categoryID = customCategories[indexPath.row].categoryID
		}
		
		// if this category is selected already then don't do anything
		
		let currentCategoryID = categoryC.getCurrentCategory().categoryID
		
		if categoryID != currentCategoryID {
			
			categoryC.toggleCategorySelection(categoryID: categoryID)
			
			//need to refresh local copy of the categories
			getCategories()
			delegate?.newCategorySelected()
			delegate?.shouldReloadTable()
		}
		
	}
	
	func addCustomCategoryName(name: String){
		//call the add Category function from the categoryController
		categoryC.addCustomCategory(name: name)
		getCategories()
		delegate?.shouldReloadTable()
	}
	
	func deleteCategory (categoryID: Int) {
		categoryC.deleteCustomCategory(categoryID: categoryID)
		getCategories()
		delegate?.shouldReloadTable()
	}
	
	func changeCategoryName (categoryID: Int, nameTo: String) {
		//place holder
		categoryC.changeCustomCategoryName(categoryID: categoryID, nameTo: nameTo)
		getCategories()
		delegate?.shouldReloadTable()
	}
}
