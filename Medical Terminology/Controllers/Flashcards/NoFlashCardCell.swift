//
//  NoFlashCardCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/21/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class NoFlashCardCell: UICollectionViewCell {
    
	@IBOutlet weak var headerIcon: UIImageView!
	@IBOutlet weak var headingLabel: UILabel!
	@IBOutlet weak var subheadingLabel: UILabel!
	@IBOutlet weak var redoButton: UIButton!
	
	@IBOutlet weak var cellView: UIView!
	override func awakeFromNib() {
		
		super.awakeFromNib()
		// Initialization code
		
		cellView.layer.cornerRadius = myConstants.layout_cornerRadius
		cellView.layer.borderWidth = 1
		cellView.clipsToBounds = true
	
	}
	
	override func layoutSubviews() {
		//set color here to it responds to dark mode
		cellView.layer.borderColor = myTheme.colorCardBorder?.cgColor
	}
}
