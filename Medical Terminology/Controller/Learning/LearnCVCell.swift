//
//  LearningCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/12/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearnCVCellDelegate: AnyObject {
    func selectedAnswer(questionIndex: Int, answerIndex: Int)
    
    //trigger when the user wants to show the card again
    func showAgain(questionIndex: Int)
}

class LearnCVCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate {
    
    
    //will need to fill itself with all the data on creation
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultRemarksLabel: UILabel!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var showAgainButton: UIButton!
    
    
    
    //this the index of the question in the quiz, used to identify the question in the quiz for the delegate function. It is set by the LearnSetVCH when forming this cell with the configure function
    private var questionIndex: Int!
    
    private var question: Question! //the question to show
    private var showAnswer = false
    
    let dIC = DItemController()
    weak var delegate: LearnCVCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        cellView.layer.cornerRadius = myConstants.layout_cornerRadius
        cellView.layer.borderWidth = 1
        cellView.clipsToBounds = true
        
        showAnswerButton.layer.cornerRadius = myConstants.button_cornerRadius
                
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func layoutSubviews() {
        //set color here to it responds to dark mode
        cellView.layer.borderColor = UIColor(named: "color card border")?.cgColor
    }
    
    func configure (question: Question, questionIndex: Int) {
        self.questionIndex = questionIndex
        self.question = question
        questionLabel.text = "\(question.questionText)"
        
        showAnswerButton.isEnabled = true
        showAgainButton.isEnabled = true
        
        if question.isAnswered() {
            
            showAgainButton.setTitle("Show Again", for: .normal)
            
            if question.isCorrect() {
                showAnswerButton.isHidden = true
                showAgainButton.isHidden = false
                resultView.backgroundColor = myTheme.color_correct
                resultRemarksLabel.text = question.getLearningRemarks()
                
            } else {
                
                showAnswerButton.isHidden = false
                showAgainButton.isHidden = true
                resultView.backgroundColor = myTheme.color_incorrect
                resultRemarksLabel.text = question.getLearningRemarks()
            }
            
        } else {
            
            //question is not answered
            let item = dIC.getDItem(itemID: question.itemID)
            question.learnedDefinitionForItem = item.learnedDefinition
            question.learnedTermForItem = item.learnedTerm

            showAnswerButton.isHidden = true
            showAgainButton.isHidden = true
            resultView.backgroundColor = UIColor(named: "color card border")
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
    
    @IBAction func showAgainButtonAction(_ sender: Any) {
        showAgainButton.isEnabled = false
        showAgainButton.setTitle("Will Show Again", for: .normal)
        delegate?.showAgain(questionIndex: questionIndex)
    }
}


