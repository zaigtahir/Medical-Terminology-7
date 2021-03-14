//
//  LearnVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class LearnSetVC: UIViewController,  UICollectionViewDataSource, CVCellChangedDelegate, LearnCVCellDelegate, LearnDoneCVCellDelegate {
    
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var scrollDelegate = CVScrollController()
    let utilities = Utilities()
    let learnSetVCH = LearningSetVCH()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollDelegate.topBottomMargin  = myConstants.layout_topBottomMargin
        scrollDelegate.sideMargin = myConstants.layout_sideMargin
        scrollDelegate.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = scrollDelegate
        
        nextButton.layer.cornerRadius  = myConstants.button_cornerRadius
        previousButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        updateDisplay()
        
    }
    
    
    //datasource function
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numItems =  learnSetVCH.learningSet.getActiveQuestionsCount()
        return numItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //need to figure out a better way to know when im at the summary card
        
        if learnSetVCH.isAtSummary(indexPath: indexPath) {
            //need to show the summary cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnDoneCell", for: indexPath) as! LearnDoneCVCell
            cell.delegate = self
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "learnCell", for: indexPath) as! LearnCVCell
            cell.delegate = self
            
            let question = learnSetVCH.learningSet.getQuestion(index: indexPath.row)
            let quizStatus = learnSetVCH.learningSet.getQuizStatus()
            
            cell.configure(question: question, questionIndex: indexPath.row, totalQuestions: learnSetVCH.learningSet.getTotalQuestionCount(), quizStatus: quizStatus)
            
            return cell
        }
    }
    
    func questionIndexChanged(questionIndex: Int, lastIndex: Int) {
        //delegate function from the collection view delegate, this is when the collection view is moved
        //just need to update the navigation buttons
        
        updateNavigationButtons()
        
    }
    
    func updateDisplay() {
        //collectionView.reloadData() removed from here, do in the functions that need it only so it does not repeat after those functions

        updateNavigationButtons()
        
        //configure options button
        if learnSetVCH.learningSet.getQuizStatus() == .notStarted {
            optionsButton.isEnabled = false
        } else {
            optionsButton.isEnabled = true
        }
    }
    
    //scroll delegates
    func CVCellChanged(cellIndex: Int) {
        updateNavigationButtons()
    }
    
    func CVCellDragging(cellIndex: Int) {
        //TODO: add code as needed
    }
    
    func updateNavigationButtons () {
        //update the status of the buttons
        previousButton.isEnabled =  scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        nextButton.isEnabled =  scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
        
        for b in [previousButton, nextButton] {
			myTheme.formatButtonColor(button: b!, enabledColor: myTheme.colorLhButton!)
        }
    }
        
    func showOptionsMenu () {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restartSet = UIAlertAction(title: "Restart this set", style: .default, handler: {action in self.restartLearningSet()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(restartSet)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func restartLearningSet() {
        learnSetVCH.learningSet.resetLearningSet()
        scrollDelegate.scrollToTop(collectionView: collectionView)
        collectionView.reloadData()
        updateDisplay()
        
    }
    
    //MARK:- delegate function from LearnCVCell delegate, this is when the user selects an answer
    func selectedAnswer(questionIndex: Int, answerIndex: Int) {
        //if this is answered already, don't do anything
        let question  = learnSetVCH.learningSet.getQuestion(index: questionIndex)
        if question.isAnswered() {
            //don't do anything
            return
        }
        
        learnSetVCH.learningSet.selectAnswerToQuestion(questionIndex: questionIndex, answerIndex: answerIndex)
        
        // will add more questions to the datasource
        collectionView.reloadData()
        
        // need to do this as it makes layout changes for the additional questions.
        // I use the layout for calculating what I need in the scroll delegate so they layout needs to be done right away
        
        collectionView.layoutIfNeeded()
        
        updateDisplay()
    }
    
    func showAgain(questionIndex: Int) {
        print("user pressed the show again button")
        
        learnSetVCH.learningSet.activeQuestions[questionIndex].showAgain = true
        
        learnSetVCH.learningSet.requeueQuestion(questionIndex: questionIndex)
        
        collectionView.reloadData()
        
        // need to do this as it makes layout changes for the additional questions.
        // I use the layout for calculating what I need in the scroll delegate so they layout needs to be done right away
        
        collectionView.layoutIfNeeded()
        
        updateDisplay()
    }
    
    func showAnswer(questionIndex: Int, showAnswer: Bool) {
        // just update the question information here to be used
        // when the user changes the cards
        // in the cell, the action will just toggle the
        // view locally
        
        learnSetVCH.learningSet.activeQuestions[questionIndex].showAnswer = showAnswer
    }
    
    //end of delegate functions from LearnCVCell
    
    func retartButtonPressed() {
        restartLearningSet()
    }
    
    @IBAction func optionsButtonAction(_ sender: UIBarButtonItem) {
        showOptionsMenu()
    }
    
    @IBAction func movePreviousButtonAction(_ sender: Any) {
        scrollDelegate.scrollPrevious(collectionView: collectionView)
    }
    
    @IBAction func moveNextButtonAction(_ sender: Any) {
        scrollDelegate.scrollNext(collectionView: collectionView)
        
    }
    
}
