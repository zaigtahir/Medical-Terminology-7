//
//  CategoryListVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/9/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit


/*
Fires off a notification if a user changes the currentCategoryID
All controllers that are affected by that can respond to it
*/
protocol CategoryListVCHDelegate: AnyObject {
	
	func shouldReloadTable ()
	func shouldUpdateDisplay ()
	func shouldSegueToPreexistingCategory (category: Category)
	func shouldSegueToNewCategory ()
	func shouldDismissCategoryMenu ()
	func shouldShowAlertSelectedLockedCategory (categoryID: Int)
}

// This is just for the TermVCH to use
protocol TermCategoryIDsDelegate: AnyObject {
	func termCategoryIDsChanged (categoryIDs: [Int])
}

class CategoryListVCH: NSObject, UITableViewDataSource, UITableViewDelegate, CategoryCellDelegate, CategoryEditDelegate {

	// REMOVE after modifying other parts of the program
	var currentCategoryID =  -1
	
	
	// MARK: - TODO: these properties will need to be made PRIVATE as I code the other sections
	
	var categoryListMode = CategoryListMode.selectCategories
	
	// Fill Initial categories when using selectCategory mode
	// If using assignCategoryMode, the initialCategories will be set to term.assignedCategories
	var initialCategoryIDs = [3,4,5]
	
	// Provide a term when Assigning Categories to a term
	// When the term is new, termID = -1
	// Have the term.assignedCategories filled before assigning the term via the seque. For a new term, termID = -1, and assign category 1 and 2 to the new
	var term: TermTB!
	
	
	// MARK: - local variables
	
	var selectedCategoryIDs: [Int]!
	
	// use to refer to the section of the table
	let sectionCustom = 0
	let sectionStandard = 1
	
	// controllers
	let cc = CategoryController()
	let utilities = Utilities()
	
	// categories to use to fill the category name and counts (not if it's selected or not selected. That is done using the selectedCategories [Int] array)
	
	var standardCategories = [Category]()
	var customCategories = [Category]()
	
	weak var delegate: CategoryListVCHDelegate?
	
	weak var assignedCategoryIDsDelegate : TermCategoryIDsDelegate?
	
	override init () {
		super.init()
		
				
		let nameCCN = Notification.Name(myKeys.categoryNameChangedKey)
		NotificationCenter.default.addObserver(self, selector: #selector(categoryNameChangedN(notification:)), name: nameCCN, object: nil)
		
		updateData()
		
	}
	
	deinit {
		// remove observer (s)
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - notification functions
	
	@objc func categoryNameChangedN (notification: Notification) {
		// refresh the lists and table
		updateData()
		delegate?.shouldReloadTable()
		
	}

	
	// END of notification functions
	
	func updateData () {
		standardCategories = cc.getCategories(categoryType: .standard)
		
		customCategories = cc.getCategories(categoryType: .custom)
	}
	
	func setupAssignCategoryMode (term: TermTB) {
		categoryListMode = .assignCategories
		self.term = term
		self.initialCategoryIDs = term.assignedCategories
		selectedCategoryIDs = term.assignedCategories
	}
	
	func setupSelectCategoryMode (initialCategories: [Int]) {
		categoryListMode = .selectCategories
		self.initialCategoryIDs = initialCategories
		selectedCategoryIDs = initialCategories
	}
	
	func getTotalSelectedCategories () -> Int {
		
		if categoryListMode == .selectCategories {
			// Select category mode
			return selectedCategoryIDs.count
			
		} else {
			// Assign category mode
			// if standard term, subtract out for category 1 as the user will not see it any way on the UI
			// if custom germ, stubtract out for category 1 and 2 as the user will not see it any way on the UI
			if term.isStandard {
				return selectedCategoryIDs.count - 1
			} else {
				return selectedCategoryIDs.count - 2
			}
		}
		
	}
	
	// The categoryListVC calls this when the user presses the done button
	
	func checkSelectedCategoriesPN () {
	
		if !utilities.containSameElements(array1: initialCategoryIDs, array2: selectedCategoryIDs) {
		
			if categoryListMode == .selectCategories {
				// post a notification so all controllers can react
				let name = Notification.Name(myKeys.currentCategoryIDsChanged)
				NotificationCenter.default.post(name: name, object: self, userInfo: ["categoryIDs" : selectedCategoryIDs as Any])
				
			} else {
				// trigger a delegate method so that the TermVC can update it self
				assignedCategoryIDsDelegate?.termCategoryIDsChanged(categoryIDs: selectedCategoryIDs)
			}
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		if section == sectionCustom {
			return "My Categories"
		}
		else {
			return "Standard Categories"
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == sectionCustom {
			return customCategories.count + 1
		} else {
			return standardCategories.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// MARK: if this is the "add custom category row"
		if indexPath.section == sectionCustom && indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddCell
			return cell!
		}
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CategoryCell {
			
			var category : Category
			
			if indexPath.section == sectionCustom {
				// subtracting 1 to account for the "add category" row
				category = customCategories[indexPath.row - 1]
			} else {
				category = standardCategories[indexPath.row]
			}
			
			// attach term count
			category.count = cc.getCountOfTerms(categoryID: category.categoryID)
			
			// setup lock categories if I am in the assign category mode
			var categoriesToLock = [Int]()
			if categoryListMode == .assignCategories {
				categoriesToLock = [1, 2, term.secondCategoryID, term.thirdCategoryID]
			}
						
			cell.formatCategoryCell(category: category, selectedCategoryIDs: selectedCategoryIDs, lockCategoryIDs: categoriesToLock)
			
			cell.delegate = self
			
			return cell
		} else {
			return UITableViewCell()
		}
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// address the case if the user pressed the add category row
		if indexPath.section == sectionCustom && indexPath.row == 0 {
			delegate?.shouldSegueToNewCategory()
			return
		}
		
		var selectedCategory : Category
		
		// determine which category is selected
		if indexPath.section == sectionCustom {
			selectedCategory = customCategories[indexPath.row-1]
		} else {
			selectedCategory = standardCategories[indexPath.row]
		}
		
		// if in assign categories mode and the user clicked on a locked category, make no changes to the selection and
		// the categoryVC should show an alert
		
		if categoryListMode == .assignCategories {
			let lockedCategories = [1, 2, term.secondCategoryID, term.thirdCategoryID]
			if lockedCategories.contains(selectedCategory.categoryID) {
				delegate?.shouldShowAlertSelectedLockedCategory(categoryID: selectedCategory.categoryID)
				return
			}
		}
		
		
		// if the user selected categoryID = 1, unselect everything else and refresh the table and display
		if selectedCategory.categoryID == 1 {
			selectedCategoryIDs = [1]
			tableView.reloadData()
			delegate?.shouldUpdateDisplay()
			return
		}
		
		// user clicked on something other than categoryID = 1
		if selectedCategoryIDs == [1] {
			selectedCategoryIDs = [Int]()
		}
		
		if let categoryIDIndex = selectedCategoryIDs.firstIndex(of: selectedCategory.categoryID) {
			// this categoryID is already selected, need to remove it from the selection
			selectedCategoryIDs = utilities.removeIndex(index: categoryIDIndex, array: selectedCategoryIDs)
			
		} else {
			// add it to the list
			selectedCategoryIDs.append(selectedCategory.categoryID)
		}
		
		tableView.reloadData()
		
		delegate?.shouldUpdateDisplay()
		
	}
	
	// MARK: - CategoryCellDelegate
	func shouldSegueToCategory(category: Category) {
		delegate?.shouldSegueToPreexistingCategory(category: category)
	}
	
	// MARK: - CategoryEditDelegate
	
	func categoryDeleted(categoryID: Int) {
		
		/*
		if the initialCategoryIDs contains the deletedCategoryID:
		Remove it
		If that leads to an empty initialCategoryIDs, set initialCategoryIDs = [1]
		broadcast the notification: currentCategoryIDsChanged
		currentCategoryIDsChangedKey
		userInfo: [“categoryIDs” : initialCategoryIDs as Any]
		Note: using the initiaCategoryIDs here as the user has not pressed save yet to I do not need to save any updates the user has made to the category selections. I’m sending out this notification as all the other VHC’s need to react to this change immediately.

		if the selectedCategoryIDs contain the deletedCategoryID:
		remove it
		if that leads to an empty selectedCategoryIDs, set selectedCategoryIDs = [1]
		refresh the CategoryListVC
		*/
		
		if initialCategoryIDs.contains(categoryID) {
			initialCategoryIDs = utilities.removeFirstValue(value: categoryID, array: initialCategoryIDs)
			
			if initialCategoryIDs.count == 0 {
				// the user deleted the only currentCategoryIDs, so set the initialCategoryIDs to All Terms
				initialCategoryIDs = [1]
			}
			
			// send out notification of change in currentCategoryIDs
			// Fire off a notification of the category change!!
			
			let name = Notification.Name(myKeys.currentCategoryIDsChanged)
			NotificationCenter.default.post(name: name, object: self, userInfo: ["categoryIDs" : initialCategoryIDs as Any])
		}
		
		if selectedCategoryIDs.contains(categoryID) {
			
			selectedCategoryIDs = utilities.removeFirstValue(value: categoryID, array: selectedCategoryIDs)
			
			if selectedCategoryIDs.count == 0 {
				// the user deleted the only currentCategoryIDs, so set the initialCategoryIDs to All Terms
				selectedCategoryIDs = [1]
			}
			
			// don't have to shoot off currentCategoryIDsChanged as the category deleted is not part of currentCategoryIDs
		}
		
		updateData()
		delegate?.shouldReloadTable()
		delegate?.shouldUpdateDisplay()
		
	}
	
	func categoryAdded() {
		updateData()
		delegate?.shouldReloadTable()
		delegate?.shouldUpdateDisplay()
	}
	
	
}
