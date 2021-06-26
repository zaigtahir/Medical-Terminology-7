//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController, TermAudioDelegate, TermVCHDelegate {
	@IBOutlet weak var nameTitleLabel: UILabel!
	@IBOutlet weak var headerImage: UIImageView!
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
	
	// controllers
	private let tcTB = TermControllerTB()
	private let cc = CategoryController()
	private let tu = TextUtilities()
	
	// keeping these vc as a class varialbe so I can dismiss them through protocol functions
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		termVCH.delegate = self
		
		updateDisplay()
	}
	
	// MARK: - updateDisplay
	
	func updateDisplay () {
		/*
		
		Format save/cancel button
		If this is a new term:
		term name OR definition name is empty: Left button = save.DISABLED, cancel.ENABLED
		term name AND definition name is filled: Left button = save.ENABLED, cancel.ENABLED
		
		if this is not a new term:
		there are no edits: left button = Done.ENABLED, cancel.ENABLED
		there are edits:
		term name OR definition name is empty: Left button = save.DISABLED, cancel.ENABLED
		term name AND definition name is filled: Left button = save.ENABLED, cancel.ENABLED
		
		*/
		
		playAudioButton.isEnabled = termVCH.editedTerm.isAudioFilePresent()
		
		favoriteButton.isOn = termVCH.editedTerm.isFavorite
		
		cancelButton.isEnabled = true
		
		fillFields()
		
		if termVCH.editedTerm.termID == -1 {
			// this is a new term
			leftButton.title = "Save"
			leftButton.isEnabled =  termVCH.editedTerm.name  != "" && termVCH.editedTerm.definition != ""
			self.title = "Add New Term"
			headerImage.image = myTheme.imageHeaderAdd
			
			nameEditButton.isHidden = false
			exampleEditButton.isHidden = false
			definitionEditButton.isHidden = false
			myNotesEditButton.isHidden = false
			
		} else {
			
			// this is not a new term
			if termVCH.termWasEdited() {
				// term is edited, not saved yet
				leftButton.title = "Save"
				leftButton.isEnabled =  termVCH.editedTerm.name  != "" && termVCH.editedTerm.definition != ""
				
			} else {
				// term is not editied yet
				leftButton.title = "Done"
				leftButton.isEnabled = true
			}
			
			// set title and header image
			if termVCH.editedTerm.isStandard {
				self.title = "Predefined Term"
				deleteTermButton.tintColor = myTheme.colorButtonDisabledTint
				nameEditButton.isHidden = true
				definitionEditButton.isHidden = true
				exampleEditButton.isHidden = true
				myNotesEditButton.isHidden = false
				
			} else {
				self.title = "My Term"
				nameTitleLabel.text = "MY TERM"
				deleteTermButton.tintColor = myTheme.colorDestructive
				nameEditButton.isHidden = false
				exampleEditButton.isHidden = false
				definitionEditButton.isHidden = false
				myNotesEditButton.isHidden = false
				
			}
		}

	}
	
	private func fillFields () {
		
		// MARK: fill fields
		
		if termVCH.editedTerm.name == "" {
			nameLabel.text = "New Name"
		} else {
			nameLabel.text = termVCH.editedTerm.name
		}
		
		if termVCH.editedTerm.definition == "" {
			definitionLabel.text = "(required)"
		} else {
			definitionLabel.text = termVCH.editedTerm.definition
		}
		
		// MARK: change the other optional fields like this
		
		if termVCH.editedTerm.example == "" {
			
			if termVCH.editedTerm.termID == -1 {
				exampleLabel.text = "(optional)"
			} else {
				exampleLabel.text = "No example available"
			}
			
		}  else {
			exampleLabel.text = termVCH.editedTerm.example
		}
		
		
		if termVCH.editedTerm.myNotes == ""
		{
			
			if termVCH.editedTerm.termID == -1 {
				myNotesLabel.text = "(optional)"
			} else {
				myNotesLabel.text = "No notes available"
			}
			
			
		} else {
			myNotesLabel.text = termVCH.editedTerm.myNotes
		}
		
		// MARK: category count will never be 0
		
		categoriesListTextView.text = termVCH.getCategoryNamesText()
		
	}
	
	// MARK: - Prepare Segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		termVCH.prepare(for: segue, sender: sender)
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
		if termVCH.editedTerm.termID == -1 {
			termVCH.saveNewTerm()
		}
		// prob change to POP
		self.dismiss(animated: true, completion: nil)
		
	}
	
	// MARK: - TermVCH delegate functions
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func duplicateTermName() {
		let ac = UIAlertController(title: "Opps!", message: "There is already a term with that name. Please choose a different name.", preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .cancel, handler: .none)
		
		ac.addAction(ok)
		
		self.present(ac, animated: true, completion: .none)
		
	}
	
	@IBAction func isFavoriteButtonAction(_ sender: ZUIToggleButton) {
		
		favoriteButton.isOn = !favoriteButton.isOn
		
		termVCH.editedTerm.isFavorite.toggle()
	}
	
	@IBAction func playAudioButtonAction(_ sender: UIButton) {
		
		termVCH.editedTerm.delegate = self
		termVCH.editedTerm.playAudio()
	}
	
	@IBAction func definitionEditButtonAction(_ sender: Any) {
		termVCH.propertyReference = .definition
		performSegue(withIdentifier: myConstants.segueMultiLineInput, sender: self)
	}
	
	@IBAction func exampleEditButtonAction(_ sender: Any) {
		termVCH.propertyReference = .example
		performSegue(withIdentifier: myConstants.segueMultiLineInput, sender: self)
	}
	
	@IBAction func myNotesEditButtonAction(_ sender: Any) {
		termVCH.propertyReference  = .myNotes
		performSegue(withIdentifier: myConstants.segueMultiLineInput, sender: self)
	}
	
	@IBAction func deleteTermButtonAction(_ sender: Any) {
		
		switch termVCH.editedTerm.isStandard {
		
		case true:
			
			let ac = UIAlertController(title: "Predefined Term", message: "This is a predefined term and can not be deleted. Only terms you create may be deleted.", preferredStyle: .alert)
			
			let okay = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
				return
			}
			
			ac.addAction(okay)
			present(ac, animated: true, completion: nil)
		
		case false:
			
			let ac = UIAlertController(title: "Delete This Term?", message: "Are you sure you want to delete this term from ALL categories?", preferredStyle: .alert)
			
			let delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
				self.tcTB.deleteTermPN(termID: self.termVCH.editedTerm.termID)
				self.navigationController?.dismiss(animated: true, completion: nil)
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
				return
			}
			
			ac.addAction(cancel)
			ac.addAction(delete)
			present(ac, animated: true, completion: nil)
		}

	}
	
}
