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
	
	let termVCH = TermVCH()
	
	private var term = Term()
	private let tc = TermController()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		term = tc.getTerm(termID: termVCH.termID)
		
		updateView()
	}
	
	func updateView () {
		
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
			
			
		default:
			// add (case delete is not used)
			nameLabel.text = "(required)"
			definitionLabel.text = "(optional)"
			exampleLabel.text = "(optional)"
			myNotesLabel.text = "(optional)"
			
			leftButton.title = "Save"
			leftButton.isEnabled = termVCH.isReadyToSaveTerm ? true : false
			cancelButton.isEnabled = true
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
	
}
