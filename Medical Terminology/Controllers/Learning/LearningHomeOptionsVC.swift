//
//  LearnHomeOptionsVCViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearningOptionsUpdated: class {
    func learningOptionsUpdated (isFavoriteMode: Bool, numberOfTerms: Int)
}

class LearningHomeOptionsVC: UIViewController {
    
    //load this via the segue call
    var isFavoriteMode  = false
    var numberOfTerms = 5 // choices will be 5, 10, 25, 50 terms
    weak var delegate: LearningOptionsUpdated?
    
    @IBOutlet weak var maximumSelector: UISegmentedControl!
    @IBOutlet weak var favoriteControl: UISegmentedControl!
    
    private let dIC = DItemController()
    
    //number of terms for the learning set, can change with options
    // load this via the segue call
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        switch numberOfTerms {
            
        case 10:
            maximumSelector.selectedSegmentIndex = 1
        case 25:
            maximumSelector.selectedSegmentIndex = 2
        case 50:
            maximumSelector.selectedSegmentIndex = 3
        default:
            maximumSelector.selectedSegmentIndex = 0
            
        }
        
        if isFavoriteMode {
            favoriteControl.selectedSegmentIndex = 1
        } else {
            favoriteControl.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func favoriteControlAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isFavoriteMode = false
        } else {
            isFavoriteMode = true
        }
    }
    
    @IBAction func numberOfTermsSelectorChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            numberOfTerms = 10
        case 2:
            numberOfTerms = 25
        case 3:
            numberOfTerms = 50
        default:
            numberOfTerms = 5
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
                
        delegate?.learningOptionsUpdated(isFavoriteMode: isFavoriteMode, numberOfTerms: numberOfTerms)
    
    }
    
    
}
