//
//  WelcomeScreenVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/2/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import UIKit

class WelcomeScreenVC: UIViewController {

    @IBOutlet weak var appTitle: UILabel!
    
    @IBOutlet weak var appVersion: UILabel!
    
    @IBOutlet weak var seeWebsiteButton: UIButton!
    @IBOutlet weak var startAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        seeWebsiteButton.layer.cornerRadius = myConstants.button_cornerRadius
        startAppButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        appTitle.text = myConstants.appTitle
        
        //the show screen button should always be ON otherwise you wouldn't see this screen
        
        let sC = SettingsController()
        let version = sC.getUserDefaultsVersion()
        appVersion.text = "version: \(version)"
        
    }

    @IBAction func showWelcomeScreenSwitchAction(_ sender: UISwitch) {
        
        var showScreen = false
        if sender.isOn {
            showScreen = true
        }
        
        let sC = SettingsController()
        sC.setShowWelcomeScreen(showWelcomeScreen: showScreen)
        
    }
    
    @IBAction func seeWebsiteButtonAction(_ sender: Any) {
        if let url = URL(string: myConstants.appWebsite) {
            UIApplication.shared.open(url)
        }
    }
    
}
