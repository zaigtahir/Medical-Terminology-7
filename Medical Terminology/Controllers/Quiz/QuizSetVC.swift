//
//  QuizSetVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol QuizSetVCDelegate: AnyObject {
	func doneButtonPressed()
}

class QuizSetVC: UIViewController, UICollectionViewDataSource, QuizCVCellDelegate, ScrollControllerDelegate, QuizDoneCVCellDelegate {
    
    @IBOutlet weak var previousButton: ZUIRoundedButton!
    @IBOutlet weak var nextButton: ZUIRoundedButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var optionsButton: UIBarButtonItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    var scrollDelegate = ScrollController()
    let quizSetVCH = QuizSetVCH()
    let utilities = Utilities()
	
	weak var delegate : QuizSetVCDelegate?
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizSetVCH.quizSet.getActiveQuestionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if quizSetVCH.isAtSummary(indexPath: indexPath)  {
            //need to show the summary cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "quizDoneCell", for: indexPath) as! QuizDoneCVCell
            
            cell.gradeLabel.text = quizSetVCH.quizSet.getLetterGrade()
            cell.resultsLabel.text = quizSetVCH.quizSet.getResultsSummary()
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
    
    //MARK: - delegate functions
    func selectedAnswer(questionIndex: Int, answerIndex: Int) {
        		
		//if this is answered already, don't do anything
        let question  = quizSetVCH.quizSet.getQuestion(index: questionIndex)
        if question.isAnswered() {
            //don't do anything
            return
        }
        
        quizSetVCH.quizSet.selectAnswerToQuestion(questionIndex: questionIndex, answerIndex: answerIndex)
        quizSetVCH.quizSet.addFeedbackRemarks(question: question)
        
        // will add more questions to the datasource
        collectionView.reloadData()
        
        // need to do this as it makes layout changes for the additional questions.
        // I use the layout for calculating what I need in the scroll delegate so they layout needs to be done right away
        
        collectionView.layoutIfNeeded()
        
        updateDisplay()

    }
    
    func showAnswer(questionIndex: Int, showAnswer: Bool) {
        quizSetVCH.quizSet.activeQuestions[questionIndex].showAnswer = showAnswer
    }
    
    //end delegate functions
    
    func retartButtonPressed() {
        restartQuiz()
    }
    
    func updateDisplay () {
        //configure options button
        if quizSetVCH.quizSet.getQuizStatus() == .notStarted {
            optionsButton.isEnabled = false
        } else {
            optionsButton.isEnabled = true
        }
        
        //update counter
        
        updateNavigationButtons()
    }
    
    func CVCellChanged(cellIndex: Int) {
        updateNavigationButtons()
    }
    
    func updateNavigationButtons () {
        //update the status of the buttons
        previousButton.isEnabled =  scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        nextButton.isEnabled =  scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
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
	
	@IBAction func doneButtonAction(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}


