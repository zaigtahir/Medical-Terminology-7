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

class FlashcardVC: UIViewController, FlashcardOptionsDelegate, FlashCardVCHDelegate {
	

	func userPressedAssignCategoryButton(itemID: Int) {
		//MARK: implement
	}
	
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
	
	let scrollDelegate = ScrollController()
	let flashCardVCH = FlashCardVCH()
	let dIC  = DItemController()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		scrollDelegate.delegate = flashCardVCH
		scrollDelegate.sideMargin = myConstants.layout_sideMargin
		scrollDelegate.topBottomMargin = myConstants.layout_topBottomMargin
		
		flashCardVCH.delegate = self
		
		collectionView.dataSource = flashCardVCH
		collectionView.delegate = scrollDelegate
		
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
		
		categoryButton.setTitle(" \(flashCardVCH.currentCategory.name)", for: .normal)	//space added to pad off the button grapic a little
		
		//configure and position the slider
		sliderOutlet.minimumValue = 0
		
		sliderOutlet.maximumValue = Float(flashCardVCH.itemIDs.count - 1)
		sliderOutlet.value = Float (scrollDelegate.getCellIndex(collectionView: collectionView))
		
		favoritesLabel.text = "\(favoriteCount)"

		updateButtons()
		
	}
	
	func updateButtons () {
		
		previousButton.isEnabled = scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
		randomButton.isEnabled = scrollDelegate.isRandomButtonEnabled(collectionView: collectionView)
		nextButton.isEnabled = scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
		
		for b in [previousButton, randomButton, nextButton] {
			
			myTheme.formatButtonColor(button: b!, enabledColor: myTheme.colorFlashcardHomeButton!)
			
		}}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == myConstants.segueFlashcardOptions {
			let vc = segue.destination as! FlashCardOptionsVC
			vc.viewMode = flashCardVCH.viewMode
			vc.delegate = self
		} else if segue.identifier == myConstants.segueSelectCatetory {
			let vc = segue.destination as! CategoryHomeVC
			vc.delegate = flashCardVCH
			
		} else {
			if isDevelopmentMode {
				print ("no matching segue found: error state in FlashCardHomeVC prepare")
			}
		}
		
	}
	
	func flashCardViewModeChanged(fcvMode: FlashcardViewMode) {
		flashCardVCH.viewMode = fcvMode
		
		//need to refresh cell
		let cellIndex  = scrollDelegate.getCellIndex(collectionView: collectionView)
		collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
	}
	
	// MARK: Delegate functions for FlashcardVCHDelegate
	
	func updateHomeDisplay() {
		self.updateDisplay()
	}
	
	func refreshCollectionView() {
		collectionView.reloadData()
	}
	
	//update options
	
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
		
		let currentCVIndex = scrollDelegate.getCellIndex(collectionView: collectionView)
		
		if currentCVIndex != sliderIntValue {
			scrollDelegate.scrollToCell(collectionView: collectionView, cellIndex: sliderIntValue, animated: false)
		}
		
		updateDisplay()
	}
	
	@IBAction func previousButtonAction(_ sender: Any) {
		scrollDelegate.scrollPrevious(collectionView: collectionView)
	}
	
	@IBAction func randomButtonAction(_ sender: Any) {
		scrollDelegate.scrollRandom(collectionView: collectionView)
	}
	
	@IBAction func nextButtonAction(_ sender: Any) {
		scrollDelegate.scrollNext(collectionView: collectionView)
	}
	
}

