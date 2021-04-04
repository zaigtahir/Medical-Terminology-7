//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController {
	
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var definitionLabel: UILabel!
	
	@IBOutlet weak var exampleLabel: UILabel!
	
	@IBOutlet weak var myNotesLabel: UILabel!
	
	@IBOutlet weak var leftButton: UIBarButtonItem!
	
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak var speakerButton: UIButton!
	
	@IBOutlet weak var favoriteButton: ZUIToggleButton!
	
	@IBOutlet weak var deleteTermButton: UIButton!
	
	let termVCH = TermVCH()
	
	private var term = Term()
	
	private let tc = TermController()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		term = tc.getTerm(termID: termVCH.termID)
		
		updateView()
	}
	
	func updateView () {
		
		speakerButton.isEnabled = term.isAudioFilePresent()
		
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
	
	@IBAction func isFavoriteButtonAction(_ sender: Any) {
		
		switch termVCH.displayMode {
		case .add:
			// just allow local toggling
			return
		default:
			print("saving favorite state")
			tc.setFavoriteStatusPostNotification(categoryID: termVCH.currentCategoryID, termID: termVCH.termID, isFavorite: favoriteButton.isOn)		}
		
	}
}
