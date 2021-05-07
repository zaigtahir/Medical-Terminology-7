//
//  LearnHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class LearningHomeVC: UIViewController, LearningHomeVCHDelegate {
	
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
	
	let learningHomeVCH = LearningHomeVCH()
	let utilities = Utilities()
	var progressBar: CircularBar!
	
	private let cc = CategoryController2()
	
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
		
		favoritesOnlyButton.isOn = learningHomeVCH.favoritesOnly
		
		favoritesCountLabel.text = "\(learningHomeVCH.favoriteTermsCount)"
		
		let c = cc.getCategory(categoryID: learningHomeVCH.currentCategoryID)
		
		categoryNameLabel.text = "\(c.name) (\(learningHomeVCH.categoryTermsCount))"
		
		let foregroundColor = myTheme.colorLhPbForeground?.cgColor
		let backgroundColor = myTheme.colorLhPbBackground?.cgColor
		let fillColor = UIColor.systemBackground.cgColor
		
		if learningHomeVCH.categoryTermsCount == 0 {
			// no terms available in this category
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noTermsHeading
			messageLabel.text = myConstants.noTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
			
			
		} else if learningHomeVCH.favoritesOnly && learningHomeVCH.favoriteTermsCount == 0 {
			
			percentLabel.isHidden = true
			redoButton.isHidden = true
			infoIcon.isHidden = false
			headingLabel.isHidden = false
			
			headingLabel.text = myConstants.noFavoriteTermsHeading
			messageLabel.text = myConstants.noFavoriteTermsSubheading
			
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
			
		} else {
			
			// some terms available
			percentLabel.isHidden = false
			
			if learningHomeVCH.learnedTermsCount > 0 {
				redoButton.isHidden = false
			} else {
				redoButton.isHidden = true
			}
			
			headingLabel.isHidden = true
			infoIcon.isHidden = true
			
			if learningHomeVCH.favoritesOnly {
				messageLabel.text = "You have learned \(learningHomeVCH.learnedTermsCount) out of \(learningHomeVCH.totalTermsCount) favorite terms."
				
			} else {
				messageLabel.text = "You have learned \(learningHomeVCH.learnedTermsCount) out of \(learningHomeVCH.totalTermsCount) terms."
			}
		
			newSetButton.isEnabled = false
			seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
		}
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor
								  , lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: learningHomeVCH.learnedTermsCount, totalCount: learningHomeVCH.totalTermsCount)
		
		let percentText = utilities.getPercentage(number: learningHomeVCH.learnedTermsCount, numberTotal: learningHomeVCH.totalTermsCount)
		
		percentLabel.text = "\(percentText)% DONE"
		
		
		if learningHomeVCH.learnedTermsCount == 0 {
			redoButton.isEnabled = false
		} else {
			redoButton.isEnabled = true
		}
		
		updateButtons()
	}
	
	private func updateButtons() {
		
		if learningHomeVCH.totalTermsCount - learningHomeVCH.learnedTermsCount > 0 {
			newSetButton.isEnabled = true
		} else {
			newSetButton.isEnabled = false
		}
		
		//enable state of see current set
		seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueLearningSet:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! LearnSetVC
			
			vc.delegate = learningHomeVCH
			
			if learningHomeVCH.startNewSet {
				vc.learnSetVCH.learningSet = learningHomeVCH.getNewLearningSet()
				
				
			} else {
				vc.learnSetVCH.learningSet = learningHomeVCH.getLearningSet()
			}
		case myConstants.segueLearningOptions:
			
			let vc = segue.destination as! LearningHomeOptionsVC
			vc.delegate = learningHomeVCH   //assigning the VCH to the options as it's delegate
			vc.isFavoriteMode = learningHomeVCH.favoritesOnly
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
	
	@IBAction func favoritesOnlyButton(_ sender: ZUIToggleButton) {
		learningHomeVCH.favoritesOnly.toggle()
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
