//
//  QuizHome.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


import UIKit

class QuizHomeVC: UIViewController, QuizHomeVCHDelegate {
	
	@IBOutlet weak var favoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var circleBarView: UIView!
	@IBOutlet weak var infoIcon: UILabel!
	@IBOutlet weak var redoButton: UIButton!
	@IBOutlet weak var newSetButton: ZUIRoundedButton!
	@IBOutlet weak var seeCurrentSetButton: ZUIRoundedButton!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var optionsButton: UIBarButtonItem!
	@IBOutlet weak var headingLabel: UILabel!
	
	let quizHomeVCH = QuizHomeVCH()
	let utilities = Utilities()
	var progressBar: CircularBar!
	
	private let cc = CategoryController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
		
		quizHomeVCH.delegate = self
		
		updateDisplay()
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	private func updateDisplay () {
		
		favoritesOnlyButton.isOn = quizHomeVCH.favoritesOnly
		
		favoritesCountLabel.text = "\(quizHomeVCH.favoriteTermsCount)"
		
		let c = cc.getCategory(categoryID: quizHomeVCH.currentCategoryID)
		
		categoryNameLabel.text = "\(c.name) (\(quizHomeVCH.categoryTermsCount))"
		
		
		let foregroundColor = myTheme.colorPbQuizForeground?.cgColor
		let backgroundColor = myTheme.colorPbQuizBackground?.cgColor
		let fillColor = UIColor.systemBackground.cgColor
		
		
		if quizHomeVCH.categoryTermsCount == 0 {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noTermsHeading
			messageLabel.text = myConstants.noTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = quizHomeVCH.isQuizSetAvailable()
	
			
		} else if (quizHomeVCH.favoritesOnly && quizHomeVCH.favoriteTermsCount == 0) {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noFavoriteTermsHeading
			messageLabel.text = myConstants.noFavoriteTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = quizHomeVCH.isQuizSetAvailable()
			
		} else {
			
			// some terms available
			percentLabel.isHidden = false
			
			if quizHomeVCH.answeredCorrectCount > 0 {
				redoButton.isHidden = false
			} else {
				redoButton.isHidden = true
			}
			
			infoIcon.isHidden = true
			headingLabel.isHidden = true
			
			newSetButton.isEnabled = true
			seeCurrentSetButton.isEnabled = quizHomeVCH.isQuizSetAvailable()
			
			// message text
			switch quizHomeVCH.questionsType {
			
			case .definition:
				messageLabel.text = "You correctly answered \(quizHomeVCH.answeredCorrectCount) out of \(quizHomeVCH.totalQuestionsCount) available definition questions"
				
			case .term:
				messageLabel.text = "You correctly answered \(quizHomeVCH.answeredCorrectCount) out of \(quizHomeVCH.totalQuestionsCount) available term questions"
				
			case .both:
				messageLabel.text = "You correctly answered \(quizHomeVCH.answeredCorrectCount) out of \(quizHomeVCH.totalQuestionsCount) available questions"
			}
		
		}
		
		// format the progress bar
		let percentText = utilities.getPercentage(number: quizHomeVCH.answeredCorrectCount, numberTotal: quizHomeVCH.totalQuestionsCount)
		
		percentLabel.text = "\(percentText)% Done"
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor, lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: quizHomeVCH.answeredCorrectCount, totalCount: quizHomeVCH.totalQuestionsCount)
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateDisplay()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueSelectCategory:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			
			vc.categoryListVCH.categoryListMode = .selectCategory
			vc.categoryListVCH.currentCategoryID = quizHomeVCH.currentCategoryID
			
		case myConstants.segueToQuiz:
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! QuizSetVC
			
			vc.delegate = quizHomeVCH
			
			if quizHomeVCH.startNewQuiz {
				vc.quizSetVCH.quizSet = quizHomeVCH.getNewQuizSet()
			} else {
				vc.quizSetVCH.quizSet = quizHomeVCH.getQuizSet()
			}
			
		case myConstants.segueQuizOptions:
			
			let vc = segue.destination as! QuizOptionsVC
			vc.delegate = quizHomeVCH
			vc.questionsType = quizHomeVCH.questionsType
			vc.numberOfQuestions = quizHomeVCH.numberOfQuestions
			vc.isFavoriteMode = quizHomeVCH.favoritesOnly
			
		default:
			print("fatal error no matching segue in quizHomeVC prepare function")
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
	
	@IBAction func favoritesOnlyButtonAction(_ sender: Any) {
		quizHomeVCH.favoritesOnly.toggle()
		quizHomeVCH.updateData()
		updateDisplay()
	}
	
	@IBAction func termComponentSelector(_ sender: UISegmentedControl) {
		quizHomeVCH.questionsType = TermComponent.init(rawValue: sender.selectedSegmentIndex)!
		quizHomeVCH.updateData()
		updateDisplay()
	}
	
}
