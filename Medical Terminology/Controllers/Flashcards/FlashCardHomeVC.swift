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

class FlashCardHomeVC: UIViewController, UICollectionViewDataSource, CVCellChangedDelegate, FCFavoritePressedDelegate, FCVModeChangedDelegate, CategoryChangedDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var favoritesSwitch: UISwitch!
    @IBOutlet weak var sliderOutlet: UISlider!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    
    @IBOutlet weak var categoryLabelButton: UIButton!   //button listing the category name
    
    var utilities = Utilities()
    
    let scrollDelegate = CVScrollController()
    let flashCardVCH = FlashCardVCH()
    let dIC  = DItemController()
    
    //button colors
    let enabledButtonColor = myTheme.color_fch_button
    let enabledButtonTint = myTheme.colorButtonEnabledTint
    let disabledButtonColor = myTheme.colorButtonDisabled
    let disabledButtonTint = myTheme.colorButtonDisabledTint
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollDelegate.delegate = self
        scrollDelegate.sideMargin = myConstants.layout_sideMargin
        scrollDelegate.topBottomMargin = myConstants.layout_topBottomMargin
        
        collectionView.dataSource = self
        collectionView.delegate = scrollDelegate
        
        // Do any additional setup after loading the view.
        
        sliderOutlet.isContinuous  = true    //output info while sliding
        sliderOutlet.minimumValue = 1
        
        //initial buttton states
        previousButton.isEnabled = false
        randomButton.isEnabled = true
        nextButton.isEnabled = true
        
        favoritesSwitch.layer.cornerRadius = 16
        favoritesSwitch.isOn = flashCardVCH.getFavoriteMode()
        favoritesSwitch.onTintColor = myTheme.colorFavorite
        
        previousButton.layer.cornerRadius = myConstants.button_cornerRadius
        nextButton.layer.cornerRadius = myConstants.button_cornerRadius
        randomButton.layer.cornerRadius = myConstants.button_cornerRadius
        
        noFavoritesLabel.text = myConstants.noFavoritesAvailableText
        updateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if flashCardVCH.getFavoriteMode() {
            //if favorite mode, update the display incase the favorites were changed in another tab
            updateDisplay()
        }
        
    }
    
    //MARK: - DataSourceFunctions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if flashCardVCH.getFavoriteMode(){
            return flashCardVCH.listFavorite.count
        } else {
            return flashCardVCH.listFull.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flashCardCell", for: indexPath) as! FlashCardCVCell
        var flashCardList: [Int]
        
        if flashCardVCH.getFavoriteMode() {
            flashCardList = flashCardVCH.listFavorite
        } else {
            flashCardList = flashCardVCH.listFull
        }
        
        //the cell should configure itself
        let dItem  = dIC.getDItem(itemID: flashCardList[indexPath.row])
        let countText = "Flashcard: \(indexPath.row + 1) of \(flashCardList.count)"
        cell.configure(dItem: dItem, fcvMode: flashCardVCH.viewMode, counter: countText)
        cell.delegate = self
        return cell
    }
    
    func updateDisplay () {
        
        let favoriteCount = dIC.getCount(favoriteState: 1) // get live count
        
        if favoriteCount == 0 && flashCardVCH.getFavoriteMode() {
            collectionView.isHidden = true
        } else {
            collectionView.isHidden = false
        }
        
        //configure and position the slider
        sliderOutlet.minimumValue = 0
        
        if flashCardVCH.getFavoriteMode() {
            sliderOutlet.maximumValue = Float(flashCardVCH.listFavorite.count - 1)
        } else {
            sliderOutlet.maximumValue  = Float(flashCardVCH.listFull.count - 1)
        }
        
        sliderOutlet.value = Float (scrollDelegate.getCellIndex(collectionView: collectionView))
        favoritesLabel.text = "\(favoriteCount)"
        
        updateButtons()
        
    }
    
    func updateButtons () {
        
        previousButton.isEnabled = scrollDelegate.isPreviouButtonEnabled(collectionView: collectionView)
        randomButton.isEnabled = scrollDelegate.isRandomButtonEnabled(collectionView: collectionView)
        nextButton.isEnabled = scrollDelegate.isNextButtonEnabled(collectionView: collectionView)
        
        for b in [previousButton, randomButton, nextButton] {
            utilities.formatButtonColor(button: b!, enabledBackground: enabledButtonColor!, enabledTint: enabledButtonTint!, disabledBackground: disabledButtonColor!, disabledTint: disabledButtonTint!)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueFCOptions" {
            let vc = segue.destination as! FlashCardOptionsVC
            vc.viewMode = flashCardVCH.viewMode
            vc.delegate = self
        } else if segue.identifier == myConstants.segue_catetories {
            let vc = segue.destination as! CategoryHomeVC
            vc.delegate = self
        } else {
            if isDevelopmentMode {
                print ("no matching segue found: error state in FlashCardHomeVC prepare")
            }
        }
        
    }
    
    // MARK: Delegate functions
    func categoryChanged(categoryID: Int, categoryName: String) {
        print("here")
        categoryLabelButton.setTitle(categoryName, for: .normal)
    }
    
    func CVCellChanged(cellIndex: Int) {
        updateDisplay()
    }
    
    func CVCellDragging(cellIndex: Int) {
        // here to meet the delegate requirement, but will not be using this function here
    }
    
    func userPressedFavoriteButton(itemID: Int) {
        dIC.toggleFavorite (itemID: itemID)
        updateDisplay()
    }
    
    func flashCardViewModeChanged(fcvMode: FlashCardViewMode) {
        flashCardVCH.viewMode = fcvMode
        
        //need to refresh cell
        let cellIndex  = scrollDelegate.getCellIndex(collectionView: collectionView)
        collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
    }
    
    //update options
    
    @IBAction func favoritesSwitchChanged(_ sender: UISwitch) {
        flashCardVCH.setFavoriteMode(isFavoriteMode: sender.isOn)
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
    
    @IBAction func categoryLabelButtonAction(_ sender: UIButton) {
        
        performSegue(withIdentifier: myConstants.segue_catetories , sender: self)
    }
}
