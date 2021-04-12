//
//  TermVCH2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/11/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//


import Foundation
import UIKit

protocol TermVCHDelegate2: AnyObject {
	func shouldUpdateDisplay()
	
	/// dismiss single or multiline input vc
	func shouldDismissTextInputVC()
	func shouldDisplayDuplicateTermNameAlert()
}

class TermVCH2 {
	
	/// Everything will be based on this term. If this termID = -1, this will be considered to be a NEW term that is not saved yet
	var term : Term!
	var newTermFavoriteStatus: Bool!
	
	var currentCategoryID : Int!
	
	var delegate: TermVCHDelegate2?
	
	// controllers
	private let tc = TermController()
	private let cc = CategoryController2()
	
	
	
	
	
}
