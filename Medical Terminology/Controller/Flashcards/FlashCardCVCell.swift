//
//  CollectionCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/17/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit

protocol FCFavoritePressedDelegate: AnyObject {
    func userPressedFavoriteButton(itemID: Int)
}

class FlashCardCVCell: UICollectionViewCell {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var showHiddenTermButton: UIButton!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var showHiddenDefinitionButton: UIButton!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var flashCardCounter: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    
    let dIC = DItemController()
    private var itemID: Int!
    private var dItem : DItem! //initialize in configure and use to play audio, and to keep track of favorite state locally
    
    private var utilities = Utilities()
    
    weak var delegate: FCFavoritePressedDelegate?
    
    func configure (dItem: DItem, fcvMode: FlashCardViewMode, counter: String) {
        
        itemID = dItem.itemID
        
        self.dItem = dItem
        
        termLabel.text = dItem.term
        definitionLabel.text = dItem.definition
        
        //look for a comma, if there is a comma, use Examples: for sample text
        var exampleText = "Example:"
        
        for c in dItem.example {
            if c == "," {
                exampleText = "Examples:"
            }
        }
        
        exampleLabel.text = "\(exampleText) \(dItem.example)"
        
        //set the favorite button
        
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)
        
        //set audio button enable or disable
        if dItem.audioFile == "" {
            playAudioButton.isEnabled = false
        } else {
            playAudioButton.isEnabled = true
        }
        
        
        
        flashCardCounter.text = counter
        
        switch fcvMode {
            
        case .definition:
            //show definition, hide term
            termLabel.isHidden = true
            showHiddenTermButton.isHidden = false
            showHiddenDefinitionButton.isHidden = true
            definitionLabel.isHidden = false
            exampleLabel.isHidden = false
            
        case .term:
            //show term, hide definition
            termLabel.isHidden = false
            showHiddenTermButton.isHidden = true
            showHiddenDefinitionButton.isHidden = false
            definitionLabel.isHidden = true
            exampleLabel.isHidden = true
            
        default:
            termLabel.isHidden = false
            showHiddenTermButton.isHidden = true
            showHiddenDefinitionButton.isHidden = true
            definitionLabel.isHidden = false
            exampleLabel.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code

        cellView.layer.cornerRadius = myConstants.layout_cornerRadius
        cellView.layer.borderWidth = 1
        cellView.clipsToBounds = true
        showHiddenTermButton.layer.cornerRadius = myConstants.button_cornerRadius
        showHiddenDefinitionButton.layer.cornerRadius = myConstants.button_cornerRadius
        
    }
    
    override func layoutSubviews() {
        //set color here to it responds to dark mode
        cellView.layer.borderColor = myTheme.colorCardBorder?.cgColor
    }
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
       
        //toggle LOCAL dItem to keep track of the favorite state for just the favorite display button
        dItem.isFavorite = !dItem.isFavorite
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)
        delegate?.userPressedFavoriteButton(itemID: dItem.itemID)
    }
    
    @IBAction func showTermButtonAction(_ sender: Any) {
        termLabel.isHidden = false
        showHiddenTermButton.isHidden = true
    }
    
    @IBAction func showHiddenDefinitionButtonAction(_ sender: Any) {
        definitionLabel.isHidden = false
        showHiddenDefinitionButton.isHidden = true
    }
    
    @IBAction func playAudioAction(_ sender: Any) {
        //play the audio associated with the item displayed
        myAudioPlayer.playAudio(audioFileWithExtension: dItem.audioFile)
    }
    
}
