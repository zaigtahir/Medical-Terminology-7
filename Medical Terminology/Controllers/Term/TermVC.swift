//
//  TermVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class TermVC: UIViewController {
	
	var term : Term!
	
	var currentCategoryID : Int!
	
	var displayMode = DisplayMode.view
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var definitionLabel: UILabel!
	
	@IBOutlet weak var exampleLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if displayMode == .view {
			nameLabel.text = "Name (required)"
			definitionLabel.text = "Definition (required)"
			exampleLabel.text = "Examle (optional)"
		} else {
			nameLabel.text = term.name
			definitionLabel.text = term.definition
			exampleLabel.text = term.example
		}
		
	}
	
	@IBAction func assignCategoryButton(_ sender: UIButton) {
	}
	@IBAction func playAudioButton(_ sender: UIButton) {
	}
	@IBAction func isFavoriteButton(_ sender: UIButton) {
	}
	@IBAction func deleteButton(_ sender: UIButton) {
	}
	
	

	
	

}
