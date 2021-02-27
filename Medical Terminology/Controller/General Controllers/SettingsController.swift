//
//  SettingsController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/30/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation
import SQLite3

class SettingsController {
    
  
    func setShowWelcomeScreen (showWelcomeScreen: Bool) {
        let userDefaults = UserDefaults()
        userDefaults.set(showWelcomeScreen, forKey: myKeys.showWelcomeScreen)
    }
    
    func getShowWelcomeScreen () -> Bool {
        let userDefaults = UserDefaults()
        return userDefaults.bool(forKey: myKeys.showWelcomeScreen)
    }
    
    func getBundleVersion () -> String {
        //will return bundle version number. If this does not match the installed version in user default settings, will need to update or upload the database
        
        //testing out the infolist
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let v = version ?? "-1"
        let b = build ?? "-1"
        
        return ("\(v).\(b)")
    }
    
    func getUserDefaultsVersion () -> String {
        
        let uDefaults = UserDefaults()
        let uVersion  = uDefaults.string(forKey: myKeys.appVersion)
        let uBuild = uDefaults.string(forKey: myKeys.appBuild)
        
        let v = uVersion ?? "-1"
        let b = uBuild ?? "-1"
        
        return ("\(v).\(b)")
    }
    
    func updateVersionNumber () {
        //will update the user defaults with the verion from the bundle
        //testing out the infolist
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let v = version ?? "-1"
        let b = build ?? "-1"
        
        setVersionNumber(version: v, build: b)
        
    }
    private func setVersionNumber(version: String, build: String) {
        let uDefaluts = UserDefaults()
        uDefaluts.setValue(version, forKey: myKeys.appVersion)
        uDefaluts.setValue(build, forKey: myKeys.appBuild)
    }
    
    
}
