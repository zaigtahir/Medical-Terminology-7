//
//  HelpScreenVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/4/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class HelpScreenVC: UIViewController {

	@IBOutlet weak var seeWebsiteButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

	@IBAction func seeWebsiteButton(_ sender: Any) {
		
		if let url = URL(string: myConstants.appWebsite) {
			UIApplication.shared.open(url)
		}
		
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
