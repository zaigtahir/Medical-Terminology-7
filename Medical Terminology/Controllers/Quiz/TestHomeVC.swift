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
	
	private let testHomeVCH = TestHomeVCH()
	private let utilities = Utilities()
	private var progressBar: CircularBar!
	
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
		
		favoritesOnlyButton.isOn = testHomeVCH.showFavoritesOnly
		
		favoritesCountLabel.text = "\(testHomeVCH.favoriteTermsCount)"
		
		
		
		if testHomeVCH.currentCategoryIDs.count == 1 {
			
			let c = cc.getCategory(categoryID: testHomeVCH.currentCategoryIDs[0])
			
			categoryNameLabel.text = "\(c.name) (\(testHomeVCH.categoryTermsCount) terms)"
			
		} else {
			
			categoryNameLabel.text = "\(testHomeVCH.currentCategoryIDs.count) categories selected (\(testHomeVCH.categoryTermsCount) terms)"
		}
		
		
		
		if testHomeVCH.categoryTermsCount == 0 {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noTermsHeading
			messageLabel.text = myConstants.noTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = testHomeVCH.isTestSetAvailable()
	
			
		} else if (testHomeVCH.showFavoritesOnly && testHomeVCH.favoriteTermsCount == 0) {
			
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
		let foregroundColor = myTheme.colorTestPbForeground?.cgColor
		let backgroundColor = myTheme.colorTestPbBackground.cgColor
		let fillColor = myTheme.colorTestPbFillcolor?.cgColor
		
		let percentText = utilities.getPercentage(number: testHomeVCH.answeredCorrectCount, numberTotal: testHomeVCH.totalQuestionsCount)
		
		percentLabel.text = "\(percentText)% Done"
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor, fillColor: fillColor!, lineWidth: myTheme.progressBarWidth)
		
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
			
			vc.categoryListVCH.setupSelectCategoryMode(initialCategories: testHomeVCH.currentCategoryIDs)
			
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
			vc.numberOfQuestions = testHomeVCH.numberOfQuestions
			
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
		testHomeVCH.showFavoritesOnly.toggle()
		testHomeVCH.updateData()
		updateDisplay()
	}
	
	@IBAction func termComponentSelector(_ sender: UISegmentedControl) {
		testHomeVCH.questionsType = TermComponent.init(rawValue: sender.selectedSegmentIndex)!
		testHomeVCH.updateData()
		updateDisplay()
	}
	
}
