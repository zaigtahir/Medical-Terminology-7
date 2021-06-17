//
//  TestHome.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//


import UIKit

class TestHomeVC: UIViewController, TestHomeVCHDelegate {
	
	@IBOutlet weak var favoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var circleBarView: UIView!
	@IBOutlet weak var infoIcon: UILabel!
	@IBOutlet weak var redoButton: UIButton!
	@IBOutlet weak var newSetButton: UIButton!
	@IBOutlet weak var seeCurrentSetButton: UIButton!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var optionsButton: UIBarButtonItem!
	@IBOutlet weak var headingLabel: UILabel!
	
	let testHomeVCH = TestHomeVCH()
	let utilities = Utilities()
	var progressBar: CircularBar!
	
	private let cc = CategoryController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
		
		testHomeVCH.delegate = self
		
		percentLabel.textColor = myTheme.colorButtonText
		
		updateDisplay()
		
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	private func updateDisplay () {
		
		favoritesOnlyButton.isOn = testHomeVCH.favoritesOnly
		
		favoritesCountLabel.text = "\(testHomeVCH.favoriteTermsCount)"
		
		let c = cc.getCategory(categoryID: testHomeVCH.currentCategoryID)
		
		categoryNameLabel.text = "\(c.name) (\(testHomeVCH.categoryTermsCount))"
		
		if testHomeVCH.categoryTermsCount == 0 {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noTermsHeading
			messageLabel.text = myConstants.noTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = testHomeVCH.isTestSetAvailable()
	
			
		} else if (testHomeVCH.favoritesOnly && testHomeVCH.favoriteTermsCount == 0) {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noFavoriteTermsHeading
			messageLabel.text = myConstants.noFavoriteTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = testHomeVCH.isTestSetAvailable()
			
		} else {
			
			// some terms available
			percentLabel.isHidden = false
			
			if testHomeVCH.answeredCorrectCount > 0 {
				redoButton.isHidden = false
			} else {
				redoButton.isHidden = true
			}
			
			infoIcon.isHidden = true
			headingLabel.isHidden = true
			
			newSetButton.isEnabled = true
			seeCurrentSetButton.isEnabled = testHomeVCH.isTestSetAvailable()
			
			// message text
			switch testHomeVCH.questionsType {
			
			case .definition:
				messageLabel.text = "You correctly answered \(testHomeVCH.answeredCorrectCount) out of \(testHomeVCH.totalQuestionsCount) available definition questions"
				
			case .term:
				messageLabel.text = "You correctly answered \(testHomeVCH.answeredCorrectCount) out of \(testHomeVCH.totalQuestionsCount) available term questions"
				
			case .both:
				messageLabel.text = "You correctly answered \(testHomeVCH.answeredCorrectCount) out of \(testHomeVCH.totalQuestionsCount) available questions"
			}
		
		}
		
		// format the progress bar
		let foregroundColor = myTheme.colorPbTestForeground?.cgColor
		let backgroundColor = myTheme.colorPbTestBackground?.cgColor
		let fillColor = myTheme.colorPbTestFillcolor?.cgColor
		
		let percentText = utilities.getPercentage(number: testHomeVCH.answeredCorrectCount, numberTotal: testHomeVCH.totalQuestionsCount)
		
		percentLabel.text = "\(percentText)% Done"
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!, lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: testHomeVCH.answeredCorrectCount, totalCount: testHomeVCH.totalQuestionsCount)
		
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
			vc.categoryListVCH.currentCategoryID = testHomeVCH.currentCategoryID
			
		case myConstants.segueToTest:
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! TestSetVC
			
			vc.delegate = testHomeVCH
			
			if testHomeVCH.startNewTest {
				vc.testSetVCH.testSet = testHomeVCH.getNewTestSet()
			} else {
				vc.testSetVCH.testSet = testHomeVCH.getTestSet()
			}
			
		case myConstants.segueTestOptions:
			
			let vc = segue.destination as! TestOptionsVC
			vc.delegate = testHomeVCH
			vc.questionsType = testHomeVCH.questionsType
			vc.numberOfQuestions = testHomeVCH.numberOfQuestions
			vc.isFavoriteMode = testHomeVCH.favoritesOnly
			
		default:
			print("fatal error no matching segue in testHomeVC prepare function")
		}
		
	}
	
	func confirmRestart () {
		
		let alert = UIAlertController(title: "Redo Test Questions", message: "Are you sure you want to clear the answers to these questions and redo them?", preferredStyle: .actionSheet)
		
		let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
										action in self.restartNow()})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	func restartNow() {
		testHomeVCH.restartOver()
		updateDisplay()
	}
	
	// MARK: - TestHomeVCHDelegate functions
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	@IBAction func optionsButtonAction(_ sender: Any) {
		performSegue(withIdentifier: "segueTestOptions", sender: nil)
	}
	
	@IBAction func redoButtonAction(_ sender: Any) {
		confirmRestart()
	}
	
	@IBAction func newTestButtonAction(_ sender: UIButton) {
		testHomeVCH.startNewTest = true
		performSegue(withIdentifier: "segueToTest", sender: nil)
	}
	
	@IBAction func currentTestButtonAction(_ sender: Any) {
		//will manually segue
		testHomeVCH.startNewTest  = false
		performSegue(withIdentifier: "segueToTest", sender: nil)
	}
	
	@IBAction func favoritesOnlyButtonAction(_ sender: Any) {
		testHomeVCH.favoritesOnly.toggle()
		testHomeVCH.updateData()
		updateDisplay()
	}
	
	@IBAction func termComponentSelector(_ sender: UISegmentedControl) {
		testHomeVCH.questionsType = TermComponent.init(rawValue: sender.selectedSegmentIndex)!
		testHomeVCH.updateData()
		updateDisplay()
	}
	
}
