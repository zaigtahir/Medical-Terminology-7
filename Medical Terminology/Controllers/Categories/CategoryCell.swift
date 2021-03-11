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

	@IBOutlet weak var selectButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
	
	private var categoryID: Int! // used so I can pass it in the delegate method
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
			selectButton.setImage(myTheme.imageSelectedRow, for: .normal)
			selectButton.tintColor = myTheme.colorMain
		} else {
			//not selected catetory
			selectButton.setImage(myTheme.imageUnselectedRow, for: .normal)
			selectButton.tintColor = myTheme.colorText
		}
	}
	
	@IBAction func selectButtonAction(_ sender: UIButton) {
		delegate?.selectedCategory(categoryID: self.categoryID, indexPath: self.indexPath)
	}
	
}
