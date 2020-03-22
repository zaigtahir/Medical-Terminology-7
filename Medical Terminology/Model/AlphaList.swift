//
//  AlphaList.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/30/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

//  Holds information to display a table with section headers and table content of DItems

import Foundation

class AlphaList {
    
    //make empty arrays
    var sections : [String] = []
    var listItems : [[DItem]] = [[]]
    
    init() {
        //don't know why this creates one item. So will just remove it so the listItems array is completely empty
        listItems.remove(at: 0)
    }
    
    func getDItemFromList (indexPath: IndexPath) -> DItem {
        //return a dItem stored at this index. You have to make sure that the list contains this or else you will get an error
        return listItems[indexPath.section][indexPath.row]
    }


    func printList() {
        for i in 0...sections.count-1 {
            print("SECTION: \(sections[i])")
            for item in listItems[i] {
                print(item.term)
            }
        }
    }
}
