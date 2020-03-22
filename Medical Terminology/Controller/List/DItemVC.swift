//
//  DItemViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 11/14/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit
import AVFoundation
class DItemVC: UIViewController {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var viewCard: UIView!
    
    let dIC = DItemController()
    let utilities = Utilities()
    
    var itemID : Int!    //set this from previous controller
    var dItem : DItem!   //set this in viewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dItem = dIC.getDItem(itemID: itemID)
        
        termLabel.text = dItem.term
        definitionLabel.text = dItem.definition
        exampleLabel.text = "Example: \(dItem.example)"
        
        
        if dItem.audioFile == "" {
            playAudioButton.isEnabled  = false
        } else {
            playAudioButton.isEnabled = true
        }
        
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)    //update button
        
        viewCard.layer.cornerRadius = myConstants.layout_cornerRadius
        viewCard.layer.borderWidth = 1
        viewCard.clipsToBounds = true
        
        //set color here to it responds to dark mode
        viewCard.layer.borderColor = UIColor(named: "color card border")?.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
        
        dItem.isFavorite = !dItem.isFavorite    //local toggle
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)    //update button
        dIC.saveFavorite(itemID: itemID, isFavorite: dItem.isFavorite)   //updates the database
    }
    
    @IBAction func playAudioAction(_ sender: Any) {
        //play the audio associated with the item displayed
        
        let dItem = dIC.getDItem(itemID: itemID)
        myAudioPlayer.playAudio(audioFileWithExtension: dItem.audioFile)
        
    }
    
    
    
}
