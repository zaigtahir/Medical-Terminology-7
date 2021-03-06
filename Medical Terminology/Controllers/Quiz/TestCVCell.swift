//
//  TestCVCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


import UIKit

//note make this similar to LearnCVCell

protocol TestCVCellDelegate: AnyObject {
	
	func selectedAnswer(questionIndex: Int, answerIndex: Int)
	func showAnswer(questionIndex: Int, showAnswer: Bool)
}

class TestCVCell: UICollectionViewCell, UITableViewDataSource, AnswerTCellDelegate {
	
	@IBOutlet weak var cellView: UIView!
	@IBOutlet weak var questionCounter: UILabel!
	@IBOutlet weak var questionLabel: UILabel!
	@IBOutlet weak var resultView: UIView!
	@IBOutlet weak var resultRemarksLabel: UILabel!
	@IBOutlet weak var showAnswerLabel: UILabel!
	@IBOutlet weak var showAnswerSwitch: UISwitch!
	
	@IBOutlet weak var tableView: UITableView!
	
	private var question: Question! //the question to show
	private var showAnswer = false
	private var totalQuestions: Int!
	private var questionIndex: Int! //this the index of the question in the test, used to identify the question in the test for the delegate function
	
	weak var delegate: TestCVCellDelegate?
	
	override func awakeFromNib() {
		
		super.awakeFromNib()
		// Initialization code
		cellView.layer.cornerRadius = myConstants.layout_cornerRadius
		cellView.layer.borderWidth = 1
		cellView.clipsToBounds = true
		
		tableView.dataSource = self
	}
	
	func configure (question: Question, questionIndex: Int, totalQuestions: Int) {
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "testAnswerCell", for: indexPath) as! AnswerTCell
		
		cell.answerText.text = "hello"
		
		cell.answerText.text = question.answers[indexPath.row].answerText
		
		cell.selectAnswerButton.setTitle("  \(indexPath.row + 1)", for: .normal)
		
		cell.rowNumber = indexPath.row
		
		cell.delegate = self
		
		// getAnswerStatus:
		// 0 = question is not answered
		// 1 = answer is selected and is correct
		// 2 = answer is selected and is not correct
		// 3 = answer is not selected but is correct
		// 4 = answer is not selected and is not correct
		
		switch question.getAnswerStatus(answerIndex: indexPath.row) {
		
		case 1:
			cell.selectAnswerButton.setImage(myTheme.imageCorrect, for: .normal)
			cell.selectAnswerButton.tintColor = myTheme.colorCorrect
			
		case 2:
			cell.selectAnswerButton.setImage(myTheme.imageIncorrect, for: .normal)
			cell.selectAnswerButton.tintColor = myTheme.colorIncorrect
			
			
		case 3:
			//this test will allow the table to be updated to
			//show the result based on local change to the
			//switch or from the question.showAnswer field when the user scrolls to this card
			
			if question.showAnswer || showAnswerSwitch.isOn {
				cell.selectAnswerButton.setImage(myTheme.imageCorrect, for: .normal)
				cell.selectAnswerButton.tintColor = myTheme.colorCorrect
				
				
			} else {
				cell.selectAnswerButton.setImage(myTheme.imageRowNotSelected, for: .normal)
				cell.selectAnswerButton.tintColor = myTheme.colorText
			}
			
		case 4:
			cell.selectAnswerButton.setImage(myTheme.imageRowNotSelected, for: .normal)
			cell.selectAnswerButton.tintColor = myTheme.colorText
			
		default:
			cell.selectAnswerButton.setImage(myTheme.imageRowNotSelected, for: .normal)
			cell.selectAnswerButton.tintColor = myTheme.colorText
		}
		
		return cell
	}
	
	//MARK: - delegate function for AnswerTCell
	func selectedAnswerRow(rowNumber: Int) {
		delegate?.selectedAnswer(questionIndex: questionIndex, answerIndex: rowNumber)
	}
	
	@IBAction func showAnswerSwitchAction(_ sender: UISwitch) {
		// trigger delegate function so that you can update the show answer setting
		// in the calling VC
		delegate?.showAnswer(questionIndex: questionIndex, showAnswer: showAnswerSwitch.isOn)
		
		//just update the table to the answer is shown
		tableView.reloadData()
	}
	
}
