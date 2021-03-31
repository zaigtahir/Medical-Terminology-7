//
//  ValidationVCViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/30/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class ValidationVC: UIViewController {
	
	// variables to set in the segue
	var isValid = false
	var message = ""
	
	@IBOutlet weak var headerImage: UIImageView!
	
	@IBOutlet weak var messageTV: UITextView!
	
	@IBOutlet weak var okayButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		okayButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		if isValid {
			headerImage.tintColor = myTheme.colorButtonEnabledBackground
		} else {
			headerImage.tintColor = myTheme.invalidFieldEntryColor
		}
		messageTV.text = message
        // Do any additional setup after loading the view.
    }
    
	@IBAction func okayButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
