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

class FlashcardVC: UIViewController, FlashCardVCHDelegate {
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var favoritesLabel: UILabel!
	@IBOutlet weak var favoritesSwitch: UISwitch!
	@IBOutlet weak var sliderOutlet: UISlider!
	@IBOutlet weak var previousButton: UIButton!
	@IBOutlet weak var randomButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	@IBOutlet weak var emptyListLabel: UILabel!
	@IBOutlet weak var emptyListImage: UIImageView!
	
	@IBOutlet weak var categoryButton: UIButton!
	
	//button listing the category name
	
	var utilities = Utilities()
	
	let scrollController = ScrollController()
	let flashCardVCH = FlashcardVCH()
	let dIC = DItemController3()
	let cController = CategoryController()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		
		
		scrollController.delegate = flashCardVCH
		scrollController.sideMargin = myConstants.layout_sideMargin
		scrollController.topBottomMargin = myConstants.layout_topBottomMargin
		
		flashCardVCH.delegate = self
		
		collectionView.dataSource = flashCardVCH
		collectionView.delegate = scrollController
		
		// Do any additional setup after loading the view.
		
		sliderOutlet.isContinuous  = true    //output info while sliding
		sliderOutlet.minimumValue = 1
		
		//initial buttton states
		previousButton.isEnabled = false
		randomButton.isEnabled = true
		nextButton.isEnabled = true
		
		favoritesSwitch.layer.cornerRadius = 16
		favoritesSwitch.isOn = flashCardVCH.showFavoritesOnly
		favoritesSwitch.onTintColor = myTheme.colorFavorite
		
		previousButton.layer.cornerRadius = myConstants.button_cornerRadius
		nextButton.layer.cornerRadius = myConstants.button_cornerRadius
		randomButton.layer.cornerRadius = myConstants.button_cornerRadius
		
		emptyListLabel.text = myConstants.noFavoritesAvailableText
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		updateDisplay()
	}
	
	func updateDisplay () {
		
		let favoriteCount = flashCardVCH.getFavoriteCount()
		
		if favoriteCount == 0 && flashCardVCH.showFavoritesOnly {
			collectionView.isHidden = true
		} else {
			collectionView.isHidden = false
		}
		
		let cbuttonTitle = " \(flashCardVCH.currentCategory.name) (\( cController.getItemCountInCategory(categoryID: flashCardVCH.currentCategory.categoryID)))"
		
		categoryButton.setTitle(cbuttonTitle, for: .normal)	//space added to pad off the button grapic a little
		
		//configure and position the slider
		sliderOutlet.minimumValue = 0
		
		sliderOutlet.maximumValue = Float(flashCardVCH.itemIDs.count - 1)
		sliderOutlet.value = Float (scrollController.getCellIndex(collectionView: collectionView))
		
		favoritesLabel.text = "\(favoriteCount)"
		
		updateButtons()
		
	}
	
	func updateButtons () {
		
		previousButton.isEnabled = scrollController.isPreviouButtonEnabled(collectionView: collectionView)
		randomButton.isEnabled = scrollController.isRandomButtonEnabled(collectionView: collectionView)
		nextButton.isEnabled = scrollController.isNextButtonEnabled(collectionView: collectionView)
		
		for b in [previousButton, randomButton, nextButton] {
			myTheme.formatButtonColor(button: b!, enabledColor: myTheme.colorFlashcardHomeButton!)
		}
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		switch segue.identifier {
		
		case myConstants.segueFlashcardOptions:
			let vc = segue.destination as! FlashcardOptionsVC
			vc.viewMode = flashCardVCH.viewMode
			vc.delegate = flashCardVCH
			
		case myConstants.segueSelectCatetory:
			let vc = segue.destination as! CategoryHomeVC
			vc.categoryHomeVCH.displayMode = .selectCategory
			vc.delegate = flashCardVCH
			
		case myConstants.segueAssignCategory:
			let vc = segue.destination as! CategoryHomeVC
			vc.categoryHomeVCH.displayMode = .assignCategory
			vc.categoryHomeVCH.itemID = 2	//just testing
			//get current itemID
			
			let cellIndex = scrollController.getCellIndex(collectionView: collectionView)
			let itemID  = flashCardVCH.itemIDs[cellIndex]
		
			vc.categoryHomeVCH.itemID = itemID
			
		default:
			print("fatal error no matching segue in flashcardCV prepare function")
		}

	}
	
	// MARK: Delegate functions for FlashcardVCHDelegate
	
	func updateHomeDisplay() {
		self.updateDisplay()
	}
	
	func refreshCollectionView() {
		collectionView.reloadData()
	}
	
	func refreshCurrentCell() {
		//need to refresh cell
		let cellIndex  = scrollController.getCellIndex(collectionView: collectionView)
		collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
	}

	
	@IBAction func favoritesSwitchChanged(_ sender: UISwitch) {
		flashCardVCH.showFavoritesOnly = sender.isOn
		flashCardVCH.makeList()
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

