//
//  CategoryController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/8/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

//used to manage categories
class CategoryController {
    
    var categories = [Category]()
    
    /*
	Return a collection of categories from the database
	categoryType = 0	standard, built in
	categoryType = 1	custom
	*/
	func getCategories (categoryType: Int) -> [Category] {
        
        var categories = [Category]()
       
		//note a null value in datatable returned as int is 0
		
		let query = "SELECT * FROM categories WHERE type = \(categoryType)"
        
        if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                let categoryID = Int(resultSet.int(forColumn: "categoryID"))
                let name = resultSet.string(forColumn: "name") ?? ""
                let description = resultSet.string(forColumn: "description") ?? ""
                let type = Int(resultSet.int(forColumn: "type"))
                let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
                
                
                let c = Category(categoryID: categoryID,
                                 name: name,
                                 description: description,
                                 type: type,
                                 displayOrder: displayOrder)
                
                categories.append(c)
            }
            
        } else {
            // error state: no categories found
            // MARK: do some thing here
            
            if isDevelopmentMode {
                print("Fatal error getting the result set in getCategories function")
            }
        }
        
        return categories
        
    }
}
