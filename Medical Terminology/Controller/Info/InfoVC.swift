//
//  InfoVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 9/30/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var feebackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        feedbackLabel.text = "Your feedback is very important, and helps us improve this app. Do you have a suggestion, find an error, or have a request for a feature? Please take a few minutes to give us your feedback. Thank you.\n\nContact Email: myemail@gmail.com"
        
    }

}
