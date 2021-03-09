//
//  CategoryHomeVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class CategoryHomeVCH: NSObject, UITableViewDataSource {
	
	// manage the datatable source
	// get the categories and display them in the table
	// at the bottom of section 2, display a cell that says "add a category"
	
	let categoryC = CategoryController()
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
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
		if section == 0 {
			return "Standard Categories"
		} else {
				return  "Custom Categories"
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return standardCategories.count
		} else {
			return customCategories.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
			
			//make cell here based on the section
			if indexPath.section == 0 {
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
	
}
