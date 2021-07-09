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

	// itialize this with the rowCategory value so that I can use it in the delegate function
	
	private var category: Category!
	
	weak var delegate : CategoryCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	
	func formatCategoryCell (category: Category, selectedCategoryIDs: [Int], lockCategoryIDs: [Int]) {
		
		self.category = category
		nameLabel.text = category.name
		countLabel.text = String (category.count)
		
		// set initial colors so if a locked-appearing cell is resused, the colors don't stay as the locked colors
		selectImage.tintColor = myTheme.colorText
		nameLabel?.textColor = myTheme.colorText
		countLabel.textColor = myTheme.colorText
		
		
		if category.categoryID == 1 {
			// this is All Terms category
			if selectedCategoryIDs.contains(category.categoryID) {
				// All Terms is selected
				selectImage.image = myTheme.imageCircleFill
				selectImage.tintColor = myTheme.colorSelectedRowIndicator
			} else {
				// All Terms is not selected
				selectImage.image = myTheme.imageCircle
				selectImage.tintColor = myTheme.colorText
			}
			
		} else {
			// not category 1 = All Terms, this is another category
			if selectedCategoryIDs.contains(category.categoryID) {
				// All Terms is selected
				selectImage.image = myTheme.imageSquareFill
				selectImage.tintColor = myTheme.colorSelectedRowIndicator
			} else {
				// All Terms is not selected
				selectImage.image = myTheme.imageSquare
				selectImage.tintColor = myTheme.colorText
			}
			
		}
		
		if lockCategoryIDs.contains(category.categoryID) {
			// this category needs to appear locked
			selectImage.tintColor = myTheme.colorLockedCategory
			//nameLabel?.textColor = myTheme.colorLockedCategory
			//countLabel.textColor = myTheme.colorLockedCategory
		}
		
	}
	
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		delegate?.shouldSegueToCategory(category: self.category)
	}
	
}
