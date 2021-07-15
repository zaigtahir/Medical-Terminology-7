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
	@IBOutlet weak var informationButton: UIButton!
	
	@IBOutlet weak var progressBar: UIProgressView!
	
	// itialize this with the rowCategory value so that I can use it in the delegate function
	
	private var category: Category!
	private let cc = CategoryController()
	private let utilities = Utilities()
	private let tcTB = TermControllerTB()
	
	weak var delegate : CategoryCellDelegate?
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		//circleBarView.tintColor = UIColor.systemBackground
		
	}
	
	
	func configure (category: Category, selectedCategoryIDs: [Int], lockCategoryIDs: [Int]) {
		
		self.category = category
		nameLabel.text = category.name
		
		let pc = ProgressCounts()
		pc.update(categoryID: category.categoryID)
		
		
		if pc.totalCategoryTerms == 0 {
			progressBar.progress = 0.0
		} else {
			progressBar.progress = pc.totalDone()
			
			
		}
		
		let title = "\(pc.totalDonePercent())% Done, \(pc.totalCategoryTerms) Terms "

		
		informationButton.setTitle(title, for: .normal)
		
		
		// set initial colors so if a locked-appearing cell is resused, the colors don't stay as the locked colors
		selectImage.tintColor = myTheme.colorText
		nameLabel?.textColor = myTheme.colorText
		
		
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
			selectImage.tintColor = myTheme.colorButtonNoBackgroundDisabledTint
		}
		
	}
	
	
	@IBAction func showDetailButtonAction(_ sender: UIButton) {
		delegate?.shouldSegueToCategory(category: self.category)
	}
	
}
