//
//  LearnHomeVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 7/10/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

class LearningHomeVC: UIViewController {
	
	// from quizHome
	@IBOutlet weak var favoritesLabel: UILabel!
	@IBOutlet weak var favoritesSwitch: UISwitch!
	@IBOutlet weak var percentLabel: UILabel!
	@IBOutlet weak var circleBarView: UIView!
	@IBOutlet weak var redoButton: UIButton!
	@IBOutlet weak var newSetButton: UIButton!
	@IBOutlet weak var seeCurrentSetButton: UIButton!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var heartImage: UIImageView!
	@IBOutlet weak var optionsButton: UIBarButtonItem!
	
	let learningHomeVCH = LearningHomeVCH()
	private let dIC = DItemController()
	private let utilities = Utilities()
	var progressBar: CircularBar!
	
	//button colors
	let enabledButtonColor = myTheme.colorQuizButton
	
	override func viewDidLoad() {
		super.viewDidLoad()
		favoritesSwitch.layer.cornerRadius = 16
		favoritesSwitch.onTintColor = myTheme.colorFavorite
		
		newSetButton.layer.cornerRadius = myConstants.button_cornerRadius
		seeCurrentSetButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		//redraw the progress bar
		updateDisplay()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		favoritesSwitch.isOn = learningHomeVCH.isFavoriteMode
		updateDisplay()
	}
	
	private func updateDisplay () {
		
		let favoritesCount = dIC.getCount(favoriteState: 1)
		
		favoritesSwitch.isOn = learningHomeVCH.isFavoriteMode
		
		favoritesLabel.text = "\(favoritesCount)"
		messageLabel.text = learningHomeVCH.getMessageText()
		
		if learningHomeVCH.isFavoriteMode && favoritesCount == 0 {
			
			//isFavorite = true, but the user has not selected any favorites
			circleBarView.isHidden = true
			percentLabel.isHidden = true
			heartImage.isHidden = false
			redoButton.isHidden = true
			newSetButton.isEnabled = false
			return
		} else {
			circleBarView.isHidden = false
			percentLabel.isHidden = false
			heartImage.isHidden = true
			messageLabel.isHidden = false
			heartImage.isHidden = true
		}
		
		let counts = learningHomeVCH.getCounts()
		
		
		let foregroundColor = myTheme.colorLhPbForeground?.cgColor
		let backgroundColor = myTheme.colorLhPbBackground?.cgColor
		let fillColor =  myTheme.colorLhPbFill?.cgColor
		
		progressBar = CircularBar(referenceView: circleBarView, foregroundColor: foregroundColor!, backgroundColor: backgroundColor!, fillColor: fillColor!
								  , lineWidth: myTheme.progressBarWidth)
		
		progressBar.setStrokeEnd(partialCount: counts.learnedTerms, totalCount: counts.totalTerms)
		
		let percentText = utilities.getPercentage(number: counts.learnedTerms, numberTotal: counts.totalTerms)
		
		percentLabel.text = "\(percentText)% DONE"
		messageLabel.text = learningHomeVCH.getMessageText()
		
		if counts.learnedTerms == 0 {
			redoButton.isEnabled = false
		} else {
			redoButton.isEnabled = true
		}
		
		if counts.availableToLearn > 0 {
			newSetButton.isEnabled = true
		} else {
			newSetButton.isEnabled = false
		}
		
		//enable state of see current set
		seeCurrentSetButton.isEnabled = learningHomeVCH.isLearningSetAvailable()
		
		for b in [seeCurrentSetButton, newSetButton] {
			myTheme.formatButtonColor(button: b!, enabledColor: enabledButtonColor!)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "segueToLearningSet" {
			let vc = segue.destination as! LearnSetVC
			
			if learningHomeVCH.startNewSet {
				vc.learnSetVCH.learningSet = learningHomeVCH.getNewLearningSet()
				
			} else {
				vc.learnSetVCH.learningSet = learningHomeVCH.getLearningSet()
			}
		}
		
		if segue.identifier == "segueToLearningHomeOptions" {
			let vc = segue.destination as! LearningHomeOptionsVC
			vc.delegate = learningHomeVCH   //assigning the VCH to the options as it's delegate
			vc.isFavoriteMode = learningHomeVCH.isFavoriteMode
			vc.numberOfTerms = learningHomeVCH.numberOfTerms
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
	
	@IBAction func redoButtonAction(_ sender: UIButton) {
		confirmRestart()
	}
	
	@IBAction func favoritesSwitchChanged(_ sender: UISwitch) {
		learningHomeVCH.isFavoriteMode = sender.isOn
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
	
}
