//
//  CategoryVC2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC2: UIViewController {

	@IBOutlet weak var headerImage: UIImageView!
	
	@IBOutlet weak var deleteCategoryButton: UIButton!
	
	@IBOutlet weak var nameTitleLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var nameEditButton: UIButton!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var descriptionEditButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
	// MARK: - updateDisplay
	
	func updateDisplay() {
		
	}
	
	// MARK: - prepare segue

}
