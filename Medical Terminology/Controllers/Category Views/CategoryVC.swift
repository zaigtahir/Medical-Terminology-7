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
	override func viewDidLoad() {
		
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		
    }
    
	@IBAction func commitButtonAction(_ sender: Any) {
	}
	
	@IBAction func cancelButtonAction(_ sender: UIButton) {
	}

}
