//
//  AssignTermsVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class AssignTermsVC: UIViewController {

	@IBOutlet weak var categoryNameLabel: UILabel!
	
	@IBOutlet weak var termStatusSwitch: UISegmentedControl!
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	@IBOutlet weak var tableView: UITableView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
	
	func updateDisplay () {
		
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
