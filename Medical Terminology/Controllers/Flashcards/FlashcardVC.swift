//
//  FlashCardVC2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/17/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//
// update the counter only with the Page Number calculated with the collectionView as this may not be in
// sync with the itemIndex in the collection view controller

import UIKit

class FlashcardVC: UIViewController, FlashcardHomeDelegate {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var favoritesCountLabel: UILabel!
	@IBOutlet weak var showFavoritesOnlyButton: ZUIToggleButton!
	
	@IBOutlet weak var categorySelectButton: UIButton!
	
	@IBOutlet weak var categoryNameLabel: UILabel!
	@IBOutlet weak var sliderOutlet: UISlider!
	
	@IBOutlet weak var previousButton: UIButton!
	@IBOutlet weak var randomButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	@IBOutlet weak var emptyListLabel: UILabel!
	@IBOutlet weak var emptyListImage: UIImageView!

	
	//button listing the category name
	
	var utilities = Utilities()
	
	let scrollController = ScrollController()
	let flashCardVCH = FlashcardVCH()
	
	let cc = CategoryController2()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		flashCardVCH.delegate = self
		
		scrollController.delegate = flashCardVCH
		scrollController.sideMargin = myConstants.layout_sideMargin
		scrollController.topBottomMargin = myConstants.layout_topBottomMargin
		
		collectionView.dataSource = flashCardVCH
		collectionView.delegate = scrollController
		
		// Do any additional setup after loading the view.
		
		sliderOutlet.isContinuous  = true    //output info while sliding
		sliderOutlet.minimumValue = 1
		
		//initial buttton states
		previousButton.isEnabled = false
		randomButton.isEnabled = true
		nextButton.isEnabled = true
		
		previousButton.layer.cornerRadius = myConstants.button_cornerRadius
		nextButton.layer.cornerRadius = myConstants.button_cornerRadius
		randomButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		emptyListLabel.text = myConstants.noFavoritesAvailableText
		
		updateDisplay()
	}
	
	func updateDisplay () {
		
		let favoriteCount = flashCardVCH.getFavoriteTermsCount()
		
		if favoriteCount == 0 && flashCardVCH.showFavoritesOnly {
			collectionView.isHidden = true
		} else {
			collectionView.isHidden = false
		}
		
		print("updateDisplay: setting fav button isOn = \(flashCardVCH.showFavoritesOnly)")
		
		showFavoritesOnlyButton.isOn = flashCardVCH.showFavoritesOnly
		
		print("in updateDisplay: showFavoritesonly = \(flashCardVCH.showFavoritesOnly)")
		
		favoritesCountLabel.text = "\(favoriteCount)"
		
		let c = cc.getCategory(categoryID: flashCardVCH.currentCategoryID)
		
		c.count = cc.getCountOfTerms(categoryID: flashCardVCH.currentCategoryID)
		
		let title = "  \(c.name) (\(flashCardVCH.getAllTermsCount()))"
		
		categoryNameLabel.text = title
		//configure and position the slider
		sliderOutlet.minimumValue = 0
		
		sliderOutlet.maximumValue = Float(flashCardVCH.termIDs.count - 1)
		sliderOutlet.value = Float (scrollController.getCellIndex(collectionView: collectionView))
		
		updateButtons()
		
	}
	
	func updateButtons () {
		
		previousButton.isEnabled = scrollController.isPreviouButtonEnabled(collectionView: collectionView)
		randomButton.isEnabled = scrollController.isRandomButtonEnabled(collectionView: collectionView)
		nextButton.isEnabled = scrollController.isNextButtonEnabled(collectionView: collectionView)
		
		for b in [previousButton, randomButton, nextButton] {
			
			myTheme.formatButtonState(button: b!, enabledColor: myTheme.colorFlashcardHomeButton!)
			
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueFlashcardOptions:
			let vc = segue.destination as! FlashcardOptionsVC
			vc.viewMode = flashCardVCH.viewMode
			vc.delegate = flashCardVCH
			
		case myConstants.segueSelectCatetory:
			
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! CategoryListVC
			
			vc.categoryHomeVCH.displayMode = .selectCategory
			vc.categoryHomeVCH.currentCategoryID = flashCardVCH.currentCategoryID
			
		case myConstants.segueTerm:
			let nc = segue.destination as! UINavigationController
			let vc = nc.topViewController as! TermVC
			
			//get current itemID
			let cellIndex = scrollController.getCellIndex(collectionView: collectionView)
			let termID  = flashCardVCH.termIDs[cellIndex]
			
			vc.termVCH.termID = termID
			vc.termVCH.currentCategoryID = flashCardVCH.currentCategoryID
			
			
		default:
			print("fatal error no matching segue in flashcardCV prepare function")
		}
		
	}
	

	// MARK: Delegate functions for FlashcardVCHDelegate
	
	func shouldUpdateDisplay() {
		self.updateDisplay()
	}
	
	func shouldRefreshCollectionView() {
		collectionView.reloadData()
	}
	
	func shouldRefreshCurrentCell() {
		//need to refresh cell
		let cellIndex  = scrollController.getCellIndex(collectionView: collectionView)
		collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
	}
	
	func shouldReloadCellAtIndex (termIDIndex: Int) {
		
		let indexPath = IndexPath(row: termIDIndex, section: 0)
		collectionView.reloadItems(at: [indexPath])
	}

	@IBAction func showFavoritesOnlyButtonAction(_ sender: ZUIToggleButton) {
		
		flashCardVCH.showFavoritesOnly = !flashCardVCH.showFavoritesOnly
		flashCardVCH.updateData(categoryID: flashCardVCH.currentCategoryID)
		collectionView.reloadData()
		
		updateDisplay()
	}
	
	@IBAction func sliderAction(_ sender: UISlider) {
		let sliderFloatValue = sender.value
		let sliderIntValue = Int(sliderFloatValue.rounded())
		
		//if the collectionView is not at the value of the slider scroll the collection view
		
		let currentCVIndex = scrollController.getCellIndex(collectionView: collectionView)
		
		if currentCVIndex != sliderIntValue {
			scrollController.scrollToCell(collectionView: collectionView, cellIndex: sliderIntValue, animated: false)
		}
		
		updateDisplay()
	}
	
	@IBAction func previousButtonAction(_ sender: Any) {
		scrollController.scrollPrevious(collectionView: collectionView)
	}
	
	@IBAction func randomButtonAction(_ sender: Any) {
		scrollController.scrollRandom(collectionView: collectionView)
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		scrollController.scrollNext(collectionView: collectionView)
	}
	
}

