//
//  CategoryHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class CategoryHomeVCH: NSObject, UITableViewDataSource, UITableViewDelegate {
	
	// manage the datatable source
	// get the categories and display them in the table
	// at the bottom of section 2, display a cell that says "add a category"
	
	let categoryC = CategoryController()
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
	let sectionStandard = 0
	let sectionCustom = 1
	
	override init (){
		//any init functions here
		standardCategories = categoryC.getCategories(categoryType: 0)
		customCategories = categoryC.getCategories(categoryType: 1)
		super.init()
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
			return customCategories.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
			
			//make cell here based on the section
			if indexPath.section == sectionStandard {
				//these are default categories
				let text = standardCategories[indexPath.row].name
				cell.textLabel?.text = text
			} else {
				//this is the custom category
				let text = customCategories[indexPath.row].name
				cell.textLabel?.text = text
				cell.textLabel?.textColor = UIColor.blue
			}
			
			return cell
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
			
			actionEdit.backgroundColor = .blue
			
			return UISwipeActionsConfiguration(actions: [actionDelete, actionEdit])
		} else {
			//make info button for the standard categories
			
			let actionInfo = UIContextualAction(style: .normal, title: "Info") { (_, _, _) in
				self.showInfo()
			}
			
			actionInfo.backgroundColor = .blue
			
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
	
	func deleteRow (indexPath: IndexPath) {
		//place holder
	}
	
	func editCategory (indexPath: IndexPath) {
		//place holder
	}
	
	func showInfo () {
		//place holder
	}
}
