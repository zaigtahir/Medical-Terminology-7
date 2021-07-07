//
//  AssignTermCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/4/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class AssignTermCell: UITableViewCell {

	@IBOutlet weak var termNameLabel: UILabel!
	@IBOutlet weak var selectImage: UIImageView!
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func configure (termName: String, isSelected: Bool, isEnabled: Bool) {
		
		termNameLabel.text = termName
		
		if isSelected {
			selectImage.image = myTheme.imageCorrect
		} else {
			selectImage.image = myTheme.imageCircle
		}
		
		if isEnabled {
			termNameLabel.textColor = myTheme.colorText
			if isSelected {
				selectImage.tintColor = myTheme.colorCorrect
			} else {
				selectImage.tintColor = myTheme.colorText
			}
			
		} else {
			termNameLabel.textColor = myTheme.colorButtonDisabledTint
			selectImage.tintColor = myTheme.colorButtonDisabledTint
		}
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
