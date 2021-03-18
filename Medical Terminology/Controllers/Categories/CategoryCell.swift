//
//  CategoryCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol CategoryCellDelegate: class {
	//trigger when the user presses the category button
	func selectedCategory (categoryID: Int)
}

class CategoryCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var selectImage: UIImageView!
	@IBOutlet weak var showDetailButton: UIButton!
	@IBOutlet weak var countLabel: UILabel!
	
	private var categoryID = 0 // used so I can pass it in the delegate method
	
	weak var delegate : CategoryCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func formatCellSelectCategory (category: Category) {
		
		self.categoryID = category.categoryID
		self.countLabel.text = String(category.count)
		
		nameLabel.text = category.name
		
		if category.selected {
			//selected category
			selectImage.image = myTheme.imageSelectedRow
			selectImage.tintColor = myTheme.colorMain
		} else {
			//not selected catetory
			selectImage.image = myTheme.imageUnselectedRow
			selectImage.tintColor = myTheme.colorText
		}
	}
	
	func formatCellAssignCategory (category: Category, dItem: DItem) {
		//nothing for now
		
		countLabel.text = String(category.count)
		
		if category.categoryID == dItem.categoryID {
			//this item belongs to this category
			selectImage.image = myTheme.imageSelectedRow
			selectImage.tintColor = myTheme.colorMain
		
		} else {
			
				// this item does not belong to this category. BUT is this category the default for this item?
			if category.categoryID == dItem.defaultCategoryID {
				// this is the default category
				selectImage.image = myTheme.imageDefaultCategory
				selectImage.tintColor = myTheme.colorText
				
				
			} else {
				// this item is not in this category and this category is not its default category
				//not selected catetory
				selectImage.image = myTheme.imageUnselectedRow
				selectImage.tintColor = myTheme.colorText
			}
		}
		
		nameLabel.text = category.name

	}
	
	func getCateoryID () -> Int {
		return categoryID
	}
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
