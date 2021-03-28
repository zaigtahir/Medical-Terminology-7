//
//  CategoryVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/28/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {
	
	@IBOutlet weak var headerImage: UIImageView!
	@IBOutlet weak var promptLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var commitButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	
	let categoryVCH = CategoryVCH()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		// setup the view based on the categoryDisplayMode in the header file
		
		// format button
		commitButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		switch categoryVCH.categoryDisplayMode {
		
		case .add:
			headerImage.image = myTheme.imageHeaderAdd
			promptLabel.text = "Add a New Category"
			messageLabel.text = "After you add a new category, you can assign terms to it to help organize your learning"
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Add", for: .normal)
			commitButton.backgroundColor = myTheme.colorAddButton
			
		case .edit:
			headerImage.image = myTheme.imageHeaderEdit
			promptLabel.text = "Edit the Category Name"
			messageLabel.text = "Make changes to the category name"
			textField.text = "Initial Name"
			textField.isUserInteractionEnabled = true
			commitButton.setTitle("Save", for: .normal)
			commitButton.backgroundColor = myTheme.colorEditButton
			commitButton.setImage(nil, for: .normal)
			
		case .delete:
			headerImage.image = myTheme.imageHeaderDelete
			promptLabel.text = "Delete This Category?"
			messageLabel.text = "When you delete a category, no terms are deleted"
			textField.text = "Sample Name"
			textField.isUserInteractionEnabled = false
			commitButton.setTitle("Delete", for: .normal)
			commitButton.backgroundColor = myTheme.colorDeleteButton
			commitButton.setImage(nil, for: .normal)
		}
	}
		
	@IBAction func commitButtonAction(_ sender: Any) {
	}
	
	@IBAction func cancelButtonAction(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
