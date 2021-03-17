//
//  FlashCardOptionsVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/25/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FlashcardOptionsDelegate {
    func flashCardViewModeChanged (fcvMode: FlashcardViewMode)
}


class FlashCardOptionsVC: UIViewController {
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var showSegmentedControl: UISegmentedControl!
    
    //class variables with default values
    var viewMode: FlashcardViewMode = .both          //flash card view mode
    
    var delegate: FlashcardOptionsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        switch viewMode {
        case .term:
            showSegmentedControl.selectedSegmentIndex = 1
        case .definition:
            showSegmentedControl.selectedSegmentIndex = 2
        default:
            showSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func viewModeSelectorChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            viewMode = .both
        case 1:
            viewMode = .term
        default:
            viewMode = .definition
        }
        
        delegate?.flashCardViewModeChanged(fcvMode: viewMode)
    }
    
}
