//
//  QuizHome.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//



import UIKit

class QuizHome: UIViewController, QuizHomeVCHDelegate {
	
	@IBOutlet weak var showFavoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var circleBarView: UIView!
	@IBOutlet weak var redoButton: UIButton!
	@IBOutlet weak var newSetButton: ZUIRoundedButton!
	@IBOutlet weak var seeCurrentSetButton: ZUIRoundedButton!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var optionsButton: UIBarButtonItem!
	@IBOutlet weak var headingLabel: UILabel!
	
	let quizHomeVCH = QuizHomeVCH()
	let utilities = Utilities()
	var progressBar: CircularBar!
	
	private let cc = CategoryController2()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
		
		quizHomeVCH.delegate = self
		
		quizHomeVCH.updateData()
		
		percentLabel.textColor = myTheme.colorButtonText
		
		updateDisplay()
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	private func updateDisplay () {
		
		showFavoritesOnlyButton.isOn = quizHomeVCH.isFavoriteMode
		
		favoritesCountLabel.text = "\(quizHomeVCH.favoriteTermsCount)"
		
		let c = cc.getCategory(categoryID: quizHomeVCH.currentCategoryID)
		
		categoryNameLabel.text = "\(c.name) (\(quizHomeVCH.categoryTermsCount))"
		
		if quizHomeVCH.categoryTermsCount == 0 {
			// no terms available in this category
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			headingLabel.isHidden = false
			messageLabel.isHidden = true
			
			headingLabel.text = myConstants.noTermsHeading
			messageLabel.text = myConstants.noTermsSubheading
			
			formatProgressBar()
			updateButtons()
			return
		}
		
		// no favorite terms available
		if quizHomeVCH.showFavoritesOnly && quizHomeVCH.favoriteTermsCount == 0 {
			percentLabel.isHidden = true
			redoButton.isHidden = true
			headingLabel.isHidden = false
			messageLabel.isHidden = true
			
			headingLabel.text = myConstants.noFavoriteTermsHeading
			messageLabel.text = myConstants.noFavoriteTermsSubheading
			
			formatProgressBar()
			updateButtons()
			return
		}
		

		
		// some terms available
		percentLabel.isHidden = false
		redoButton.isHidden = false
		headingLabel.isHidden = true
		messageLabel.isHidden = false
		
		return
		
		messageLabel.text = "You correctly answered \(quizHomeVCH.answeredCorrectCount) out of \(quizHomeVCH.totalQuestionsAvailableCount) available questions"
		formatProgressBar()
		updateButtons()
	
	}
	
	private func formatProgressBar () {
		
		let foregroundColor = myTheme.colorPbQuizForeground?.cgColor
		let backgroundColor = myTheme.colorPbQuizBackground?.cgColor
		let fillColor =  myTheme.colorPbQuizFillcolor?.cgColor
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!, lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: quizHomeVCH.answeredCorrectCount, totalCount: quizHomeVCH.totalQuestionsAvailableCount)
		
		let percentText = utilities.getPercentage(number: quizHomeVCH.answeredCorrectCount, numberTotal: quizHomeVCH.totalQuestionsAvailableCount)
		
		percentLabel.text = "\(percentText)% DONE"
	}
	
	private func updateButtons () {
		print ("to complete code update buttons")
		/*
		if quizHomeVCH.answeredCorrectCount == 0 {
			redoButton.isEnabled = false
		} else {
			redoButton.isEnabled = true
		}
		
		//state of see current quiz button
		//currentQuizButton.isEnabled = quizHomeVCH.isQuizSetAvailable()

*/
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		
		updateDisplay()
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "segueToQuiz" {
			let vc = segue.destination as! QuizSetVC
			
			if quizHomeVCH.startNewQuiz {
				vc.quizSetVCH.quizSet = quizHomeVCH.getNewQuizSet()
			} else {
				vc.quizSetVCH.quizSet = quizHomeVCH.getQuizSet()
			}
		}
		
		if segue.identifier == "segueQuizOptions" {
			let vc = segue.destination as! QuizOptionsVC
			vc.delegate = quizHomeVCH
			vc.questionsType = quizHomeVCH.questionsType
			vc.numberOfQuestions = quizHomeVCH.numberOfQuestions
			vc.isFavoriteMode = quizHomeVCH.isFavoriteMode
		}
	}
	
	func confirmRestart () {
		
		let alert = UIAlertController(title: "Redo Quiz Questions", message: "Are you sure you want to clear the answers to these questions and redo them?", preferredStyle: .actionSheet)
		
		let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
										action in self.restartNow()})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	func restartNow() {
		quizHomeVCH.restartOver()
		updateDisplay()
	}
	
	// MARK: - QuizHomeVCHDelegate functions
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	@IBAction func optionsButtonAction(_ sender: Any) {
		performSegue(withIdentifier: "segueQuizOptions", sender: nil)
	}
	
	@IBAction func redoButtonAction(_ sender: Any) {
		confirmRestart()
	}
	
	@IBAction func newQuizButtonAction(_ sender: UIButton) {
		quizHomeVCH.startNewQuiz = true
		performSegue(withIdentifier: "segueToQuiz", sender: nil)
	}
	
	@IBAction func currentQuizButtonAction(_ sender: Any) {
		//will manually segue
		quizHomeVCH.startNewQuiz  = false
		performSegue(withIdentifier: "segueToQuiz", sender: nil)
	}
	
	
}
