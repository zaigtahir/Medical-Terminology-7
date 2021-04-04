//
//  TermVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class TermVCH {
	
	var termID : Int!
	
	var currentCategoryID : Int!
	
	var displayMode = DisplayMode.view
	
	///set this to true when the user is in edit/add mode and the data is valid to save as a term
	var isReadyToSaveTerm = false
}
