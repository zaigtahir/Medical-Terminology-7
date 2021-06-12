//
//  LearnVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/29/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol LearnSetVCDelegate: AnyObject {
	func doneButtonPressed()
}

class LearnSetVC: UIViewController, LearningSetVCHDelegate {
	

    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    var scrollDelegate = ScrollController()
    let utilities = Utilities()
    let learnSetVCH = LearningSetVCH()
	
	weak var delegate : LearnSetVCDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollDelegate.topBottomMargin  = myConstants.layout_topBottomMargin
        scrollDelegate.sideMargin = myConstants.layout_sideMargin
        scrollDelegate.delegate = learnSetVCH
		collectionView.dataSource = learnSetVCH
        collectionView.delegate = scrollDelegate
        
        nextButton.layer.cornerRadius  = myConstants.button_cornerRadius
        previousButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        updateDisplay()
        
    }
    
    func updateDisplay() {

        updateNavigationButtons()
        
        //configure options button
        if learnSetVCH.learningSet.getQuizStatus() == .notStarted {
            optionsButton.isEnabled = false
        } else {
            optionsButton.isEnabled = true
        }
    }
    
    func updateNavigationButtons () {
        //update the status of the buttons
        previousButton.isEnabled =  scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        nextButton.isEnabled =  scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
    }
        
    func showOptionsMenu () {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restartSet = UIAlertAction(title: "Restart this set", style: .default, handler: {action in self.restartLearningSet()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(restartSet)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func restartLearningSet() {
        learnSetVCH.learningSet.resetLearningSet()
        scrollDelegate.scrollToTop(collectionView: collectionView)
        collectionView.reloadData()
        updateDisplay()
        
    }
	
	//MARK: - delegate functions for LearningSetVCHDelegate
	func shouldUpdateDisplay() {
		updateDisplay()
	}
	
	func shouldUpdateData() {
		// will add more questions to the datasource
		collectionView.reloadData()
		
		// need to do this as it makes layout changes for the additional questions.
		// I use the layout for calculating what I need in the scroll delegate so they layout needs to be done right away
		
		collectionView.layoutIfNeeded()
	}
	
	func shouldRestartSet() {
		restartLearningSet()
	}
	// END of delegate functions
	
    @IBAction func optionsButtonAction(_ sender: UIBarButtonItem) {
        showOptionsMenu()
    }
    
    @IBAction func movePreviousButtonAction(_ sender: Any) {
        scrollDelegate.scrollPrevious(collectionView: collectionView)
    }
    
    @IBAction func moveNextButtonAction(_ sender: Any) {
        scrollDelegate.scrollNext(collectionView: collectionView)
        
    }
    
	@IBAction func doneButtonAction(_ sender: Any) {
		delegate?.doneButtonPressed()
		self.dismiss(animated: true, completion: nil)
	}
}
