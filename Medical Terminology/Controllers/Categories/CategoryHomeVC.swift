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
		
		let aC = UIAlertController(title: title, message: "Do you want to delete this category?", preferredStyle: .alert)
		let yes = UIAlertAction(title: "Yes", style: .destructive) { (_) in
			self.categoryHomeVCH.deleteCategory(categoryID: categoryID)
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
			// nothing
		}
		
		aC.addAction(cancel)
		aC.addAction(yes)
		
		self.present(aC, animated: true, completion: nil)
	}
	
	func shouldReloadTable() {
		print("reloading in shouldRefreshTable")
		tableView.reloadData()
	}
	
	//MARK: End Delegate functions for CategoryHomeVCHDelegate
	
	@IBAction func addCustomCategoryButtonAction(_ sender: UIButton) {
		
		categoryHomeVCH.addCustomCategoryName(name: "Hard Questions")

	}
	
}
