//
//  ListViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 10/27/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit
import SQLite3

class TermListVC: UIViewController, UISearchBarDelegate, TermListVCHDelegate {

	
	//will use ListTC as the table datasource
	//use this VC to use as the table delegate as lots of actions happen based on selection including segue
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var favoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	
	let termListVCH = TermListVCH()
	let cc = CategoryController()
	let tcTB = TermControllerTB()
	let tu = TextUtilities()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		termListVCH.delegate = self
		tableView.delegate = termListVCH
		tableView.dataSource = termListVCH
		tableView.tableFooterView = UIView()
		
		searchBar.delegate = self
		
		favoritesOnlyButton.isOn = termListVCH.showFavoritesOnly
		updateDisplay()
	}
	
	func updateDisplay () {
				
		let favoriteCount = tcTB.getTermCount(categoryIDs: termListVCH.currentCategoryIDs, showFavoritesOnly: true)
		
		let totalTermsCount = tcTB.getTermCount(categoryIDs: termListVCH.currentCategoryIDs, showFavoritesOnly: false)
		
		favoritesOnlyButton.isOn = termListVCH.showFavoritesOnly
		
		favoritesCountLabel.text = String(favoriteCount)
		
		if termListVCH.currentCategoryIDs.count == 1 {
			
			let c = cc.getCategory(categoryID: termListVCH.currentCategoryIDs[0])
			
			categoryNameLabel.text = "\(c.name) (\(totalTermsCount) terms)"
			
		} else {
			
			categoryNameLabel.text = "\(termListVCH.currentCategoryIDs.count) categories selected (\(totalTermsCount) terms)"
		}

	}
	
	// MARK: - TermListVCHDelegate functions
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldReloadRowAt(indexPath: IndexPath) {
		//tableView.reloadData()
		tableView.reloadRows(at: [indexPath], with: .fade)
		
	}
	
	func shouldRemoveRowAt(indexPath: IndexPath) {
		tableView.deleteRows(at: [indexPath], with: .automatic)
	}
	
	func shouldClearSearchText () {
		termListVCH.searchText = ""
		searchBar.text = ""
	}
	
	func shouldSegueToTermVC() {
		termListVCH.termEditMode = .view
		performSegue(withIdentifier: myConstants.segueTerm, sender: self)
	}
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueSelectCategory:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			
			vc.categoryListVCH.setupSelectCategoryMode(initialCategories: termListVCH.currentCategoryIDs)
			
		case myConstants.segueTerm:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! TermVC
		
			switch termListVCH.termEditMode {
			
			case .view:
				let term = tcTB.getTerm(termID: termListVCH.termIDForSegue)
				vc.termVCH.setInitialTerm(initialTerm: term)
				
			case .add:
				
				let newTerm = TermTB()
				
				// assign current categories and 1 & 2
				newTerm.assignedCategories = termListVCH.currentCategoryIDs
				
				if !newTerm.assignedCategories.contains(1) {
					newTerm.assignedCategories.append(1)
				}
				
				if !newTerm.assignedCategories.contains(2) {
					newTerm.assignedCategories.append(2)
				}
				
				// sort the category names in the correct sequence
				cc.sortAssignedCategories(term: newTerm)
				
				vc.termVCH.setInitialTerm(initialTerm: newTerm)
			}
	
			
		default:
			print("fatal error no matching segue in termListVC prepare function")
		}
	}
	
	// MARK: - Search bar functions and delegates
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
	
		if searchBar.showsCancelButton == false {
			searchBar.showsCancelButton = true
		}
		
		termListVCH.searchText = searchBar.text
		termListVCH.updateData()
		tableView.reloadData()
		updateDisplay()
		
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.text = .none
		searchBar.showsCancelButton = false
		searchBar.endEditing(true)
		
		termListVCH.searchText = ""
		termListVCH.updateData()
		tableView.reloadData()
		updateDisplay()
	}
	
	@IBAction func favoritesOnlyButtonAction(_ sender: ZUIToggleButton) {

		termListVCH.showFavoritesOnly.toggle()
		termListVCH.updateData ()
		tableView.reloadData()
		updateDisplay()
		
	}
	
	@IBAction func addTermButtonAction(_ sender: Any) {
		termListVCH.termEditMode = .add
		performSegue(withIdentifier: myConstants.segueTerm, sender: self)
	}
	
}
