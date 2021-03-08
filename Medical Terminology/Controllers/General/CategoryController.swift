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
    
    func test () {
        if let resultSet = myDB.executeQuery("Select * from categories", withParameterDictionary: nil) {
        } else {
            print("Fatal error getting resultset in test()")
        }
    }
    /*
     Return a collection of categories from the database
     */
    func getCategories () -> [Category] {
        
        var categories = [Category]()
        
        let query = "SELECT categoryID, name, ifnull(description, '') As description, ifnull(displayOrder, 0) AS displayOrder FROM categories"
        
        if let resultSet = myDB.executeQuery(query, withParameterDictionary: nil) {
            
            while resultSet.next() {
                
                let categoryID = Int(resultSet.int(forColumn: "categoryID"))
                let name = resultSet.string(forColumn: "name") ?? ""
                let description = resultSet.string(forColumn: "description") ?? ""
                let displayOrder = Int(resultSet.int(forColumn: "displayOrder"))
                
                
                let c = Category(categoryID: categoryID, name: name, description: description, displayOrder: displayOrder)
                
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
