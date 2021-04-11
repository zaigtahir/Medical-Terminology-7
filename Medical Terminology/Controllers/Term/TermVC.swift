//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController, TermAudioDelegate, TermVCHDelegate {
	
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
	
	// store term here so it can be used to play audio as a class function
	private var term : Term!
	
	// controllers
	private let tc = TermController()
	private let cc = CategoryController2()
	
	// keeping these vc as a class varialbe so I can dismiss them through protocol functions
	private var singleLineInputVC : SingleLineInputVC!
	private var multiLineInputVC : MultiLineInputVC!
	

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		termVCH.delegate = self
		
		updateDisplay()
	}
	
	func updateDisplay () {
		
		term = tc.getTerm(termID: termVCH.termID)
		
		print ("in TermVC. For testing setting term to be not isStandard")
		
		term.isStandard = false
		
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
			
			if term.myNotes == "" {
				myNotesLabel.text = "none available"
			} else {
				myNotesLabel.text = term.myNotes
			}
			
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
			
		case myConstants.segueSingleLineInput:
			
			singleLineInputVC = segue.destination as? SingleLineInputVC
			singleLineInputVC.textInputVCH.fieldTitle = "TERM NAME"
			singleLineInputVC.textInputVCH.initialText = term.name
			singleLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
			singleLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-"
			singleLineInputVC.textInputVCH.minLength = 1
			singleLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermName
			singleLineInputVC.textInputVCH.propertyReference = .name
			singleLineInputVC.delegate = termVCH
			
		case myConstants.segueMultiLineInput:
			
			multiLineInputVC = segue.destination as? MultiLineInputVC
			
			switch termVCH.propertyReference  {
			
			case .definition:
				
				multiLineInputVC.textInputVCH.fieldTitle = "DEFINITION"
				multiLineInputVC.textInputVCH.initialText = term.definition
				multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
				multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
				multiLineInputVC.textInputVCH.minLength = 0
				multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermDefinition
				multiLineInputVC.textInputVCH.propertyReference = .definition
				multiLineInputVC.delegate = termVCH
				
			case .example:
				
				multiLineInputVC.textInputVCH.fieldTitle = "EXAMPLE"
				multiLineInputVC.textInputVCH.initialText = term.example
				multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ."
				multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/.-\n\t"
				multiLineInputVC.textInputVCH.minLength = 0
				multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthTermExample
				multiLineInputVC.textInputVCH.propertyReference = .example
				multiLineInputVC.delegate = termVCH
				
			default:
				
				multiLineInputVC.textInputVCH.fieldTitle = "MY NOTES"
				multiLineInputVC.textInputVCH.initialText = term.myNotes
				multiLineInputVC.textInputVCH.validationPrompt = "You may use letters, numbers and the following characters: ! , ( ) / ? ."
				multiLineInputVC.textInputVCH.allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz 0123456789 !,()/?.-\n\t"
				multiLineInputVC.textInputVCH.minLength = 0
				multiLineInputVC.textInputVCH.maxLength = myConstants.maxLengthMyNotes
				multiLineInputVC.textInputVCH.propertyReference = .myNotes
				multiLineInputVC.delegate = termVCH
				
			}
			
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
	
	func shouldDisplayDuplicateTermNameAlert() {
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
