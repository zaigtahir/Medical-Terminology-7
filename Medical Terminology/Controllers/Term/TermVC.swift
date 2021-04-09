//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController, TermAudioDelegate, TermVCHDelegate, SingleLineInputDelegate {


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
	
	@IBOutlet weak var nameEditButton: UIButton!
	
	@IBOutlet weak var definitionEditButton: UIButton!
	
	@IBOutlet weak var exampleEditButton: UIButton!
	
	@IBOutlet weak var myNotesEditButton: UIButton!
	
	let termVCH = TermVCH()
	
	private var term : Term!	// store term here so it can be used to play audio as a class function
	
	private let tc = TermController()
	
	private let cc = CategoryController2()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		termVCH.delegate = self
		
		term = tc.getTerm(termID: termVCH.termID)
		
		print ("in TermVC. For testing setting term to be not isStandard")
		term.isStandard = false
		
		updateDisplay()
	}
	
	func updateDisplay () {
		
		playAudioButton.isEnabled = term.isAudioFilePresent()
		
		// even if no term exists yet ( as a new term will be id = 0, this will result in result = false
		
		let termIsFavorite  = tc.getFavoriteStatus(categoryID: 1, termID: term.termID)
		
		favoriteButton.isOn = termIsFavorite
		
		
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
			categoriesListTextView.text = termVCH.getCategoryNamesText()
			
			
			if term.isStandard {
				deleteTermButton.isEnabled = false
				nameEditButton.isHidden = true
				definitionEditButton.isHidden = true
				exampleEditButton.isHidden = true
				myNotesEditButton.isHidden = false
				
			} else {
				deleteTermButton.isEnabled = true
				nameEditButton.isHidden = false
				exampleEditButton.isHidden = false
				definitionEditButton.isHidden = false
				myNotesEditButton.isHidden = false
			}
			
			
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
			
		case myConstants.segueTextInput:
			let vc = segue.destination as! SingleLineInput
			
			vc.fieldTitle = "TERM NAME"
			vc.inputFieldText = term.name
			vc.validationText = "You may use letters, numbers and the following characters: ! , ( ) / ."
			vc.validationAllowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
			vc.inputIsRequired = true
			vc.maxLength = 20
			vc.itemReference = "term name"
			vc.delegate = self
			
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
	
	// MARK: - TermVCH delegate functions
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	// MARK: - SingleLineInputDelegate function
	
	/**
	This function will allow you to save an empty string, so if a blank string should not be saved, need to address that before calling this function
	*/
	func shouldUpdateInformation(inputVC: SingleLineInput, itemReference: String, cleanString: String) {
	
		// won't need to use an item reference here because only the term name will use the SingleLineInputDelegate here
		
		// if there is no change from the original information, just pop the input controller and do nothing
		
		if !inputVC.hasChangedFromOriginal() {
			print ("no change from before, not doing anything")
			return
		}
		
		print ("there was a change! looking to see if this is a duplicate")
		
		// if this is a duplicate term name, show an alert, and do not pop the input controller
		
		print("checking name: \(cleanString)")
		
		// look for a duplicate name in any OTHER row
		if tc.termNameIsUnique(name: cleanString, notIncludingTermID: term.termID) {
			
			tc.updateTermNamePN (termID: term.termID, name: cleanString)
			
			// reload the term from the db to show changes
			self.term = tc.getTerm(termID: self.term.termID)
			
			updateDisplay()
			
			inputVC.navigationController?.popViewController(animated: true)
		
		} else {
			
			let ac = UIAlertController(title: "Hey there!", message: "There is already a term with that name. Please choose a different name.", preferredStyle: .alert)
			let ok = UIAlertAction(title: "OK", style: .cancel, handler: .none)
			
			ac.addAction(ok)
			
			self.present(ac, animated: true, completion: .none)
			
			return
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
