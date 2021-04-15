//
//  CategoryVC2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC2: UIViewController {

	@IBOutlet weak var headerImage: UIImageView!
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak var leftButton: UIBarButtonItem!
	
	@IBOutlet weak var deleteCategoryButton: UIButton!

	@IBOutlet weak var nameTitleLabel: UILabel!
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var nameEditButton: UIButton!
	
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var descriptionEditButton: UIButton!
	
	var categoryVCH = CategoryVCH2()
		
		
    override func viewDidLoad() {
        super.viewDidLoad()
		updateDisplay()
		
		//navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
		
		self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "My Title", style: .plain, target: nil, action: nil)
		

        // Do any additional setup after loading the view.UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
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
			
			if let singleLineInputVC = segue.destination as? SingleLineInputVC {
				singleLineInputVC.textInputVCH.fieldTitle = "CATEGORY NAME"
				singleLineInputVC.textInputVCH.initialText = categoryVCH.category.name
				singleLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
				singleLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
				singleLineInputVC.textInputVCH.minLength = 1
				singleLineInputVC.textInputVCH.maxLength = myConstants.maxLengthCategoryName
				singleLineInputVC.textInputVCH.propertyReference = .none
				// need to add delegate
				
				
			}
			
		case myConstants.segueMultiLineInput:
			
			if let multiLineInputVC = segue.destination as? MultiLineInputVC {
				multiLineInputVC.textInputVCH.fieldTitle = "DESCRIPTION"
				multiLineInputVC.textInputVCH.initialText = categoryVCH.category.description
				multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
				multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
				multiLineInputVC.textInputVCH.minLength = 0
				multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthCategoryDescription
				multiLineInputVC.textInputVCH.propertyReference = .definition
				// need to add delegate
			}
			
			
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
