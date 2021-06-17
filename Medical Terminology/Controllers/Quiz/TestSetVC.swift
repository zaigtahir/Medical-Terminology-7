//
//  TestSetVC.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 8/5/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol TestSetVCDelegate: AnyObject {
	func doneButtonPressed()
}

class TestSetVC: UIViewController, TestSetVCHDelegate {
	
    @IBOutlet weak var previousButton: ZUIRoundedButton!
    @IBOutlet weak var nextButton: ZUIRoundedButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var restartButton: UIBarButtonItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    var scrollDelegate = ScrollController()
    let testSetVCH = TestSetVCH()
    let utilities = Utilities()
	
	weak var delegate : TestSetVCDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollDelegate.topBottomMargin  = myConstants.layout_topBottomMargin
        scrollDelegate.sideMargin = myConstants.layout_sideMargin
        scrollDelegate.delegate = testSetVCH
        
        collectionView.dataSource = testSetVCH
        collectionView.delegate = scrollDelegate
		
		testSetVCH.delegate = self
        
        nextButton.layer.cornerRadius  = myConstants.button_cornerRadius
        previousButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        updateDisplay()
        
    }
    
    func updateDisplay () {
        //configure options button
        if testSetVCH.testSet.getTestStatus() == .notStarted {
			restartButton.isEnabled = false
        } else {
			restartButton.isEnabled = true
        }
        
        //update counter
        
        updateNavigationButtons()
    }
    
    func updateNavigationButtons () {
        //update the status of the buttons
        previousButton.isEnabled =  scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        nextButton.isEnabled =  scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
    }

    func showOptionsMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let restartTest = UIAlertAction(title: "Restart This Test", style: .default, handler: {action in self.restartTest()})
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(restartTest)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func restartTest() {
        testSetVCH.testSet.resetTestSet()
        scrollDelegate.scrollToTop(collectionView: collectionView)
        collectionView.reloadData()
        updateDisplay()
    }
    
	//MARK: - delegate functions for TestSetVCHDelegate
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
	
	func shouldRestartTest() {
		restartTest()
	}
	// END of delegate functions
	
	
    @IBAction func movePreviousButtonAction(_ sender: Any) {
        scrollDelegate.scrollPrevious(collectionView: collectionView)
    }
    
    @IBAction func moveNextButtonAction(_ sender: Any) {
        scrollDelegate.scrollNext(collectionView: collectionView)
    }
    
    @IBAction func restartButtonAction(_ sender: UIBarButtonItem) {
        showOptionsMenu()
    }
	
	@IBAction func doneButtonAction(_ sender: Any) {
		delegate?.doneButtonPressed()
		self.dismiss(animated: true, completion: nil)
	}
	
}


