//
//  LearnHomeOptionsVCViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearningOptionsUpdated: AnyObject {
    func learningOptionsUpdated ( numberOfQuestions: Int)
}

class LearningHomeOptionsVC: UIViewController {
    
    //load this via the segue call
    var numberOfQuestions = 10 // choices will be 10, 20, 50, 100 questions
    weak var delegate: LearningOptionsUpdated?
    
    @IBOutlet weak var maximumSelector: UISegmentedControl!
    
    //number of terms for the learning set, can change with options
    // load this via the segue call
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        switch numberOfQuestions {
            
        case 20:
            maximumSelector.selectedSegmentIndex = 1
        case 50:
            maximumSelector.selectedSegmentIndex = 2
        case 100:
            maximumSelector.selectedSegmentIndex = 3
        default:
            maximumSelector.selectedSegmentIndex = 0
            
        }
    }
    
	@IBAction func numberOfQuestionsSelectorAction(_ sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
		case 1:
			numberOfQuestions = 20
		case 2:
			numberOfQuestions = 50
		case 3:
			numberOfQuestions = 100
		default:
			numberOfQuestions = 10
		}
	}

    override func viewWillDisappear(_ animated: Bool) {
                
        delegate?.learningOptionsUpdated( numberOfQuestions: numberOfQuestions)
    
    }
    
}
