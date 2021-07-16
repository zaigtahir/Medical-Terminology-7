//
//  TestOptionsViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol TestOptionsVCDelegate: AnyObject {
    func shouldChangeNumberOfQuestions (numberOfQuestions: Int)
}


class TestOptionsVC: UIViewController {
    
    @IBOutlet weak var maximumSelector: UISegmentedControl!
   
    var numberOfQuestions = 10
    weak var delegate : TestOptionsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch numberOfQuestions {
        case 25:
            maximumSelector.selectedSegmentIndex = 1
        case 50:
            maximumSelector.selectedSegmentIndex = 2
        case 100:
            maximumSelector.selectedSegmentIndex = 3
        default:
            maximumSelector.selectedSegmentIndex = 0
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func maximumQuestionsSelectorChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
		
        case 0:
            numberOfQuestions = 10
        case 1:
            numberOfQuestions = 25
        case 2:
            numberOfQuestions = 50
        default:
            numberOfQuestions = 100
        }
		
		delegate?.shouldChangeNumberOfQuestions(numberOfQuestions: numberOfQuestions)
    }
}
