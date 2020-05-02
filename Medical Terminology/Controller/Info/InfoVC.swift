//
//  InfoVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/30/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
import MessageUI


class InfoVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feebackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK:- delegate functions
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func feedbackButtonAction(_ sender: Any) {
        if let url = URL(string: "https://theappgalaxy.com") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func emailSupportButtonAction(_ sender: Any) {
    
        guard MFMailComposeViewController.canSendMail() else {
            //can't sent email with this device
            let alert = UIAlertController(title: "Email Issue", message: "It looks like you can not send an email on this device using this link. You can try sending an email directly to support@theappgalaxy.com using your email program", preferredStyle: .alert)
            let alertActionOkay = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(alertActionOkay)
            present(alert, animated: true)
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["zaigtahir@gmail.com"])
        composer.setSubject("Support request")
        composer.setMessageBody("Hey, I got some feedback for you...", isHTML: false)
        
        present(composer, animated: true)
    
    }
}
