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
}

class QuizCVCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var questionCounter: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultRemarksLabel: UILabel!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var question: Question! //the question to show
    private var showAnswer = false
    private var totalQuestions: Int!
    private var questionIndex: Int! //this the index of the question in the quiz, used to identify the question in the quiz for the delegate function
    
    let dIC = DItemController()
    
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
    
    override func layoutSubviews() {
        //set color here to it responds to dark mode
        cellView.layer.borderColor = UIColor(named: "color card border")?.cgColor
    }
    
    func configure (question: Question, questionIndex: Int, totalQuestions: Int) {
        self.questionIndex = questionIndex
        self.question = question
        self.totalQuestions = totalQuestions
        questionCounter.text = "Question: \(questionIndex + 1) of \(totalQuestions)"
        showAnswerButton.isEnabled = true
        questionLabel.text = "\(question.questionText)"
        questionLabel.text = "\(question.questionText)"
        
        if question.isAnswered() {
            if question.isCorrect() {
                showAnswerButton.isHidden = true
                resultView.backgroundColor = myTheme.color_correct
                resultRemarksLabel.text = question.getQuizAnswerRemarks()
            } else {
                resultView.backgroundColor = myTheme.color_incorrect
                resultRemarksLabel.text = question.getQuizAnswerRemarks()
                showAnswerButton.isHidden = false
            }
            
        } else {
            
            //question is not answered
            let item = dIC.getDItem(itemID: question.itemID)
            question.learnedDefinitionForItem = item.learnedDefinition
            question.learnedTermForItem = item.learnedTerm
            showAnswerButton.isHidden = false
            showAnswerButton.isHidden = true
            resultRemarksLabel.text = ""
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
            cell.answerImage.image = myTheme.image_correct
            cell.answerImage.tintColor = myTheme.color_correct
            
        case 2:
            cell.answerImage.image = myTheme.image_incorrect
            cell.answerImage.tintColor = myTheme.color_incorrect
        case 3:
            
            if showAnswer {
                cell.answerImage.image = myTheme.image_correct
                cell.answerImage.tintColor = myTheme.color_correct
                showAnswer = false  //reset it
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
    
    @IBAction func showAnswerButtonAction(_ sender: UIButton) {
        showAnswer = true
        showAnswerButton.isEnabled = false
        tableView.reloadData()
    }
}
