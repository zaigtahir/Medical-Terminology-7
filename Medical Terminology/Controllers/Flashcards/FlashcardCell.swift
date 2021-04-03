//
//  CollectionCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/17/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
import AVFoundation

protocol FlashcardCellDelegate: AnyObject {
    func userPressedFavoriteButton(termID: Int)
}

class FlashcardCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var showHiddenTermButton: UIButton!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var showHiddenDefinitionButton: UIButton!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var favoriteButton: ZUIToggleButton!	//my custom button! :)
    @IBOutlet weak var flashCardCounter: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!

	private var term: 	Term!
	
	private let tc = TermController()
    private var utilities = Utilities()
    private var audioPlayer = AVAudioPlayer ()
	
    weak var delegate: FlashcardCellDelegate?
	
	func configure (term: Term, fcvMode: FlashcardViewMode, isFavorite: Bool, counter: String) {
		
		self.term = term
		termLabel.text = term.name
		definitionLabel.text = "Definition: \(term.definition)"
		exampleLabel.text = "Example(s): \(term.example)"
		flashCardCounter.text = counter
		favoriteButton.isOn = isFavorite
		
		// set speaker button to not playing
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
		
		playAudioButton.isEnabled = term.isAudioFilePresent()
		
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
    
	/*
    func configure (dItem: DItem, fcvMode: FlashcardViewMode, counter: String) {
        
        itemID = dItem.itemID
        
        self.dItem = dItem
        
        termLabel.text = dItem.term
        definitionLabel.text = "Definition: \(dItem.definition)"
        
        //look for a comma, if there is a comma, use Examples: for sample text
        
        if dItem.example == "" {
            exampleLabel.text = ""
            
        } else {
            exampleLabel.text = "Example: \(dItem.example)"
        }
        
        //set the favorite button
        
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)
        
        //set speaker button to not playing
        playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
        
        //check if the audioFile is present in the bundle
        let aFC = AudioFileController()
        
        //set audio button enable or disable
        if dItem.audioFile != "" && aFC.isAudioFilePresentInBundle(filename: dItem.audioFile, extension: "mp3"){
            
            playAudioButton.isEnabled = true
        } else {
            playAudioButton.isEnabled = false
            
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
    */
	
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        
		audioPlayer.delegate = self
		
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
    
    func playAudio () {
		term.playAudio(audioPlayer: audioPlayer)
    }
	
    // MARK: Delegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //change the speaker image to no playing
      
		
		print ("got message of audio completion")
		
        playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
    }
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
		delegate?.userPressedFavoriteButton(termID: term.termID)
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
        playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
        playAudio()
      
    }
}
