//
//  QuizSetVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class QuizSetVC: UIViewController, UICollectionViewDataSource, QuizCVCellDelegate, CVCellChangedDelegate, QuizDoneCVCellDelegate {
    
    
    @IBOutlet weak var movePreviousButton: UIButton!
    @IBOutlet weak var moveNextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    
    var scrollDelegate = CVScrollController()
    let quizSetVCH = QuizSetVCH()
    let utilities = Utilities()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollDelegate.topBottomMargin  = myConstants.layout_topBottomMargin
        scrollDelegate.sideMargin = myConstants.layout_sideMargin
        scrollDelegate.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = scrollDelegate
        
        moveNextButton.layer.cornerRadius  = myConstants.button_cornerRadius
        movePreviousButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        updateDisplay()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizSetVCH.quizSet.getActiveQuestionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if quizSetVCH.isAtSummary(indexPath: indexPath)  {
            //need to show the summary cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "quizDoneCell", for: indexPath) as! QuizDoneCVCell
            cell.gradeLabel.text = quizSetVCH.getGradeLabelText()
            cell.resultsLabel.text = quizSetVCH.getResultsLabeText()
            cell.delegate = self
            return cell
            
        } else {
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "quizCell", for: indexPath) as! QuizCVCell
            let question = quizSetVCH.quizSet.getQuestion(index: indexPath.row)
            cell.configure(question: question, questionIndex: indexPath.row, totalQuestions: quizSetVCH.quizSet.getTotalQuestionCount())
            cell.delegate = self
            return cell
        }
    }
    
    // delegate functions
    func selectedAnswer(questionIndex: Int, answerIndex: Int) {
        //if this is answered already, don't do anything
        let question  = quizSetVCH.quizSet.getQuestion(index: questionIndex)
        if question.isAnswered() {
            //don't do anything
            return
        }
        
        quizSetVCH.quizSet.selectAnswerToQuestion(questionIndex: questionIndex, answerIndex: answerIndex)
        
        // will add more questions to the datasource
        collectionView.reloadData()
        
        // need to do this as it makes layout changes for the additional questions.
        // I use the layout for calculating what I need in the scroll delegate so they layout needs to be done right away
        
        collectionView.layoutIfNeeded()
        
        //if the set is complete, show a completion dialog
        
        if quizSetVCH.quizSet.getQuizStatus() == 2 {
            print("you are done!!!")
            //add a fake question
        }
        
        updateDisplay()
    }
    
    func retartButtonPressed() {
        restartQuiz()
    }
    
    func updateDisplay () {
        //configure options button
        if quizSetVCH.quizSet.getQuizStatus() == 0 {
            optionsButton.isEnabled = false
        } else {
            optionsButton.isEnabled = true
        }
        updateNavigationButtons()
    }
    
    func CVCellChanged(cellIndex: Int) {
        updateNavigationButtons()
    }
    
    func updateNavigationButtons () {
        //update the status of the buttons
        let previousButtonState = scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        let nextButtonState = scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
        utilities.setEnableState(button: movePreviousButton, isEnabled: previousButtonState)
        utilities.setEnableState(button: moveNextButton, isEnabled: nextButtonState)
    }
    
    func CVCellDragging(cellIndex: Int) {
        //do nothing
    }
    
    func showOptionsMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restartQuiz = UIAlertAction(title: "Restart This Quiz", style: .default, handler: {action in self.restartQuiz()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(restartQuiz)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func restartQuiz() {
        quizSetVCH.quizSet.resetQuizSet()
        scrollDelegate.scrollToTop(collectionView: collectionView)
        collectionView.reloadData()
        updateDisplay()
    }
    
    @IBAction func movePreviousButtonAction(_ sender: Any) {
        scrollDelegate.scrollPrevious(collectionView: collectionView)
    }
    
    @IBAction func moveNextButtonAction(_ sender: Any) {
        scrollDelegate.scrollNext(collectionView: collectionView)
    }
    
    @IBAction func optionsButtonAction(_ sender: UIBarButtonItem) {
        showOptionsMenu()
    }
    
}


