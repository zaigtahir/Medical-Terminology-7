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
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var termNameLabel: UILabel!
	@IBOutlet weak var totalCategoriesSelectedLabel: UILabel!
	
	let categoryListVCH = CategoryListVCH()
	
	// used just to pass info from performSegue to prepare for segue
	private var segueCategory: Category!
		
	override func viewDidLoad() {
		
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.dataSource = categoryListVCH
		tableView.delegate = categoryListVCH
		tableView.tableFooterView = UIView()
		
		categoryListVCH.delegate = self
		
		
		//set the title and header image
		if categoryListVCH.categoryListMode == .selectCategories {
			self.title = "Categories To View"
			selectModeImage.isHidden = false
			termNameLabel.isHidden = true
			
		} else {
			self.title = "Assign To Categories"
			selectModeImage.isHidden = true
			termNameLabel.isHidden = false
			termNameLabel.text = "For Term: \(categoryListVCH.term.name)"
			
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateDisplay()
	}
	
	func updateDisplay () {
	

		if categoryListVCH.categoryListMode == .selectCategories {
			
			totalCategoriesSelectedLabel.text =  "Total selected categories: \(categoryListVCH.selectedCategoryIDs.count)"
		} else {
			totalCategoriesSelectedLabel.text =  "Total assigned categories: \(categoryListVCH.selectedCategoryIDs.count)"
		}
		
		
		if categoryListVCH.categoryListMode == .selectCategories {
			
			if categoryListVCH.selectedCategoryIDs.count == 0 { 
				// no category selected
				let ac = UIAlertController(title: "Select A Category", message: "Please select one or more  categories to view.", preferredStyle: .alert)
				let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
				
				ac.addAction(okay)
				
				self.present(ac, animated: true, completion: nil)
				
				doneButton.isEnabled = false
				
			} else {
				doneButton.isEnabled = true
			}
			
		}
	
	}
	// MARK: - categoryListVCHDelegate functions
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldUpdateDisplay () {
		updateDisplay()
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
	
	func shouldShowAlertSelectedLockedCategory(categoryID: Int) {
		
		var message : String
		
		switch categoryID {
		case 1:
			message = "The All Terms category is automatically assigned to all terms"
		case 2:
			message = "The My Terms category is automatically assigned to terms you create"
		default:
			message = "This category is automatically assigned to this term, and it cannot be unassigned"
		}
		
		let ac = UIAlertController(title: "Locked Category", message: message, preferredStyle: .alert)
		let okay = UIAlertAction(title: "OK", style: .default, handler: .none)
		ac.addAction(okay)
		self.present(ac, animated: true, completion: nil)
	}
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueCategory:
			let vc = segue.destination as? CategoryVC
			vc?.categoryVCH.category = segueCategory
			
		
		
		
		
		//
		// vc?.categoryVCH.currentCategoryIDs = categoryListVCH.curr
			
			
			
		default:
			print ("fatal error did not find a matching segue in prepar funtion of categoryListVC")
		}
		
	}
	
	@IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
		
		if categoryListVCH.categoryListMode == .selectCategories {
			categoryListVCH.checkSelectedCategoriesPN ()
		} else {
			categoryListVCH.checkAssignedCategories()
		}
		
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
