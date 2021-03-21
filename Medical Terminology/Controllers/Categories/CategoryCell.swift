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
	
	func formatCellSelectCategory (category: Category, tabCategoryID: Int) {

		if let count = category.count {
			self.countLabel.text = String(count)
		}
		
		
		nameLabel.text = category.name
		
		if category.categoryID == tabCategoryID {
			//selected category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
		} else {
			//not selected category
			if category.count == 0 {
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
				//this item is assigned this category
				selectImage.image = myTheme.imageRowSelected
				selectImage.tintColor = myTheme.colorMain
			}
		}
		
		
		/*
		if category.categoryID == dItem.categoryID {
			//this item belongs to this category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
			
		} else {
			// this item does not belong to this category. BUT is this category the default for this item?
			if category.categoryID == dItem.defaultCategoryID {
				// this is the default category
				selectImage.image = myTheme.imageRowDefaultCategory
				selectImage.tintColor = myTheme.colorText
				
			} else {
				// this item is not in this category and this category is not its default category
				//not selected catetory
				selectImage.image = myTheme.imageRowNotSelected
				selectImage.tintColor = myTheme.colorText
			}

		}
		*/
		
	
		
	}
		
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
