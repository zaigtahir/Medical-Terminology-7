//
//  CategoryVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/28/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

class CategoryVCH {
	
	var categoryEditMode = CategoryEditMode.add	// just a default setting, need to set via prepare segue
	
	var affectedCategory: Category2! 	// set when making the segue for edit/add function to uses
	
	// handle delete category, edit, and add category functions
	// the underlying category controller will perform these functions and it will send out notifications of the events
	
	
}


