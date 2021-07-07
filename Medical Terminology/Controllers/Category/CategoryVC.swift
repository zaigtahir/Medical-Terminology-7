//
//  CategoryVC2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/13/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController, CategoryVCHDelegate {
	
	@IBOutlet weak var headerImage: UIImageView!
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak var leftButton: UIBarButtonItem!
	
	@IBOutlet weak var deleteCategoryButton: ZUIRoundedButton!
	
	@IBOutlet weak var nameTitleLabel: UILabel!
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var nameEditButton: UIButton!
	
	@IBOutlet weak var descriptionLabel: UILabel!
	
	@IBOutlet weak var descriptionEditButton: UIButton!
	
	@IBOutlet weak var assignedTermsLabel: UILabel!
	
	@IBOutlet weak var overallAllProgressLabel: UILabel!
	
	@IBOutlet weak var flashcardProgressLabel: UILabel!
	
	@IBOutlet weak var learnedProgressLabel: UILabel!
	
	@IBOutlet weak var testProgressLabel: UILabel!
	@IBOutlet weak var circleBarViewTotalProgress: UIView!
	@IBOutlet weak var circleBarViewFlashcardsProgress: UIView!
	@IBOutlet weak var circleBarViewLearnedProgress: UIView!
	@IBOutlet weak var circleBarViewTestProgress: UIView!
	
	var categoryVCH = CategoryVCH()
	
	private let cc = CategoryController()
	private let tcTB = TermControllerTB()
	private let tu = TextUtilities()
	private let utilities = Utilities()
	
	private var progressBarTotal : CircularBar!
	private var progressBarFlashcards : CircularBar!
	private var progressBarLearning: CircularBar!
	private var progressBarTest : CircularBar!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		updateDisplay()
		
		//navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
		
		self.navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "My Title", style: .plain, target: nil, action: nil)
		
		
		categoryVCH.delegate = self
		
		// test out done numbers
		
		let progress = cc.getDoneCounts(categoryID: categoryVCH.editedCategory.categoryID)
		
		let totalCount = tcTB.getTermCount(categoryIDs: [categoryVCH.editedCategory.categoryID], showFavoritesOnly: false)
		
		assignedTermsLabel.text = ("\(totalCount)")
		
		overallAllProgressLabel.text = ("Total: \(utilities.getPercentage(number: progress.totalDone, numberTotal: totalCount * 4))% done")
		
		flashcardProgressLabel.text =  ("Flashcards: \(utilities.getPercentage(number: progress.fcDone, numberTotal: totalCount))% done")
		
		learnedProgressLabel.text = ("Learning: \(utilities.getPercentage(number: progress.lnDone, numberTotal: totalCount))% done")
		
		testProgressLabel.text = ("Test: \(utilities.getPercentage(number: progress.anDone, numberTotal: totalCount * 2))% done")
		
		// format the progress bar
		let foregroundColor = myTheme.colorProgressPbForeground?.cgColor
		let backgroundColor = myTheme.colorProgressPbBackground.cgColor
		let fillColor = myTheme.colorProgressPbFillcolor?.cgColor
		
		
		// format total progress bar
		progressBarTotal = CircularBar(referenceView: circleBarViewTotalProgress, foregroundColor: foregroundColor!, backgroundColor: backgroundColor, fillColor: fillColor!, lineWidth: 3)
		
		progressBarTotal.setStrokeEnd(partialCount: progress.totalDone, totalCount: totalCount * 4)
		
		// format the flashcard progress bar
		progressBarFlashcards = CircularBar(referenceView: circleBarViewFlashcardsProgress, foregroundColor: foregroundColor!, backgroundColor: backgroundColor, fillColor: fillColor!, lineWidth: 3)
		
		progressBarFlashcards.setStrokeEnd(partialCount: progress.fcDone, totalCount: totalCount)
		
		// format the learned progress bar
		progressBarLearning = CircularBar(referenceView: circleBarViewLearnedProgress, foregroundColor: foregroundColor!, backgroundColor: backgroundColor, fillColor: fillColor!, lineWidth: 3)
		
		progressBarLearning.setStrokeEnd(partialCount: progress.lnDone, totalCount: totalCount)
		
		// format the test progress bar
		progressBarTest = CircularBar(referenceView: circleBarViewTestProgress, foregroundColor: foregroundColor!, backgroundColor: backgroundColor, fillColor: fillColor!, lineWidth: 3)
		
		progressBarTest.setStrokeEnd(partialCount: progress.anDone, totalCount: totalCount)
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	// MARK: - categoryVCH2Delegate
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldAlertDuplicateCategoryName() {
		let ac = UIAlertController(title: "Duplicate Name", message: "This category name already exists, please try a different category name", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: .none)
		ac.addAction(ok)
		present(ac, animated: true, completion: nil)
	}
	
	// MARK: - updateDisplay
	
	func updateDisplay () {
		
		func formatButtons() {
			
			/*
			If the category is edited:
			name is valid: Save.Enabled, Cancel.Enabled
			name is not valid: Save.Disabled, Cancel.Enabled
			
			if the category is NOT edited:
			new category: Save.Disabled, Cancel.Enabled
			not new category: Done.Enabled, Cancel.Disabled
			
			*/
			
			
			if categoryVCH.categoryWasEdited() {
				
				if categoryVCH.editedCategory.name != "" {
					// both required fields have data
					leftButton.title = "Save"
					leftButton.isEnabled = true
					cancelButton.isEnabled = true
				} else {
					leftButton.title = "Save"
					leftButton.isEnabled = false
					cancelButton.isEnabled = true
				}
				
			} else {
				
				// no edits have been made yet
				if categoryVCH.editedCategory.categoryID == -1 {
					// the category is new
					leftButton.title = "Save"
					leftButton.isEnabled = false
					cancelButton.isEnabled = true
				} else {
					leftButton.title = "Done"
					leftButton.isEnabled = true
					cancelButton.isEnabled = false
				}
			}
			
			if categoryVCH.editedCategory.isStandard {
				
				
				nameEditButton.isHidden = true
				descriptionEditButton.isHidden = false
			} else {
				
				nameEditButton.isHidden = false
				descriptionEditButton.isHidden = false
			}
			
			// format the delete icon
			if categoryVCH.editedCategory.isStandard {
				deleteCategoryButton.isEnabled = false
			} else {
				if categoryVCH.editedCategory.categoryID == -1 {
					deleteCategoryButton.isEnabled = false
				} else {
					deleteCategoryButton.isEnabled = true
				}
			}
			
		}
		
		func formatFields() {
			
			if categoryVCH.editedCategory.isStandard {
				self.title = "Category"
				nameTitleLabel.text = "Category Name"
			} else {
				nameTitleLabel.text = "My Category Name"
				self.title = "My Category"
			}
			
			if categoryVCH.editedCategory.name == "" {
				
				nameLabel.text = "New Name"
			} else {
				nameLabel.text = categoryVCH.editedCategory.name
			}
			
			if categoryVCH.editedCategory.description == "" {
				
				if categoryVCH.editedCategory.categoryID == -1 {
					descriptionLabel.text = "(optional)"
				} else {
					descriptionLabel.text = "No description available"
				}
				
			} else {
				descriptionLabel.text = categoryVCH.editedCategory.description
			}
			
			if categoryVCH.editedCategory.categoryID == -1 {
				
				headerImage.image = myTheme.imageHeaderAdd
			}
		}
		
		formatButtons()
		
		formatFields()
		
	}
	
	// MARK: - prepare segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		categoryVCH.prepare(for: segue, sender: sender)
	}
	
	@IBAction func leftButtonAction(_ sender: Any) {
		
		/*
		
		if new category, save new category -> show success dialog box -> dismiss
		
		if preexisting category and there are edits -> save edits -> dismiss
		
		if preextisting category and no edits -> just dismiss
		
		*/
		
		if categoryVCH.editedCategory.categoryID == -1 {
			// this is a new term, so save it
			categoryVCH.saveNewCategory()
			updateDisplay()
			
			let ac = UIAlertController(title: "Success!", message: "Your category was saved, and it will show in alphabetical order in the My Categories section.", preferredStyle: .alert)
			
			let ok = UIAlertAction(title: "OK", style: .cancel) {alertAction in
				
				self.navigationController?.popViewController(animated: true)
			}
			
			ac.addAction(ok)
			
			self.present(ac, animated: true, completion: nil)
			
		} else {
			// this is not a new term, so check to see it has been editied
			
			if categoryVCH.categoryWasEdited() {
				
				categoryVCH.updateCategoryPN()
				
				self.navigationController?.popViewController(animated: true)
				
			} else {
				
				self.navigationController?.popViewController(animated: true)
			}
		}
		
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func deleteCategoryButtonAction(_ sender: Any) {
		
		print("to code delete category button")
		
		// only delete a non-standard category
		
		if !categoryVCH.editedCategory.isStandard {
			
			let ac = UIAlertController(title: "Delete Category?", message: "Are you sure you want to delete this category? Just FYI: When you delete a category, no terms will be deleted", preferredStyle: .alert)
			
			let delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
				//self.cc.deleteCategoryPN(categoryID: self.categoryVCH.category.categoryID)
				self.categoryVCH.deleteCategory()
				self.navigationController?.popViewController(animated: true)
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
				self.navigationController?.popViewController(animated: true)
			}
			
			ac.addAction(cancel)
			ac.addAction(delete)
			present(ac, animated: true, completion: nil)
		}
	}
}
