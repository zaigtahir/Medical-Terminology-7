//
//  AppDelegate.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 10/9/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit

var myDB : FMDatabase!  //serve as the globan database object

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
            let fU = FileUtilities ()
            let fileURL = fU.copyFileIfNeeded(fileName: "Medical Terminology", fileExtension: "db")
            myDB = FMDatabase(path: fileURL?.absoluteString)
            myDB.open()
        print ("in App delegate opened myDB")
        
        //check and see if there is a resource present for each audiofile name listed in the database
        print("In AppDelegate checking if each audiofile name in the database has a matching audiofile in the resource bundle")
        let aFC = AudioFileController()
        aFC.checkAudioFiles()
        print("Audio file check done! if there were any missing they would be listed before this ending line.")
        
        // here we will see if the installed version is the same as bundle version
        
        // if the bundle version is not same as the installed version, then do initial setup things
        
        let sC = SettingsController()
        
        print(sC.getBundleVersion())
        print(sC.getUserDefaultsVersion())
        
        // install and updates
        // if the userDefaults version is = 0.0, this is a new install. Will need to just copy all the database file to the documents folder
        
        if sC.getUserDefaultsVersion() == "0.0" {
            // brand new install
            // copy the database
            // update userDefaults version to match new version
            // set to show the welcome screen
            
        }
        
        if sC.getBundleVersion() != sC.getUserDefaultsVersion() {
            // the versions are not the same
            // migrate the database
            // update userDefaults version to match new version
            // set to show the welcome screen
            
            print ("the bundle and the install versions are not the same!")
            
            //set to show the welcome screen as this is a new install or reinstall
            sC.setShowWelcomeScreen(showWelcomeScreen: true)
            
        }
        
        
        if sC.getShowWelcomeScreen() == false {
        
            // selecting if to start at the welcome screen or flashcardhomeVC
            
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            
            
            let tabController = storyboard.instantiateViewController(withIdentifier: "appTabController") as! UITabBarController
            
            self.window?.rootViewController = tabController
            
            /*
            
            
            
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            
            self.window?.makeKeyAndVisible()
 */
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //close the singleton database
        
        //MARK: To fix this, will need to fix the close for the database variable
        
        myDB.close()
    }
    
    
}

