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
	
	// hold the state of this cells isEnable so I can use it later in the didSelectRow method I just have a default value here, but when you format the cell, you will also end up setting this value
	var isSelectable = true
	
	//	private var categoryID = 0 // used so I can pass it in the delegate method
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func formatCellSelectCategory (rowCategory: Category2, currentCatetory: Int, isSelectable: Bool ) {
		nameLabel.text  = rowCategory.name
		countLabel.text = String (rowCategory.count)
		self.isSelectable = isSelectable
		
		if rowCategory.categoryID == currentCatetory {
			//selected category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
		
		} else {
			//category is not selected
			selectImage.image = myTheme.imageRowNotSelected
			selectImage.tintColor = myTheme.colorText
		}
		
	}
	
	func formatCellAssignCategory (rowCategory: Category2, currentCategoryID: Int, assignedCategoryIDsForTerm ids: [Int], isSelectable: Bool ) {
		
		nameLabel.text  = rowCategory.name
		nameLabel.textColor = myTheme.colorText
		countLabel.text = String (rowCategory.count)
		countLabel.text = String (rowCategory.count)
		self.isSelectable = isSelectable
		
		if ids.contains(rowCategory.categoryID) {
			// the term is assigned this category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
			
		} else {
			// not assigned to this category, but if this is the current category, use a different not selected icon
			if rowCategory.categoryID == currentCategoryID {
				selectImage.image = myTheme.imageRowCurrentCategoryNotSelected
				
			} else {
				selectImage.image = myTheme.imageRowNotSelected
			}
			
			selectImage.tintColor = myTheme.colorText
		}
		
		if isSelectable == false {
			nameLabel.textColor = myTheme.colorUnavailableCatetory
			selectImage.tintColor = myTheme.colorUnavailableCatetory
			countLabel.text = String (rowCategory.count)
		}
		
		
	}
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
