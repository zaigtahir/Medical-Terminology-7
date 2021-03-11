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
	func pressedEditButtonOnCustomCategory ()
	func pressedDeleteButtonOnCustomCatetory ()
	func shouldRefreshTable ()
}

class CategoryHomeVCH: NSObject, UITableViewDataSource, UITableViewDelegate{
	
	// manage the datatable source
	// get the categories and display them in the table
	// at the bottom of section 2, display a cell that says "add a category"
	
	let categoryC = CategoryController()
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
	let sectionStandard = 0
	let sectionCustom = 1
	
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
		return 2
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == sectionStandard {
			return "Standard Categories"
		} else {
			return  "Custom Categories"
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == sectionStandard {
			return standardCategories.count
		} else {
			return customCategories.count + 1 //added one to make cell to add custom category
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// will have different cell for section 1, last row to function as an add row button
		
		if indexPath.section == 0 {
			//default section
			if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CategoryCell {
				cell.formatCell(category: standardCategories[indexPath.row], indexPath: indexPath)
				return cell
			} else {
				return UITableViewCell()
			}
		}
		
		// if here, section == 1
		
		if indexPath.row < customCategories.count {
			// not at last row
			//default section
			if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CategoryCell {
				cell.formatCell(category: customCategories[indexPath.row], indexPath: indexPath)
				return cell
			} else {
				return UITableViewCell()
			}
		}
		
		// fall through, is at last row in custom category, so need to return the cell for adding row
		if let cellAdd = tableView.dequeueReusableCell(withIdentifier: "cellAdd") as? CategoryCell {
			return cellAdd
		} else {
			return UITableViewCell()
		}
	
	}
	
	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		if indexPath.section == sectionCustom {
			let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
				self.deleteRow(indexPath: indexPath)
			}
			
			let actionEdit = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
				self.editCategory (indexPath: indexPath)
				completionHandler(false)
			}
			
			actionEdit.backgroundColor = myTheme.colorEditButton
			
			return UISwipeActionsConfiguration(actions: [actionDelete, actionEdit])
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
		
		if indexPath.section == 0 {
			return false 	//do not allow to edit the standard rows
		} else {
			return true
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		var categoryID: Int
		
		if indexPath.section == 0 {
			categoryID = standardCategories[indexPath.row].categoryID
		} else {
			categoryID = customCategories[indexPath.row].categoryID
		}
		
		categoryC.toggleCategorySelection(categoryID: categoryID)
		
		//need to refresh local copy of the categories
		getCategories()
		
		delegate?.shouldRefreshTable()
		
	}
	
	func deleteRow (indexPath: IndexPath) {
		//place holder
	}
	
	func editCategory (indexPath: IndexPath) {
		//place holder
	}
	
	
}
