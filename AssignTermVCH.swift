//
//  AssignTermVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class AssignTermVCH: NSObject, UITableViewDataSource {
		
	var categoryID : Int!
	
	// 0 = all, 1 = assigned, 2 = unassigned
	var termStatus = 0
	
	
	func updateData () {
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 10
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
}
