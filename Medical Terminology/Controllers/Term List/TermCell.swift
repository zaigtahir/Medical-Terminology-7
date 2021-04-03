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
    func pressedFavoriteButton (dItem: DItem)
}

class TermCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var playAudioButton: UIButton!
    
    var indexPath : IndexPath!
    var dItem : DItem!
	
	// set up in segue
	var term : Term!
	
	
   // let utilities = Utilities()
	
    let aFC = AudioFileController()
    
    private var audioPlayer: AVAudioPlayer?
    
    weak var delegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(term: Term, indexPath: IndexPath) {
        self.term = term
        self.indexPath = indexPath
		self.termLabel.text = term.name
		self.definitionLabel.text = term.definition
        
		playAudioButton.isEnabled = term.isAudioFilePresent()

    }
    
    func playAudio () {
        
		let fileName = "\(myConstants.audioFolder)/\(term.audioFile ?? "no file name").mp3"
        
        let path = Bundle.main.path(forResource: fileName, ofType: nil)!
        
        let url = URL(fileURLWithPath: path)
        
        //if this player is already playing, stop the play
        
        if let player = audioPlayer {
            if player.isPlaying{
                player.stop()
            }
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
        } catch {
            print("couldn't load audio file")
        }
        
        return
    }
    
    //MARK: Delegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //change the speaker image to no playing
        
        playAudioButton.setImage(myTheme.imageSpeaker, for: .normal)
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
     
		
        //change the favorite button image locally
   //     utilities.setFavoriteState(button: favoriteButton, isFavorite: !dItem.isFavorite)
        
        //now need to pass this info back to database
        delegate?.pressedFavoriteButton(dItem: dItem)
    }
    
    @IBAction func playAudioButtonAction(_ sender: UIButton) {
        playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
        playAudio()
    }
    
}
