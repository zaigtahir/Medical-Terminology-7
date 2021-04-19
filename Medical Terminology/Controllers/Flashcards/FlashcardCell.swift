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
    func pressedFavoriteButton(termID: Int)
	func pressedGotItButton(termID: Int)
}

class FlashcardCell: UICollectionViewCell, AVAudioPlayerDelegate, TermAudioDelegate {
	
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var showHiddenTermButton: UIButton!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var showHiddenDefinitionButton: UIButton!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var favoriteButton: ZUIToggleButton!	//my custom button! :)
    @IBOutlet weak var flashCardCounter: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
	@IBOutlet weak var gotItButton: ZUIToggleButton!
	
	private var term: 	Term!
	
	private let tc = TermController()
    private var utilities = Utilities()
	
    weak var delegate: FlashcardCellDelegate?
	
	func configure (term: Term, fcvMode: FlashcardViewMode, isFavorite: Bool, flashcardLearnStatus: FlashCardLearnStatus,  counter: String) {
		
		self.term = term
		termLabel.text = term.name
		definitionLabel.text = "Definition: \(term.definition)"
		exampleLabel.text = "Example(s): \(term.example)"
		flashCardCounter.text = counter
		favoriteButton.isOn = isFavorite
		
		term.delegate = self
		
		// set speaker button to not playing
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
		playAudioButton.isEnabled = term.isAudioFilePresent()
		
		if flashcardLearnStatus == FlashCardLearnStatus.learning {
			gotItButton.isOn = false
		} else {
			gotItButton.isOn = true
		}
		
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
    
    // MARK: -TermAudioDelegate methods
	
	func termAudioStartedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
	}
	
	func termAudioStoppedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
	}
	    
    @IBAction func favoriteButtonAction(_ sender: Any) {
		delegate?.pressedFavoriteButton(termID: term.termID)
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
		term.playAudio()
    }
	@IBAction func gotItButtonAction(_ sender: Any) {
		gotItButton.isOn.toggle()
		delegate?.pressedGotItButton(termID: term.termID)
	}
}
