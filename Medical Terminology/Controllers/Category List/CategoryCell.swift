//
//  CategoryCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol CategoryCellDelegate: AnyObject {
	func shouldSegueToCategory (category: Category)
}

class CategoryCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var selectImage: UIImageView!
	@IBOutlet weak var countLabel: UILabel!
	
	// hold the state of this cells isEnable so I can use it later in the didSelectRow method I just have a default value here, but when you format the cell, you will also end up setting this value
	var  isSelectable = true
	
	// itialize this with the rowCategory value so that I can use it in the delegate function
	
	private var category: Category!
	
	weak var delegate : CategoryCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	func formatCellSelectCategory (rowCategory: Category, currentCategory: Int, isSelectable: Bool ) {
		nameLabel.text  = rowCategory.name
		countLabel.text = String (rowCategory.count)
		self.isSelectable = isSelectable
		self.category = rowCategory
		
		if rowCategory.categoryID == currentCategory {
			//selected category
			selectImage.image = myTheme.imageRowSelected
			selectImage.tintColor = myTheme.colorMain
		
		} else {
			//category is not selected
			selectImage.image = myTheme.imageRowNotSelected
			selectImage.tintColor = myTheme.colorText
		}
		
	}
	
	func formatCellAssignCategory (rowCategory: Category, currentCategoryID: Int, assignedCategoryIDsForTerm ids: [Int], isSelectable: Bool ) {
		
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
		delegate?.shouldSegueToCategory(category: self.category)
	}
	
}
