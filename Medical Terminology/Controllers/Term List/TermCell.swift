//
//  ListCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/9/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
import AVFoundation

protocol ListCellDelegate: class {
	func pressedFavoriteButton (termID: Int)
}

class TermCell: UITableViewCell, TermAudioDelegate {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var favoriteButton: ZUIToggleButton!
	
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var playAudioButton: UIButton!
    
    var indexPath : IndexPath!
    
	// set up in segue. This will be a class variable so can use it for playing the audio
	var term : Term!
	
   // let utilities = Utilities()
	
    let aFC = AudioFileController()
    
    private var audioPlayer: AVAudioPlayer?
    
    weak var delegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
	func configure(term: Term, isFavorite: Bool, indexPath: IndexPath) {
        self.term = term
        self.indexPath = indexPath
		termLabel.text = term.name
		definitionLabel.text = term.definition
		favoriteButton.isOn = isFavorite
		
		// set non playing speaker
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
		playAudioButton.isEnabled = term.isAudioFilePresent()

    }
    
    //MARK: TermAudioDelegate
	func termAudioStartedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
	}
	
	func termAudioStoppedPlaying() {
		playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
	}
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
		// the favorite button will make a local toggle in appearance
		delegate?.pressedFavoriteButton(termID: term.termID)
    }
    
    @IBAction func playAudioButtonAction(_ sender: UIButton) {
		term.delegate = self
		term.playAudio()
    }
    
}
