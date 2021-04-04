//
//  Protocols.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/31/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation

protocol notificationProtocol {
	
	func termInformationChangedNotification (notification: Notification)
	
	func categoryChangedNotification (notification : Notification)
	
	func categoryAssignedNotfication (notification : Notification)
	
	func unassignedCategoryNotfication (notification : Notification)
	
	func categoryDeletedNotification (notification: Notification)
}
