//
//  AssignTermsVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class AssignTermsVC: UIViewController, AssignTermsVCHDelegate {

	@IBOutlet weak var categoryNameLabel: UILabel!
	
	@IBOutlet weak var termsStatusSwitch: UISegmentedControl!
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	@IBOutlet weak var termsCountLabel: UILabel!
	
	@IBOutlet weak var tableView: UITableView!
	
	var assignTermsVCH = AssignTermsVCH()
	
	override func viewDidLoad() {
        super.viewDidLoad()

		tableView.dataSource = assignTermsVCH
    }
	
	func updateDisplay () {
		
		termsCountLabel.text = "Terms Count: \(assignTermsVCH.termsList.getCount())"
		
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: AssignTermsVCH delegate
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldUpdateDisplay() {
	
	}
	
	func shouldReloadRowAt(indexPath: IndexPath) {
		
	}
	
	func shouldRemoveRowAt(indexPath: IndexPath) {
		
	}
	
	func shouldClearSearchText() {
		
	}
	
	@IBAction func termsStatusSwitchChanged(_ sender: Any) {
		assignTermsVCH.assignedListViewMode =  termsStatusSwitch.selectedSegmentIndex
		assignTermsVCH.updateData()
		tableView.reloadData()
		updateDisplay()
	}
}
