//
//  CategoryHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//


// plus.square.fill.on.square.fill
// pencil.circle
// exclamationmark.bubble

import UIKit

class CategoryListVC: UIViewController, CategoryListVCHDelegate {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var selectModeImage: UIImageView!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	@IBOutlet weak var termNameLabel: UILabel!
	@IBOutlet weak var termPredefinedButton: UIButton!
	
	let categoryListVCH = CategoryListVCH()
	
	// used just to pass info from performSegue to prepare for segue
	private var segueCategory: Category2!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.dataSource = categoryListVCH
		tableView.delegate = categoryListVCH
		tableView.tableFooterView = UIView()
		
		categoryListVCH.delegate = self
		
		categoryListVCH.fillCategoryLists()
		
		//set the title and header image
		if categoryListVCH.categoryListMode == .selectCategory {
			self.title = "Category To View"
			selectModeImage.isHidden = false
			termNameLabel.isHidden = true
			termPredefinedButton.isHidden = true
			
		} else {
			self.title = "Assign Categories"
			selectModeImage.isHidden = true
			termNameLabel.isHidden = false
			
			termNameLabel.text = "For Term: \(categoryListVCH.term.name)"
			
			if categoryListVCH.term.isStandard {
				termPredefinedButton.isHidden = false
			} else {
				termPredefinedButton.isHidden = true
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
	}
	
	// MARK: - categoryListVCHDelegate functions
	
	func shouldReloadTable() {
		tableView.reloadData()
	}
	
	func shouldSegueToPreexistingCategory(category: Category2) {
		
		self.segueCategory = category
		
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	func shouldSegueToNewCategory() {
		// new empty category will have id = -1
		self.segueCategory = Category2()
		
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueCategory:
			let vc = segue.destination as? CategoryVC
			vc?.categoryVCH.category = segueCategory
		default:
			print ("fatal error did not find a matching segue in prepar funtion of categoryListVC")
		}
		
	}
	
	@IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func termPredefinedButtonAction(_ sender: UIButton) {
		let ac = UIAlertController(title: "Locked Term", message: "This is a predefined term, and you can't change it's standard categories. However, you can select any of the \"My Categories\"", preferredStyle: .alert)
		let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
		
		ac.addAction(okay)
		
		self.present(ac, animated: true, completion: nil)
	}
	
	
	/*
	// MARK: Delegate Functions for categoryHomeDelegate
	
	func pressedInfoButtonOnStandardCategory() {
		let aC = UIAlertController(title: "Standard Category", message: "This is a predefined category and you cannot edit it. However, you can add your own categories and edit or delete them.", preferredStyle: .alert)
		
		let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
		aC.addAction(okay)
		self.present(aC, animated: true, completion: nil)
	}
	
	func pressedEditButtonOnCustomCategory(category: Category2) {
		self.categoryEditMode = .edit
		self.segueCategory = category
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	func pressedDeleteButtonOnCustomCatetory(category: Category2) {
		self.categoryEditMode = .delete
		self.segueCategory = category
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	func addACategory() {
		self.categoryEditMode = .add
		performSegue(withIdentifier: myConstants.segueCategory, sender: self)
	}
	
	// END with delegate functions
	*/
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	
	
	
	
	let categoryC = CategoryController()	// here so i can use it to check for duplicate category name the user enters
	
	let utilities = Utilities() 			// here so I can clean up the user text entry
	
	let dIC = DItemController3()
	
	override func viewDidLoad() {
	super.viewDidLoad()
	// Do any additional setup after loading the view.
	tableView.dataSource = categoryListVCH
	tableView.delegate = categoryHomeVCH
	tableView.tableFooterView = UIView()
	
	categoryHomeVCH.delegate = self
	
	addCustomCategoryButton.layer.cornerRadius = myConstants.button_cornerRadius
	}
	
	override func viewWillAppear(_ animated: Bool) {
	updateDisplay()
	tableView.reloadData()
	//if any alerts are showing, need to dismiss them
	
	}
	
	func updateDisplay() {
	
	// set the message label
	
	if categoryHomeVCH.categoryListMode == .selectCategory {
	messageLabel.text = "Select A Category To View"
	
	} else {
	let dItem = dIC.getDItem(itemID: categoryHomeVCH.itemID)
	
	messageLabel.text = "Select categories for the term: \(dItem.term)"
	}
	
	}
	
	//MARK: Start Delegate functions for CategoryHomeVCHDelegate
	func pressedInfoButtonOnStandardCategory() {
	let aC = UIAlertController(title: "Standard Category", message: "This is a built in category and you cannot edit it. However, you can add your own custom categories and edit or delete them.", preferredStyle: .alert)
	
	let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
	aC.addAction(okay)
	self.present(aC, animated: true, completion: nil)
	}
	
	func pressedEditButtonOnCustomCategory(categoryID: Int, name: String) {
	
	let alertC = UIAlertController(title: "Edit Category Name", message: "", preferredStyle: .alert)
	
	alertC.addTextField(configurationHandler: nil)
	alertC.textFields![0].text = name
	let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
	//place holder for now
	self.tableView.reloadData() //to get rid of swipe buttons
	}
	
	let okay = UIAlertAction(title: "OK", style: .default) { (_) in
	// enable update here
	// if the name user entered in to the field is the same as original then just do nothing
	
	if let enteredText = alertC.textFields?[0].text {
	
	// check for blank entry
	if self.utilities.isBlank(string: enteredText) {
	// do nothing
	self.tableView.reloadData() // to get rid of the swipe buttons
	return
	}
	
	// check for same entry as original
	// clean the entry of any preceding or trailing spaces
	let cleanedEntry = self.utilities.cleanString(string: enteredText)
	
	if name == cleanedEntry {
	// do nothing as the user entered the same name as the original or did not change the original
	self.tableView.reloadData() // to get rid of the swipe buttons
	return
	}
	// here can CHANGE the category name
	self.categoryHomeVCH.changeCategoryName(categoryID: categoryID, nameTo: cleanedEntry)
	
	}
	// if this entered name is the same name as the current name then don't do anything
	self.tableView.reloadData() // to get rid of the swipe buttons
	}
	
	alertC.addAction(okay)
	alertC.addAction(cancel)
	self.present(alertC, animated: true, completion: nil)
	}
	
	func requestDeleteCategory(categoryID: Int, name: String) {
	
	let title = "Delete \"\(name)?\""
	
	let alertC = UIAlertController(title: title, message: "Are you sure you want to delete this category?", preferredStyle: .alert)
	let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
	self.categoryHomeVCH.deleteCategory(categoryID: categoryID)
	}
	let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
	self.tableView.reloadData()	// doing this so that swipe action goes away
	}
	
	alertC.addAction(delete)
	alertC.addAction(cancel)
	
	self.present(alertC, animated: true, completion: nil)
	}
	
	func shouldReloadTable() {
	tableView.reloadData()
	updateDisplay()
	}
	
	func itemCategoryChanged() {
	//reload the table view to update the item's new categories
	tableView.reloadData()
	}
	
	//MARK: End Delegate functions for CategoryHomeVCHDelegate
	
	private func addNewCustomCategory () {
	
	let alertC = UIAlertController(title: "New Category", message: "Add a new category", preferredStyle: .alert)
	
	alertC.addTextField(configurationHandler: nil)
	
	let utilities = Utilities()
	
	let okay = UIAlertAction(title: "OK", style: .default) { [self] (_) in
	if let inputText = alertC.textFields![0].text {
	
	
	
	let cleanText = utilities.cleanString(string: inputText)
	if cleanText != "" {
	
	//need to check if this name is a duplicate
	if categoryC.customCatetoryNameIsUnique(name: cleanText) {
	//this is not a duplicate, may save this name
	self.categoryHomeVCH.addCustomCategoryName(name: cleanText)
	
	} else {
	self.showDuplicateCategoryAlert(name: cleanText)
	}
	}
	}
	}
	
	let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
	//just cancel
	}
	
	alertC.addAction(okay)
	alertC.addAction(cancel)
	present(alertC, animated: true, completion: nil)
	}
	
	private func showDuplicateCategoryAlert (name: String) {
	let alertDuplicate = UIAlertController(title: "Opps! Duplicate Category", message: "The category \"\(name)\" already exists.\nPlease use a different name", preferredStyle: .alert)
	let okayDuplicate = UIAlertAction(title: "Ok", style: .default, handler: nil)
	alertDuplicate.addAction(okayDuplicate)
	self.present(alertDuplicate, animated: true, completion: nil)
	}
	
	@IBAction func addCustomCategoryButtonAction(_ sender: UIButton) {
	self.addNewCustomCategory()
	}
	*/
}
