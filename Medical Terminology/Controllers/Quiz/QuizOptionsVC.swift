//
//  QuizOptionsViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol QuizOptionsUpdated: AnyObject {
    func quizOptionsUpdate (numberOfQuestions: Int, questionsTypes: TermComponent, isFavoriteMode: Bool)
}


class QuizOptionsVC: UIViewController {
    
    @IBOutlet weak var maxiumLabel: UILabel!
    @IBOutlet weak var maximumSelector: UISegmentedControl!
    @IBOutlet weak var questionsTypeLabel: UILabel!
    @IBOutlet weak var questionsTypeSelector: UISegmentedControl!
    @IBOutlet weak var favoriteSelector: UISegmentedControl!
    
    var numberOfQuestions = 10
    var questionsType : TermComponent = .both
    var isFavoriteMode = false
    
    weak var delegate : QuizOptionsUpdated?
    
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
        
        switch questionsType {
        case .both:
            questionsTypeSelector.selectedSegmentIndex = 0
        case .term:
            questionsTypeSelector.selectedSegmentIndex = 1
        default:
            questionsTypeSelector.selectedSegmentIndex = 2
        }
        
        if isFavoriteMode {
            favoriteSelector.selectedSegmentIndex = 1
        } else {
            favoriteSelector.selectedSegmentIndex = 0
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
    }
    
    @IBAction func questionsTypeSelectorChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            questionsType = .both
            
        case 1:
            questionsType = .term
            
        default:
            questionsType = .definition
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        delegate?.quizOptionsUpdate(numberOfQuestions: numberOfQuestions, questionsTypes: questionsType, isFavoriteMode: isFavoriteMode)
        
    }
    
    @IBAction func favoriteSelectorChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            isFavoriteMode = false
        } else {
            isFavoriteMode = true
        }
    }
    
}
