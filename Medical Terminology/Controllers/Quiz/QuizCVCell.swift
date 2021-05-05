//
//  QuizCVCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


import UIKit

//note make this similar to LearnCVCell

protocol QuizCVCellDelegate: AnyObject {
    
    func selectedAnswer(questionIndex: Int, answerIndex: Int)
    func showAnswer(questionIndex: Int, showAnswer: Bool)
}

class QuizCVCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var questionCounter: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultRemarksLabel: UILabel!
    @IBOutlet weak var showAnswerLabel: UILabel!
    @IBOutlet weak var showAnswerSwitch: UISwitch!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var question: Question2! //the question to show
    private var showAnswer = false
    private var totalQuestions: Int!
    private var questionIndex: Int! //this the index of the question in the quiz, used to identify the question in the quiz for the delegate function
    
    weak var delegate: QuizCVCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = myConstants.layout_cornerRadius
        cellView.layer.borderWidth = 1
        cellView.clipsToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func configure (question: Question2, questionIndex: Int, totalQuestions: Int) {
        self.questionIndex = questionIndex
        self.question = question
        self.totalQuestions = totalQuestions
        
        questionCounter.text = "Question: \(questionIndex + 1) of \(totalQuestions)"
        questionLabel.text = "\(question.questionText)"
        resultRemarksLabel.text = question.feedbackRemarks
        showAnswerSwitch.isOn = question.showAnswer
        
        if question.isAnswered() {
            if question.isCorrect() {
                showAnswerLabel.isHidden = true
                showAnswerSwitch.isHidden = true
                resultView.backgroundColor = myTheme.colorCorrect
                cellView.layer.borderColor = myTheme.colorCorrect?.cgColor
                
            } else {
                resultView.backgroundColor = myTheme.colorIncorrect
                cellView.layer.borderColor = myTheme.colorIncorrect?.cgColor
                
                showAnswerLabel.isHidden = false
                showAnswerSwitch.isHidden = false
            }
            
        } else {
 
            resultView.backgroundColor = myTheme.colorQsNotAnswered
            cellView.layer.borderColor = myTheme.colorQsNotAnswered?.cgColor
            showAnswerLabel.isHidden = true
            showAnswerSwitch.isHidden = true
        }
        
        tableView.reloadData()  //must refesh the data here so the table holds updated information
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //called changing from dark to light views
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
            
            if showAnswerSwitch.isOn {
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
        // trigger delegate function so that you can update the show answer setting
        // in the calling VC
        delegate?.showAnswer(questionIndex: questionIndex, showAnswer: showAnswerSwitch.isOn)
        
        //just update the table to the answer is shown
        tableView.reloadData()
    }
    
}
