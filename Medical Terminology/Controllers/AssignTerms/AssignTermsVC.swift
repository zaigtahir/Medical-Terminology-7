//
//  AssignTermsVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class AssignTermsVC: UIViewController, AssignTermsVCHDelegate, UISearchBarDelegate {
	
	@IBOutlet weak var categoryNameLabel: UILabel!
	
	@IBOutlet weak var termsStatusSwitch: UISegmentedControl!
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	@IBOutlet weak var tableView: UITableView!
	
	var assignTermsVCH = AssignTermsVCH()
	
	private let tcTB = TermControllerTB()
	
	private let cc = CategoryController()
	
	private let utilities = Utilities()
	
	override func viewDidLoad() {
        
		super.viewDidLoad()
		tableView.dataSource = assignTermsVCH
		tableView.delegate = assignTermsVCH
		
		assignTermsVCH.delegate = self
		
		searchBar.delegate = self
		
		categoryNameLabel.text = cc.getCategory(categoryID: assignTermsVCH.categoryID).name
		
		updateDisplay()
		
		
		
    }
	
	func updateDisplay () {
		
		let totalCount = tcTB.getTermCount()
		
		
		if assignTermsVCH.assignedListViewMode == 0 {
			// viewing assigned terms
			
			termsStatusSwitch.setTitle("Assigned: \(assignTermsVCH.termsList.getCount())", forSegmentAt: 0)
			termsStatusSwitch.setTitle("Not Assigned: \(totalCount - assignTermsVCH.termsList.getCount())", forSegmentAt: 1)
		} else {
			termsStatusSwitch.setTitle("Assigned: \(totalCount - assignTermsVCH.termsList.getCount())", forSegmentAt: 0)
			termsStatusSwitch.setTitle("Not Assigned: \(assignTermsVCH.termsList.getCount())", forSegmentAt: 1)
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
	
	// MARK: -AssignTermsVCH delegate
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldReloadRowAt(indexPath: IndexPath) {
		
	}
	
	func shouldRemoveRowAt(indexPath: IndexPath) {		
		tableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
	func shouldClearSearchText() {
		
	}
	
	func shouldShowAlert(title: String, message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
		ac.addAction(okay)
		self.present(ac, animated: true, completion: nil)
	}
	
	// MARK: - Search bar functions and delegates
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	
		if searchBar.showsCancelButton == false {
			searchBar.showsCancelButton = true
		}
		
		assignTermsVCH.searchText = searchBar.text
		assignTermsVCH.updateData()
		tableView.reloadData()
		updateDisplay()
		
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.text = .none
		searchBar.showsCancelButton = false
		searchBar.endEditing(true)
		
		assignTermsVCH.searchText = ""
		assignTermsVCH.updateData()
		tableView.reloadData()
		updateDisplay()
	}
	
	@IBAction func termsStatusSwitchChanged(_ sender: Any) {
		assignTermsVCH.assignedListViewMode =  termsStatusSwitch.selectedSegmentIndex
		assignTermsVCH.updateData()
		tableView.reloadData()
		updateDisplay()
	}
}
