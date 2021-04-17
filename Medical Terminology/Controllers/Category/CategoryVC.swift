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
	
	@IBOutlet weak var deleteCategoryButton: UIButton!
	
	@IBOutlet weak var nameTitleLabel: UILabel!
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var nameEditButton: UIButton!
	
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var descriptionEditButton: UIButton!
	
	var categoryVCH = CategoryVCH()
	
	private let tu = TextUtilities()
	
	// keeping a class reference so I can dismiss it in another function
	
	
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
	
	func duplicateCatetoryName() {
		print ("hey this is a duplicate category  name")
	}
	
	// MARK: - updateDisplay
	
	func updateDisplay() {
		
		/*
		If catetory is standard
		DONE | Cancel: disabled
		Hide delete icon
		Hide edit button for name and description
		
		If the category is NOT standard, and IS NEW
		SAVE: enable if name is not blank, otherwise disable
		CANCEL: enabled
		Disable delete icon
		Show edit name and edit description buttons
		
		If the category is NOT standard and IS NOT NEW
		DONE | Cancel: enabled
		Enable delete icon
		Show edit name and edit description buttons
		
		*/
		
		
		// MARK: update buttons and titles
		if categoryVCH.category.isStandard {
			// category is standard
			self.title = "Category Details"
			nameTitleLabel.text = "PREDEFINED CATEGORY"
			nameEditButton.isHidden = true
			descriptionEditButton.isHidden = true
			deleteCategoryButton.isHidden = true
			
			leftButton.title = "Done"
			cancelButton.isEnabled = false
			
		} else {
			// category is not standard
			nameTitleLabel.text = "MY CATEGORY"
			nameEditButton.isHidden = false
			descriptionEditButton.isHidden = false
			deleteCategoryButton.isHidden = false
			
			if categoryVCH.category.categoryID == -1 {
				// category is new
				self.title = "Add New Category"
				headerImage.image = myTheme.imageHeaderAdd
				deleteCategoryButton.isEnabled = false
				
				leftButton.title = "Save"
				
				if categoryVCH.category.name != "" {
					leftButton.isEnabled = true
				} else {
					leftButton.isEnabled = false
				}
				
				cancelButton.isEnabled = true
				
			} else {
				// category is not new
				self.title = "My Categoroy Details"
				deleteCategoryButton.isEnabled = true
				
				leftButton.title = "Done"
				cancelButton.isEnabled = false
			}
		}
		
		// MARK: fill fields
		
		if categoryVCH.category.name == "" {
			nameLabel.text = "New Name"
		} else {
			nameLabel.text = categoryVCH.category.name
		}
		
		if categoryVCH.category.description == "" {
			
			if categoryVCH.category.categoryID == -1 {
				descriptionLabel.text = "(optional)"
			} else {
				descriptionLabel.text = "No description available"
			}
			
		} else {
			descriptionLabel.text = categoryVCH.category.description
		}
		
		if categoryVCH.category.categoryID == -1 {
			headerImage.image = myTheme.imageHeaderAdd
		}
	}
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueSingleLineInput:

			categoryVCH.prepareSingleLineInputVC(segue: segue)
	
		case myConstants.segueMultiLineInput:
		
			categoryVCH.prepareMultiLineInputVC(segue: segue)
		default:
			print("fatal error, called with an unexpecting segue in categoryVC prepare for segue")
		}
	}
	
	@IBAction func leftButtonAction(_ sender: Any) {
		
		if categoryVCH.category.categoryID == -1 {
			// this is a new category, save it
			categoryVCH.saveCategory()
		}
		
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	
	
}
