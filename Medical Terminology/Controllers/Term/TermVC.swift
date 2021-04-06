//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController, TermAudioDelegate {
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var definitionLabel: UILabel!
	
	@IBOutlet weak var exampleLabel: UILabel!
	
	@IBOutlet weak var myNotesLabel: UILabel!
	
	@IBOutlet weak var leftButton: UIBarButtonItem!
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak var playAudioButton: UIButton!
	
	@IBOutlet weak var favoriteButton: ZUIToggleButton!
	
	@IBOutlet weak var deleteTermButton: UIButton!
	
	@IBOutlet weak var categoriesListTextView: UITextView!
	
	let termVCH = TermVCH()
	
	private var term : Term!	// store term here so it can be used to play audio as a class function
	
	private let tc = TermController()
	
	private let cc = CategoryController2()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		term = tc.getTerm(termID: termVCH.termID)
		
		updateView()
	}
	
	func updateView () {
		
		playAudioButton.isEnabled = term.isAudioFilePresent()
		
		// even if no term exists yet ( as a new term will be id = 0, this will result in result = false
		
		let termIsFavorite  = tc.getFavoriteStatus(categoryID: 1, termID: term.termID)
		
		favoriteButton.isOn = termIsFavorite
		
		// make list of categories
		let categoryIDs = tc.getTermCategoryIDs(termID: term.termID)
		var categoryList = ""
		
		for id in categoryIDs {
			if (id != myConstants.dbCategoryMyTermsID) && (id != myConstants.dbCategoryAllTermsID) {
				// note not including id 1 = All terms and 2 = My Terms
				
				let category = cc.getCategory(categoryID: id)
				categoryList.append("\(category.name)\n")
				
			}
		}
		
		switch termVCH.displayMode {
		
		case .view:
			nameLabel.text = term.name
			definitionLabel.text = term.definition
			
			if term.example == "" {
				exampleLabel.text = "none available"
			} else {
				exampleLabel.text = term.example
			}
			
			myNotesLabel.text = "none available"
			
			leftButton.title = "Done"
			leftButton.isEnabled  = true
			
			cancelButton.isEnabled = false
			
			deleteTermButton.isEnabled = !term.isStandard
			
			categoriesListTextView.text = categoryList
			
		case .edit:
			nameLabel.text = term.name
			definitionLabel.text = term.definition
			
			if term.example == "" {
				exampleLabel.text = "none available"
			} else {
				exampleLabel.text = term.example
			}
			
			myNotesLabel.text = "none available"
			
			leftButton.title = "Save"
			leftButton.isEnabled = termVCH.isReadyToSaveTerm ? true : false
			cancelButton.isEnabled = true
			
			deleteTermButton.isEnabled = !term.isStandard
			
			categoriesListTextView.text = categoryList
			
			
		default:
			// add (case delete is not used)
			nameLabel.text = "(required)"
			definitionLabel.text = "(optional)"
			exampleLabel.text = "(optional)"
			myNotesLabel.text = "(optional)"
			
			leftButton.title = "Save"
			leftButton.isEnabled = termVCH.isReadyToSaveTerm ? true : false
			cancelButton.isEnabled = true
			
			deleteTermButton.isEnabled = false
			
			categoriesListTextView.text = "Your new term will automatically be added to \"My Terms\" category in addition to any others you assign it to."
			
		}
		
	}
	
	// MARK: -Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueAssignCategory:
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			vc.categoryHomeVCH.displayMode = .assignCategory
			vc.categoryHomeVCH.termID = termVCH.termID
			
		default:
			print("fatal error, no segue identifier found in prepare TermVC")
		}
	}
	
	// MARK: - TermAudioDelegate functions
	func termAudioStartedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
	}
	
	func termAudioStoppedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
	}
	
	@IBAction func cancelButtonAction(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func leftButtonAction(_ sender: Any) {
		
		switch termVCH.displayMode {
		
		case .view:
			self.dismiss(animated: true, completion: nil)
		default:
			print ("take save action!")
		}
		
	}
	
	@IBAction func isFavoriteButtonAction(_ sender: ZUIToggleButton) {
		
		favoriteButton.isOn = !favoriteButton.isOn
		
		switch termVCH.displayMode {
		
		// toggle the button image
		case .add:
			// just allow local toggling
			return
			
		default:
			
			// Note, can't use my button's isOn property here to check as it is not set yet as action triggers before it is set/unset
			
			let favoriteState  = tc.getFavoriteStatus(categoryID: termVCH.currentCategoryID, termID: term.termID)
			tc.setFavoriteStatusPN(categoryID: termVCH.currentCategoryID, termID: termVCH.termID, isFavorite: !favoriteState)		}
	}
	
	@IBAction func playAudioButtonAction(_ sender: UIButton) {
		
		term = tc.getTerm(termID: termVCH.termID)
		term.delegate = self
		term.playAudio()
		
	}
	
}
