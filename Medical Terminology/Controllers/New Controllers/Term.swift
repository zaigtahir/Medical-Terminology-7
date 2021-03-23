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
	var audioFile: String?
	var isFavorite: Bool = false
	var isMyTerm: Bool = false
	
	init () {
	
	}
	
	convenience init(termID: Int, name: String, definition: String, audioFile: String?, isFavorite: Bool, isMyTerm: Bool) {
		
		self.init()
		self.termID = termID
		self.name = name
		self.definition = definition
		self.example = example
		self.audioFile = audioFile
		self.isFavorite = isFavorite
		self.isMyTerm = isMyTerm
	}
	
	func printTerm() {
		print("term name: \(self.name)")
		print("term ID: \(self.termID)")
	}
}
