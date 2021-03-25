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
		countLabel.text = String (displayCategory.count!)
		
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
	
	func formatCellAssignCategory (category: Category, dItem: DItem) {
		// category is the category the cell is displaying
		// item has all the categories it is assigned to

		// get category count
		if let count = category.count {
			countLabel.text = String (count)
		}
		
		nameLabel.text = category.name
		
		if let customIDs = dItem.customCategoryIDs {
					
			if ((category.categoryID == dItem.categoryID) || (customIDs.contains(category.categoryID))) {
				// this item is assigned this category
				selectImage.image = myTheme.imageRowSelected
				selectImage.tintColor = myTheme.colorMain
				
			} else if (category.categoryID == dItem.defaultCategoryID) {
				// this is the default category and not selected
				selectImage.image = myTheme.imageRowDefaultCategory
				selectImage.tintColor = myTheme.colorText
				
			} else {
				// not selected, and not default
				selectImage.image = myTheme.imageRowNotSelected
				selectImage.tintColor = myTheme.colorText
			}
		}
		
	}
		
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
