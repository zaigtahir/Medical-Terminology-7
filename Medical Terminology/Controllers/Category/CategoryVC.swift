//
//  CategoryVC2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController, CategoryVCHDelegate {
	
	@IBOutlet weak var headerImage: UIImageView!
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak var leftButton: UIBarButtonItem!
	
	@IBOutlet weak var deleteCategoryButton: ZUIRoundedButton!
	
	@IBOutlet weak var nameTitleLabel: UILabel!
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var nameEditButton: UIButton!
	
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var descriptionEditButton: UIButton!
	
	var categoryVCH = CategoryVCH()
	
	let cc = CategoryController()
	
	private let tu = TextUtilities()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateDisplay()
		
		//navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
		
		self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "My Title", style: .plain, target: nil, action: nil)
		
		
		categoryVCH.delegate = self
		
		// Do any additional setup after loading the view.UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
	}
	
	// MARK: - categoryVCH2Delegate
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldAlertDuplicateCategoryName() {
		let ac = UIAlertController(title: "Duplicate Name", message: "This category name already exists, please try a different category name", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: .none)
		ac.addAction(ok)
		present(ac, animated: true, completion: nil)
	}
	
	// MARK: - updateDisplay
	
	func updateDisplay () {
		
		func formatButtons() {
			
			/*
			If the category is edited:
			name is valid: Save.Enabled, Cancel.Enabled
			name is not valid: Save.Disabled, Cancel.Enabled
			
			if the category is NOT edited:
			new category: Save.Disabled, Cancel.Enabled
			not new category: Done.Enabled, Cancel.Disabled
			
			*/
			
			
			if categoryVCH.categoryWasEdited() {
				
				if categoryVCH.editedCategory.name != "" {
					// both required fields have data
					leftButton.title = "Save"
					leftButton.isEnabled = true
					cancelButton.isEnabled = true
				} else {
					leftButton.title = "Save"
					leftButton.isEnabled = false
					cancelButton.isEnabled = true
				}
				
			} else {
				
				// no edits have been made yet
				if categoryVCH.editedCategory.categoryID == -1 {
					// the category is new
					leftButton.title = "Save"
					leftButton.isEnabled = false
					cancelButton.isEnabled = true
				} else {
					leftButton.title = "Done"
					leftButton.isEnabled = true
					cancelButton.isEnabled = false
				}
			}
	
			
			if categoryVCH.editedCategory.isStandard {
				
				self.title = "Predefined Category"
				nameEditButton.isHidden = true
				descriptionEditButton.isHidden = false
			} else {
				self.title = "My Category"
				nameEditButton.isHidden = false
				descriptionEditButton.isHidden = false
			}
			
			// format the delete icon
			if categoryVCH.editedCategory.isStandard {
				deleteCategoryButton.isEnabled = false
			} else {
				if categoryVCH.editedCategory.categoryID == -1 {
					deleteCategoryButton.isEnabled = false
				} else {
					deleteCategoryButton.isEnabled = true
				}
			}
			
		}
		
		func formatFields() {
			
			if categoryVCH.editedCategory.name == "" {
				nameLabel.text = "Category name"
			} else {
				nameLabel.text = categoryVCH.editedCategory.name
			}
			
			if categoryVCH.editedCategory.description == "" {
				
				if categoryVCH.editedCategory.categoryID == -1 {
					descriptionLabel.text = "(optional)"
				} else {
					descriptionLabel.text = "No description available"
				}
				
			} else {
				descriptionLabel.text = categoryVCH.editedCategory.description
			}
			
			if categoryVCH.editedCategory.categoryID == -1 {
				headerImage.image = myTheme.imageHeaderAdd
			}
		}
		
		formatButtons()
		
		formatFields()
		
	}
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		categoryVCH.prepare(for: segue, sender: sender)
	}
	
	@IBAction func leftButtonAction(_ sender: Any) {
		
		print("for now just dismiss the vc")
		
		/*
		
		if new category, save new category -> show success dialog box -> change to existing category view
		
		if preexisting category and there are edits -> save edits -> change to no edits state
		
		if preextisting category and no edits -> just dismiss
		
		*/
		
		if categoryVCH.editedCategory.categoryID == -1 {
			// this is a new term, so save it
			categoryVCH.saveNewCategory()
			updateDisplay()
			
			let ac = UIAlertController(title: "Success!", message: "Your category was saved, and it will show up in alphabetical order in the My Categories section.", preferredStyle: .alert)
			let ok = UIAlertAction(title: "OK", style: .cancel, handler: .none)
			ac.addAction(ok)
			self.present(ac, animated: true, completion: nil)
			
		} else {
			// this is not a new term, so check to see it has been editied
			
			if categoryVCH.categoryWasEdited() {
				
				categoryVCH.updateCategoryPN()
				
			} else {
				
				self.navigationController?.dismiss(animated: true, completion: nil)
				
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		/*
		if categoryVCH.category.categoryID == -1 {
			// this is a new category, save it
			
			categoryVCH.addNewCategory()
			
		}
		*/
		
		
		
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func deleteCategoryButtonAction(_ sender: Any) {
		
		print("to code delete category button")
		
		// only delete a non-standard category
		
		if !categoryVCH.editedCategory.isStandard {
			
			let ac = UIAlertController(title: "Delete Category?", message: "Are you sure you want to delete this category? Just FYI: When you delete a category, no terms will be deleted", preferredStyle: .alert)
			
			let delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
				//self.cc.deleteCategoryPN(categoryID: self.categoryVCH.category.categoryID)
				self.categoryVCH.deleteCategory()
				self.navigationController?.popViewController(animated: true)
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
				self.navigationController?.popViewController(animated: true)
			}
			
			ac.addAction(cancel)
			ac.addAction(delete)
			present(ac, animated: true, completion: nil)
		}
	}
}
