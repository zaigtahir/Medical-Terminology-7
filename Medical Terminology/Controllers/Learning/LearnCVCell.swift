//
//  LearningCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/12/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearnCVCellDelegate: AnyObject {
    // user selected an answer
    func selectedAnswer(questionIndex: Int, answerIndex: Int)
    
    // trigger when the user wants to show the card again
    func showAgain(questionIndex: Int)
    
    // user pressed the showAnswer button
    func showAnswer(questionIndex: Int, showAnswer: Bool)
}

class LearnCVCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    
    //will need to fill itself with all the data on creation
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultRemarksLabel: UILabel!
    @IBOutlet weak var questionCounterLabel: UILabel!
    @IBOutlet weak var showAgainButton: UIButton!
    @IBOutlet weak var willShowAgainButton: UIButton! //used always in default state as a hack.. see in the configure function for my description
    @IBOutlet weak var showAnswerLabel: UILabel!
    @IBOutlet weak var showAnswerSwitch: UISwitch!
    
    //this the index of the question in the quiz, used to identify the question in the quiz for the delegate function. It is set by the LearnSetVCH when forming this cell with the configure function
    
    private var questionIndex = 0     //index of the question in the learningSet
    private var question: Question!     //the question to show
    //initally set to totalQuestions, then
    private var totalQuestions = 0
    
    let dIC = DItemController()
    weak var delegate: LearnCVCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = myConstants.layout_cornerRadius
        cellView.layer.borderWidth = 1
        cellView.clipsToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func configure (question: Question, questionIndex: Int, totalQuestions: Int, quizStatus: QuizStatus) {
        //new configure function
        
        //hide the show controls
        
        showAgainButton.isHidden = true
        willShowAgainButton.isHidden = true
        showAnswerSwitch.isHidden = true
        showAnswerLabel.isHidden = true
        
        //save class variables
        self.question = question
        self.questionIndex = questionIndex
        
        resultRemarksLabel.text = question.feedbackRemarks
        
        questionCounterLabel.text = "Question: \(questionIndex + 1) of \(totalQuestions)"
        
        questionLabel.text = "\(question.questionText)"
        
        if question.isAnswered() {
            //question is answered already
            if question.isCorrect() {
                //is correctly answered
                resultView.backgroundColor = myTheme.colorCorrect
                cellView.layer.borderColor = myTheme.colorCorrect?.cgColor
                
                // configure showAgainButton
                // no ideas why but when I change the text on the button it flashes twice before staying on
                // will hack it an create two buttons: Show Again, Will Show Again (this one is always disabled)
                if question.showAgain == true {
                    //the user previously chose to add this question to the stack again. So do not enable this now
                    showAgainButton.isHidden = true
                    willShowAgainButton.isHidden = false
                } else {
                    showAgainButton.isHidden = false
                    willShowAgainButton.isHidden = true
                }
                
            } else {
                //is not answered correctly
                //set the switch to the position it should be
                
                resultRemarksLabel.text = "Incorrect - You'll See This Again"
                
                showAnswerSwitch.isOn = question.showAnswer
                showAnswerSwitch.isHidden = false
                showAnswerLabel.isHidden = false
                
                resultView.backgroundColor = myTheme.colorIncorrect
                cellView.layer.borderColor = myTheme.colorIncorrect?.cgColor
            }
        } else {
            //question is not answered
            resultView.backgroundColor = myTheme.colorLsNotAnswered
            cellView.layer.borderColor = myTheme.colorLsNotAnswered?.cgColor
        }
        
        tableView.reloadData()  //must refesh the data here so the table holds updated information
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell", for: indexPath) as! AnswerTCell
        
        cell.answerNumberLabel.text = "\(indexPath.row + 1)."
        
        cell.answerText.text = question.answers[indexPath.row].answerText
        
        // getAnswerStatus:
        // 0 = question is not answered
        // 1 = answer is selected and is correct
        // 2 = answer is selected and is not correct
        // 3 = answer is not selected but is correct
        // 4 = answer is not selected and is not correct
        
        switch question.getAnswerStatus(answerIndex: indexPath.row) {
            
        case 1:
            cell.answerImage.image = myTheme.imageCorrect
            cell.answerImage.tintColor = myTheme.colorCorrect
            
        case 2:
            cell.answerImage.image = myTheme.imageIncorrect
            cell.answerImage.tintColor = myTheme.colorIncorrect
            
        case 3:
            
            //this test will allow the table to be updated to
            //show the result based on local change to the
            //switch or from the question.showAnswer field when the user scrolls to this card
            
            if question.showAnswer || showAnswerSwitch.isOn {
                cell.answerImage.image = myTheme.imageCorrect
                cell.answerImage.tintColor = myTheme.colorCorrect
                
            } else {
                cell.answerImage.image = nil
            }
            
        case 4:
            cell.answerImage.image = nil
            
        default:
            cell.answerImage.image = nil
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedAnswer(questionIndex: questionIndex, answerIndex: indexPath.row)
    }
    
    @IBAction func showAnswerSwitchAction(_ sender: UISwitch) {
        // shoot off delegate function so that the question is
        // updated in the learningSet
        // just update the table locally to show or hide the result while the card is in view
        
        delegate?.showAnswer(questionIndex: questionIndex, showAnswer: sender.isOn)
        
        tableView.reloadData()
    }
    
    @IBAction func showAgainButtonAction(_ sender: Any) {
        //locally increment total questions
        delegate?.showAgain(questionIndex: questionIndex)
    }
}


