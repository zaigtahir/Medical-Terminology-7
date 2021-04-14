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

        // Do any additional setup after loading the view.
    }
    
	// MARK: - updateDisplay
	
	func updateDisplay() {
		
		if categoryVCH.category.isStandard {
			nameTitleLabel.text = "PREDEFINED CATEGORY"
		} else {
			nameTitleLabel.text = "MY CATEGORY"
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

}
