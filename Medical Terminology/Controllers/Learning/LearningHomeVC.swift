//
//  LearnHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class LearningHomeVC: UIViewController, LearningHomeVCHDelegate {

	// from quizHome
	@IBOutlet weak var showFavoritesOnlyButton: ZUIToggleButton!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var categorySelectButton: UIButton!
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var circleBarView: UIView!
	@IBOutlet weak var redoButton: UIButton!
	@IBOutlet weak var newSetButton: UIButton!
	@IBOutlet weak var seeCurrentSetButton: UIButton!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var optionsButton: UIBarButtonItem!
	@IBOutlet weak var mainStack: UIStackView!
	@IBOutlet weak var noTermsView: UIView!
	
	let learningHomeVCH = LearningHomeVCH()
	
	private let utilities = Utilities()
	var progressBar: CircularBar!
	
	private let cc = CategoryController2()

	//button colors
	let enabledButtonColor = myTheme.colorQuizButton
	
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
		
		learningHomeVCH.delegate = self
		learningHomeVCH.updateData()
		updateDisplay()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	private func updateDisplay () {
		
		showFavoritesOnlyButton.isOn = learningHomeVCH.showFavoritesOnly
		
		favoritesCountLabel.text = "\(learningHomeVCH.favoriteTermsCount)"
		
		let c = cc.getCategory(categoryID: learningHomeVCH.currentCategoryID)
				
		categoryNameLabel.text = "\(c.name) (\(cc.getCountOfTerms(categoryID: c.categoryID)))"
		
		// no terms available
		if learningHomeVCH.totalTermsCount == 0 {
			mainStack.isHidden = true
			noTermsView.isHidden = false
			
			return
		}
		
		// no favorite terms available
		if learningHomeVCH.showFavoritesOnly && learningHomeVCH.favoriteTermsCount == 0 {
			mainStack.isHidden = true
			noTermsView.isHidden = false
		
			return
		}
	
		// some terms available
		mainStack.isHidden = false
		noTermsView.isHidden = true
		
		if learningHomeVCH.showFavoritesOnly {
			messageLabel.text = "You have learned \(learningHomeVCH.learnedTermsCount) out of \(learningHomeVCH.totalTermsCount) favorite terms."
			print ("here")
			
		} else {
			messageLabel.text = "You have learned \(learningHomeVCH.learnedTermsCount) out of \(learningHomeVCH.totalTermsCount) terms."
			print ("here")
		}
		
		
	
		
		
		
		
		/*
		
		if learningHomeVCH.showFavoritesOnly && learningHomeVCH.favoriteTermsCount == 0 {
			
			//isFavorite = true, but the user has not selected any favorites
			circleBarView.isHidden = true
			percentLabel.isHidden = true
			redoButton.isHidden = true
			newSetButton.isEnabled = false
			return
			
		} else {
			circleBarView.isHidden = false
			percentLabel.isHidden = false
			messageLabel.isHidden = false
		}
		*/
		
		let foregroundColor = myTheme.colorLhPbForeground?.cgColor
		let backgroundColor = myTheme.colorLhPbBackground?.cgColor
		let fillColor =  myTheme.colorLhPbFill?.cgColor
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!
								  , lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: learningHomeVCH.learnedTermsCount, totalCount: learningHomeVCH.totalTermsCount)
		
		let percentText = utilities.getPercentage(number: learningHomeVCH.learnedTermsCount, numberTotal: learningHomeVCH.totalTermsCount)
		
		percentLabel.text = "\(percentText)% DONE"
		
		
		
		
		
		
		
		if learningHomeVCH.learnedTermsCount == 0 {
			redoButton.isEnabled = false
		} else {
			redoButton.isEnabled = true
		}
		
		if learningHomeVCH.totalTermsCount - learningHomeVCH.learnedTermsCount > 0 {
			newSetButton.isEnabled = true
		} else {
			newSetButton.isEnabled = false
		}
		
		//enable state of see current set
		seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
		
		for b in [seeCurrentSetButton, newSetButton] {
			myTheme.formatButtonState(button: b!, enabledColor: enabledButtonColor!)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueLearningSet:
			
			let vc = segue.destination as! LearnSetVC
			
			if learningHomeVCH.startNewSet {
				vc.learnSetVCH.learningSet = learningHomeVCH.getNewLearningSet()
				
			} else {
				vc.learnSetVCH.learningSet = learningHomeVCH.getLearningSet()
			}
		case myConstants.segueLearningOptions:
			
			let vc = segue.destination as! LearningHomeOptionsVC
			vc.delegate = learningHomeVCH   //assigning the VCH to the options as it's delegate
			vc.isFavoriteMode = learningHomeVCH.showFavoritesOnly
			vc.numberOfTerms = learningHomeVCH.numberOfTerms
		
		case myConstants.segueSelectCategory:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			
			vc.categoryListVCH.categoryListMode = .selectCategory
			vc.categoryListVCH.currentCategoryID = learningHomeVCH.currentCategoryID
			
			
		default:
			print("Fatal error got an unexpected segue in LearningHomeVC")
		}
		
	}
	
	func confirmRestart () {
		
		let alert = UIAlertController(title: "Restart Learning", message: "Are you sure you want to clear the learned terms and start over?", preferredStyle: .actionSheet)
		
		let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
										action in self.restartNow()})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
		
		alert.addAction(yesAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	func restartNow() {
		learningHomeVCH.restartOver()
		updateDisplay()
	}
	
	// MARK: - LearningHomeVCHDelegate
	
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	@IBAction func redoButtonAction(_ sender: UIButton) {
		confirmRestart()
	}
	
	@IBAction func showFavoritesOnlyButton(_ sender: ZUIToggleButton) {
		learningHomeVCH.showFavoritesOnly.toggle()
		learningHomeVCH.updateData()
		updateDisplay()
	}
	
	@IBAction func optionsButtonAction(_ sender: Any) {
		performSegue(withIdentifier: "segueToLearningHomeOptions", sender: nil)
	}
	
	@IBAction func startNewSetButtonAction(_ sender: Any) {
		//will manually segue
		learningHomeVCH.startNewSet = true
		performSegue(withIdentifier: "segueToLearningSet", sender: nil)
		
	}
	
	@IBAction func seeCurrentSetButtonAction(_ sender: Any) {
		//will manually segue
		learningHomeVCH.startNewSet = false
		performSegue(withIdentifier: "segueToLearningSet", sender: nil)
	}
	
	@IBAction func categorySelectButtonAction(_ sender: Any) {
	}
	
	
}
