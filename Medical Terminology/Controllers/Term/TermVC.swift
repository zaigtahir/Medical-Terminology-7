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
	private let tc = TermController()
	private let cc = CategoryController2()
	private let tu = TextUtilities()
	
	// keeping these vc as a class varialbe so I can dismiss them through protocol functions
	private var singleLineInputVC : SingleLineInputVC!
	private var multiLineInputVC : MultiLineInputVC!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		termVCH.delegate = self
		
		updateDisplay()
	}
	
	// MARK: - updateDisplay
	
	func updateDisplay () {
		
		
		/*
		If term is standard
		DONE |  CANCEL: disable
		Hide edit buttons for name, definition, example
		Show edit buttons for my notes, categories
		
		If the term is NOT standard, and IS NEW
		SAVE: enable if name and definition are not blank, otherwise disable
		CANCEL: enable
		Show and enable all the edit buttons
		
		If the term is NOT standard and IS NOT NEW
		DONE | CANCEL: disable
		Show and enable all the edit buttons
		*/
		
		
		// MARK: update buttons and titles
		
		
		playAudioButton.isEnabled = termVCH.term.isAudioFilePresent()
		
		
		if termVCH.term.isStandard {
			// term is standard
			self.title = "Term Details"
			nameTitleLabel.text = "PREDEFINED TERM"
			
			leftButton.title = "Done"
			cancelButton.isEnabled = false
			
			deleteTermButton.isEnabled = false
			
			nameEditButton.isHidden = true
			definitionEditButton.isHidden = true
			exampleEditButton.isHidden = true
			myNotesEditButton.isHidden = false
			
		} else {
			// term is not standard
			nameTitleLabel.text = "MY TERM"
			nameEditButton.isHidden = false
			exampleEditButton.isHidden = false
			definitionEditButton.isHidden = false
			myNotesEditButton.isHidden = false
			
			if termVCH.term.termID == -1 {
				// term is new
				self.title = "Add New Term"
				headerImage.image = myTheme.imageHeaderAdd
				leftButton.title = "Save"
				
				if (termVCH.term.name != "" && termVCH.term.definition != "") {
					leftButton.isEnabled = true
				} else {
					leftButton.isEnabled = false
				}
				
				cancelButton.isEnabled = true
				deleteTermButton.isEnabled = false
				
				
			} else {
				// term is not new
				self.title = "My Term Details"
				
				leftButton.title = "Done"
				cancelButton.isEnabled = false
				
				deleteTermButton.isEnabled = true
				
			}
		}
		
		
		// MARK: fill fields
		
		if termVCH.term.name == "" {
			nameLabel.text = "New Name"
		} else {
			nameLabel.text = termVCH.term.name
		}
		
		if termVCH.term.definition == "" {
			definitionLabel.text = "(required)"
		} else {
			definitionLabel.text = termVCH.term.definition
		}
		
		// MARK: change the other optional fields like this
		
		if termVCH.term.example == "" {
			
			if termVCH.term.termID == -1 {
				exampleLabel.text = "(optional)"
			} else {
				exampleLabel.text = "No example available"
			}
			
		}  else {
			exampleLabel.text = termVCH.term.example
		}
		
		
		if termVCH.term.myNotes == ""
		{
			
			if termVCH.term.termID == -1 {
				myNotesLabel.text = "(optional)"
			} else {
				myNotesLabel.text = "No notes available"
			}
			
			
		} else {
			myNotesLabel.text = termVCH.term.myNotes
		}
		
		// MARK: category count will never be 0
		
		categoriesListTextView.text = termVCH.getCategoryNamesText()
		
	}
	
	// MARK: - Prepare Segue
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueAssignCategory:
			prepareAssignCategorySegue(for: segue)
			
		case myConstants.segueSingleLineInput:
			
			prepareEditNameSegue(for: segue)
			
		case myConstants.segueMultiLineInput:
			
			switch termVCH.propertyReference  {
			
			case .definition:
				
				prepareEditDefinitionSegue(for: segue)
				
			case .example:
				
				prepareEditExampleSegue(for: segue)
				
			case .myNotes:
				
				prepareEditMyNotesSegue(for: segue)
				
			default:
				print("fatal error, no segue identifier found in prepare TermVC")
			}
			
		default:
			print("fatal error, no segue identifier found in prepare TermVC")
			
		}
	}
	
	private func prepareAssignCategorySegue (for segue: UIStoryboardSegue) {
		
		let nc = segue.destination as! UINavigationController
		let vc = nc.topViewController as! CategoryListVC
		
		vc.categoryListVCH.categoryListMode = .assignCategory
		vc.categoryListVCH.currentCategoryID = termVCH.currentCategoryID
		vc.categoryListVCH.term = termVCH.term
		
	}
	
	private func prepareEditNameSegue (for segue: UIStoryboardSegue) {
		singleLineInputVC = segue.destination as? SingleLineInputVC
		singleLineInputVC.textInputVCH.fieldTitle = "TERM NAME"
		singleLineInputVC.textInputVCH.initialText = termVCH.term.name
		singleLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		singleLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
		singleLineInputVC.textInputVCH.minLength = 1
		singleLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermName
		singleLineInputVC.textInputVCH.propertyReference = .name
		
		singleLineInputVC.delegate = termVCH
	}
	
	private func prepareEditDefinitionSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "DEFINITION"
		multiLineInputVC.textInputVCH.initialText = termVCH.term.definition
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermDefinition
		multiLineInputVC.textInputVCH.propertyReference = .definition
		multiLineInputVC.delegate = termVCH
	}
	
	private func prepareEditExampleSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "EXAMPLE"
		multiLineInputVC.textInputVCH.initialText = termVCH.term.example
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermExample
		multiLineInputVC.textInputVCH.propertyReference = .example
		multiLineInputVC.delegate = termVCH
	}
	
	private func prepareEditMyNotesSegue (for segue: UIStoryboardSegue) {
		multiLineInputVC = segue.destination as? MultiLineInputVC
		multiLineInputVC.textInputVCH.fieldTitle = "MY NOTES"
		multiLineInputVC.textInputVCH.initialText = termVCH.term.myNotes
		multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ? ."
		multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/?.-\n\t"
		multiLineInputVC.textInputVCH.minLength = 0
		multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthMyNotes
		multiLineInputVC.textInputVCH.propertyReference = .myNotes
		multiLineInputVC.delegate = termVCH
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
		if termVCH.term.termID == -1 {
			termVCH.saveTerm()
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
	
	func shouldDismissTextInputVC() {
		multiLineInputVC?.navigationController?.popViewController(animated: true)
		singleLineInputVC?.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func isFavoriteButtonAction(_ sender: ZUIToggleButton) {
		
		favoriteButton.isOn = !favoriteButton.isOn
		
		if termVCH.term.termID == -1 {
			
			termVCH.newTermFavoriteStatus.toggle()
			
		} else {
			
			let favoriteState  = tc.getFavoriteStatus(categoryID: termVCH.currentCategoryID, termID: termVCH.term.termID)
			tc.setFavoriteStatusPN(categoryID: termVCH.currentCategoryID, termID: termVCH.term.termID, isFavorite: !favoriteState)
		}
	}
	
	@IBAction func playAudioButtonAction(_ sender: UIButton) {
		
		termVCH.term.delegate = self
		termVCH.term.playAudio()
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
	
}
