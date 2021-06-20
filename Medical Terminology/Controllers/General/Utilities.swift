//
//  Utilities.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/21/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import Foundation
import UIKit

class Utilities {

    func setFavoriteState (button: UIButton, isFavorite: Bool) {
        if isFavorite {
            button.tintColor = myTheme.colorFavorite
        } else {
            button.tintColor = myTheme.colorNotFavorite
        }
    }
    
    func getPercentage (number: Int, numberTotal: Int) -> String {
        
		if numberTotal == 0 {
			return "0"
		}
		
        let percent = Float(number)/Float(numberTotal) * 100
		
        if percent < 1 || (percent > 99 && percent < 100) {
            return String(format: "%.1f", percent) //formats to zero decimal place
        } else   {
            return String(format: "%.0f", percent) //formats to one decimal place
        }
    }
    
	func removeIndex (index: Int, array: [Int]) -> [Int]{
		
		var newArray = array
		
		if array.count == 0 {
			return newArray
		}
		
		if index >= array.count {
			return newArray
		}
		
		if index == array.count - 1 {
			newArray.removeLast()
			return newArray
		} else {
			newArray.remove(at: index)
			return newArray
		}
	
	}
	
	func containSameElements (array1 : [Int], array2 : [Int]) -> Bool {
		
		let a1 = array1.sorted()
		let a2 = array2.sorted()
		return a1 == a2
	
	}
}
