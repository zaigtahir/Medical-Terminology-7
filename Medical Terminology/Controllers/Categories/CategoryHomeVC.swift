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
	
	func pressedEditButtonOnCustomCategory() {
		//place holder
	}
	
	func requestDeleteCategory(categoryID: Int, name: String) {
		
		let title = "Delete \"\(name)?\""
		
		let aC = UIAlertController(title: title, message: "Are you sure you want to delete this category?", preferredStyle: .alert)
		let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
			self.categoryHomeVCH.deleteCategory(categoryID: categoryID)
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			self.tableView.reloadData()	// doing this so that swipe action goes away
		}
		
		aC.addAction(cancel)
		aC.addAction(delete)
		
		self.present(aC, animated: true, completion: nil)
	}
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	//MARK: End Delegate functions for CategoryHomeVCHDelegate
	
	private func addNewCategory () {
		
		let aC = UIAlertController(title: "New Category", message: "Add a new category", preferredStyle: .alert)
		
		aC.addTextField(configurationHandler: nil)
		
		let utilities = Utilities()
		
		let okay = UIAlertAction(title: "OK", style: .default) { [self] (_) in
			if let inputText = aC.textFields![0].text {
				let cleanText = utilities.cleanString(string: inputText)
				if cleanText != "" {
					self.categoryHomeVCH.addCustomCategoryName(name: cleanText)
				}
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
			//just cancel
		}
		
		aC.addAction(cancel)
		aC.addAction(okay)
		present(aC, animated: true, completion: nil)
		
	}
	
	@IBAction func addCustomCategoryButtonAction(_ sender: UIButton) {
		self.addNewCategory()
	}

}
