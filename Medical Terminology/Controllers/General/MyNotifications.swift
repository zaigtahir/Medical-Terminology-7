//
//  MyNotifications.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/15/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

//class used to consolidate my notifications so that I don't have to duplicate them

class MyNotifications {
	
	
	func resetFlashcardsNotification (categoryID: Int, object: Any? ){
		let nName = Notification.Name(myKeys.resetFlashcardsKey)
		NotificationCenter.default.post(name: nName, object: object, userInfo: ["categoryID" : categoryID])
	}
	
	func resetLearningNotification (categoryID: Int, object: Any? ) {
		let nName = Notification.Name(myKeys.resetLearningKey)
		NotificationCenter.default.post(name: nName, object: object, userInfo: ["categoryID" : categoryID])
	}
	
	func resetTestNotification (categoryID: Int, object: Any? ) {
		
		let nName = Notification.Name(myKeys.resetTestKey)
		NotificationCenter.default.post(name: nName, object: object, userInfo: ["categoryID" : categoryID])
	}
	
	
	
}
