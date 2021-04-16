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
		
		if categoryVCH.category.isStandard {
			nameTitleLabel.text = "PREDEFINED CATEGORY"
			nameEditButton.isHidden = true
			descriptionEditButton.isHidden = true
			
		} else {
			nameTitleLabel.text = "MY CATEGORY"
			nameEditButton.isHidden = false
			descriptionEditButton.isHidden = false
		}
		
		
		// delete icon
		if categoryVCH.category.isStandard {
			deleteCategoryButton.isHidden = true
		} else {
			deleteCategoryButton.isHidden = false
			if categoryVCH.category.categoryID == -1 {
				deleteCategoryButton.isEnabled = false
			} else {
				deleteCategoryButton.isEnabled = true
			}
		}
		
		
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
			
			let vc = segue.destination as! SingleLineInputVC
			categoryVCH.configureSingleLineInputVC(vc: vc)
			
		case myConstants.segueMultiLineInput:
			
			let vc = segue.destination as! MultiLineInputVC
			categoryVCH.configureMultiLineInputVC(vc: vc)
		default:
			print("fatal error, called with an unexpecting segue in categoryVC prepare for segue")
		}
	}
	
	@IBAction func leftButtonAction(_ sender: Any) {
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
}
