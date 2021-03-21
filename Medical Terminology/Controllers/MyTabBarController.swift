//
//  MyTabBarController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/20/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import UIKit

class MyCustomTabBarController: UITabBarController, UITabBarControllerDelegate {
	
	/*
	
	var previousSelectedTabIndex:Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
	}
	
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		self.previousSelectedTabIndex = tabBarController.selectedIndex
	}
	
	
	override func tabBar(_ tabBar: UITabBar, didSelect item:
							UITabBarItem) {
		let vc = self.viewControllers![previousSelectedTabIndex] as! UINavigationController
		vc.popToRootViewController(animated: false)
		
	}


*/
override func viewDidLoad()
		{
			super.viewDidLoad()
			self.delegate = self
		}


	 func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
		{
			if let vc = viewController as? UINavigationController
			{ vc.popToRootViewController(animated: false) }
		}
	}
	


/*

import UIKit

class MyCustomTabBarController: UITabBarController, UITabBarControllerDelegate {
var previousSelectedTabIndex:Int = 0

override func viewDidLoad() {
super.viewDidLoad()
self.delegate = self
}

func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
self.previousSelectedTabIndex = tabBarController.selectedIndex
}


override func tabBar(_ tabBar: UITabBar, didSelect item:
UITabBarItem) {
let vc = self.viewControllers![previousSelectedTabIndex] as! UINavigationController
vc.popToRootViewController(animated: false)

}

}
*/
