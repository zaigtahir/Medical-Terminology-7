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
	
	let categoryHomeVCH = CategoryHomeVCH()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.dataSource = categoryHomeVCH
		tableView.delegate = categoryHomeVCH
		tableView.tableFooterView = UIView()
		
		categoryHomeVCH.delegate = self
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
	
	func pressedDeleteButtonOnCustomCatetory() {
		//place holder
	}
	
	func pressedAddCategoryButton() {
		
		categoryHomeVCH.addCustomCategoryName(name: "my test")
		
		return
		
		let aC = UIAlertController(title: "New Category", message: "Add a new category", preferredStyle: .alert)
		
		aC.addTextField(configurationHandler: nil)
		
		let okay = UIAlertAction(title: "OK", style: .default) { (_) in
			let text = aC.textFields![0].text
			
				
			
			
			print("add this category: \(text)")
			self.tableView.reloadData()
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
			//just cancel
		}
		
		aC.addAction(okay)
		aC.addAction(cancel)
		present(aC, animated: true, completion: nil)
	}
	
	func shouldRefreshTable() {
		print("reloading in shouldRefreshTable")
		tableView.reloadData()
	}
	//MARK: End Delegate functions for CategoryHomeVCHDelegate
	
}
