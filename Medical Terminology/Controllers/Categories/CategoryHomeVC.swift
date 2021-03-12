//
//  CategoryHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryHomeVC: UIViewController, CategoryHomeVCHDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var addCustomCategoryButton: UIButton!
	
	let categoryHomeVCH = CategoryHomeVCH()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.dataSource = categoryHomeVCH
		tableView.delegate = categoryHomeVCH
		tableView.tableFooterView = UIView()
		
		categoryHomeVCH.delegate = self
		
		addCustomCategoryButton.layer.cornerRadius = myConstants.button_cornerRadius
		
	}
	
	//MARK: Start Delegate functions for CategoryHomeVCHDelegate
	func pressedInfoButtonOnStandardCategory() {
		let aC = UIAlertController(title: "Standard Category", message: "This is a built in category and you cannot edit it. However, you can add your own custom categories and edit or delete them.", preferredStyle: .alert)
		
		let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
		aC.addAction(okay)
		self.present(aC, animated: true, completion: nil)
	}
	
	func pressedEditButtonOnCustomCategory(categoryID: Int, name: String) {
		
		let alertC = UIAlertController(title: "Edit Category Name", message: "", preferredStyle: .alert)
		alertC.addTextField(configurationHandler: nil)
		alertC.textFields![0].text = name
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			//place holder for now
			self.tableView.reloadData() //to get rid of swipe buttons
		}
		
		let okay = UIAlertAction(title: "OK", style: .default) { (_) in
			//place holder for now
			self.tableView.reloadData() // to get rid of the swipe buttons
			
		}
		
		alertC.addAction(okay)
		alertC.addAction(cancel)
		self.present(alertC, animated: true, completion: nil)
	}
	
	func requestDeleteCategory(categoryID: Int, name: String) {
		
		let title = "Delete \"\(name)?\""
		
		let alertC = UIAlertController(title: title, message: "Are you sure you want to delete this category?", preferredStyle: .alert)
		let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
			self.categoryHomeVCH.deleteCategory(categoryID: categoryID)
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.tableView.reloadData()	// doing this so that swipe action goes away
		}
		
		alertC.addAction(delete)
		alertC.addAction(cancel)
		
		self.present(alertC, animated: true, completion: nil)
	}
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	//MARK: End Delegate functions for CategoryHomeVCHDelegate
	
	private func addNewCategory () {
		
		let alertC = UIAlertController(title: "New Category", message: "Add a new category", preferredStyle: .alert)
		
		alertC.addTextField(configurationHandler: nil)
		
		let utilities = Utilities()
		
		let okay = UIAlertAction(title: "OK", style: .default) { [self] (_) in
			if let inputText = alertC.textFields![0].text {
				let cleanText = utilities.cleanString(string: inputText)
				if cleanText != "" {
					self.categoryHomeVCH.addCustomCategoryName(name: cleanText)
				}
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
			//just cancel
		}
		
		alertC.addAction(okay)
		alertC.addAction(cancel)
		present(alertC, animated: true, completion: nil)
		
	}
	
	@IBAction func addCustomCategoryButtonAction(_ sender: UIButton) {
		self.addNewCategory()
	}
	
}
