//
//  InfoVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/30/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
import MessageUI


class InfoVC: UIViewController {
    
    @IBOutlet weak var showScreenSwitch: UISwitch!
    @IBOutlet weak var seeWebsiteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seeWebsiteButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        //set the showScreenSwitch position
        let sC = SettingsController()
        let showScreenState = sC.getSettings().showWelcomeScreen
        if showScreenState == 1 {
            showScreenSwitch.isOn = true
        } else {
            showScreenSwitch.isOn = false
        }
        
    }
        
    @IBAction func showWelcomeScreenSwitchAction(_ sender: UISwitch) {
        
        var showScreen = 0
              if sender.isOn {
                  showScreen = 1
              }
              
              let sC = SettingsController()
              sC.saveShowWelcomeScreen(showIntro: showScreen)
    }
    
    @IBAction func seeWebsiteButtonAction(_ sender: Any) {
        
        if let url = URL(string: myConstants.appWebsite) {
            UIApplication.shared.open(url)
        }
        
    }
}
