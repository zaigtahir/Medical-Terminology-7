//
//  CategoryCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/10/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

	@IBOutlet weak var selectButton: UIButton!
	@IBOutlet weak var nameLabel: UILabel!
	
	var category : Category!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func formatCell (category: Category) {
		nameLabel.text = category.name
		if category.selected {
			//selected category
			selectButton.setImage(myTheme.imageSelectedRow, for: .normal)
			selectButton.tintColor = myTheme.colorMain
		} else {
			//not selected catetory
			selectButton.setImage(myTheme.imageUnselectedRow, for: .normal)
			selectButton.tintColor = UIColor.green
		}
	}

}
