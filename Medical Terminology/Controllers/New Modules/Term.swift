//
//  Term.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/23/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class Term {
	var termID: Int = -1
	var name: String = "default"
	var definition: String = "default"
	var example: String = "default"
	var secondCategoryID : Int = -1
	var audioFile: String?
	var isStandard: Bool = true
	
	init () {
	
	}
	
	convenience init(termID: Int, name: String, definition: String, example: String, secondCategoryID: Int, audioFile: String?, isStandard: Bool) {
		
		self.init()
		self.termID = termID
		self.name = name
		self.definition = definition
		self.example = example
		self.secondCategoryID = secondCategoryID
		self.audioFile = audioFile
		self.isStandard = isStandard
	}
	
	func printTerm() {
		print("term name: \(self.name)")
		print("term ID: \(self.termID)")
	}
}
