//
//  CategoryHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//


// plus.square.fill.on.square.fill
// pencil.circle
// exclamationmark.bubble

import UIKit

class CategoryListVC: UIViewController, CategoryListVCHDelegate {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var selectModeImage: UIImageView!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var termNameLabel: UILabel!
	@IBOutlet weak var termPredefinedButton: UIButton!
	
	let categoryListVCH = CategoryListVCH()
	
	// used just to pass info from performSegue to prepare for segue
	private var segueCategory: Category!
		
	override func viewDidLoad() {
		
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.dataSource = categoryListVCH
		tableView.delegate = categoryListVCH
		tableView.tableFooterView = UIView()
		
		//categoryListVCH.delegate = self
		
		
		//set the title and header image
		if categoryListVCH.categoryListMode == .selectCategory {
			self.title = "Category To View"
			selectModeImage.isHidden = false
			termNameLabel.isHidden = true
			termPredefinedButton.isHidden = true
			
		} else {
			self.title = "Assign Categories"
			selectModeImage.isHidden = true
			termNameLabel.isHidden = false
			
			termNameLabel.text = "For Term: \(categoryListVCH.term.name)"
			
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
	}
	
	// MARK: - categoryListVCHDelegate functions
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldSegueToPreexistingCategory(category: Category) {
		
		self.segueCategory = category
		
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	func shouldSegueToNewCategory() {
		// new empty category will have id = -1
		self.segueCategory = Category()
		
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	func shouldDismissCategoryMenu() {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueCategory:
			let vc = segue.destination as? CategoryVC
			vc?.categoryVCH.category = segueCategory
		default:
			print ("fatal error did not find a matching segue in prepar funtion of categoryListVC")
		}
		
	}
	
	@IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func termPredefinedButtonAction(_ sender: UIButton) {
		let ac = UIAlertController(title: "Locked Term", message: "This is a predefined term, and you can't change it's standard categories. However, you can select any of the \"My Categories\"", preferredStyle: .alert)
		let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		ac.addAction(okay)
		
		self.present(ac, animated: true, completion: nil)
	}

}
