//
//  CategoryCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var selectImage: UIImageView!
	@IBOutlet weak var showDetailButton: UIButton!
	@IBOutlet weak var countLabel: UILabel!
	
	//	private var categoryID = 0 // used so I can pass it in the delegate method
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func formatCellSelectCategory (displayCategory: Category2, currentCatetory: Int ) {
		nameLabel.text  = displayCategory.name
		countLabel.text = String (displayCategory.count)
		
		if displayCategory.categoryID == currentCatetory {
			//selected category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
		
		} else {
			//not selected category
			if displayCategory.count == 0 {
				//nothing in this category
				selectImage.image = myTheme.imageRowEmpty
			} else {
				selectImage.image = myTheme.imageRowNotSelected
			}
			selectImage.tintColor = myTheme.colorText
		}
		
	}
	
	func formatCellAssignCategory (displayCategory: Category2, assignedCategoryIDsForTerm ids: [Int], isEnabled: Bool ) {
		
		nameLabel.text  = displayCategory.name
		nameLabel.textColor = myTheme.colorText
		countLabel.text = String (displayCategory.count)
		
		if ids.contains(displayCategory.categoryID) {
			// the term is assigned this category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
			
		} else {
			// not selected, and not default
			selectImage.image = myTheme.imageRowNotSelected
			selectImage.tintColor = myTheme.colorText
		}
		
		if isEnabled == false {
			nameLabel.textColor = myTheme.colorUnavailableCatetory
			selectImage.tintColor = myTheme.colorUnavailableCatetory
		}
		
		
	}
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
