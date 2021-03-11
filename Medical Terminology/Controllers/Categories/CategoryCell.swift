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
	func selectedCategory (categoryID: Int, indexPath: IndexPath)
}

class CategoryCell: UITableViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var selectImage: UIImageView!
	
	@IBOutlet weak var showDetailButton: UIButton!
	
	private var categoryID = 0 // used so I can pass it in the delegate method
	
	private var indexPath: IndexPath!	// used so I can pass it back in the delgate method
	weak var delegate : CategoryCellDelegate?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func formatCell (category: Category, indexPath: IndexPath) {
		
		self.categoryID = category.categoryID
		self.indexPath = indexPath
		
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
	
	func getCateoryID () -> Int {
		return categoryID
	}
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		print("show detail button pressed")
	}
	
}
