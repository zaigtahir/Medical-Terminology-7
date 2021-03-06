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
    func pressedFavoriteButton (sender: UIButton, indexPath: IndexPath, itemID: Int)
}

class ListCC: UITableViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var playAudioButton: UIButton!
    
    var indexPath : IndexPath!
    var dItem : DItem!
    let utilities = Utilities()
    let aFC = AudioFileController()
    
    private var audioPlayer: AVAudioPlayer?
    
    weak var delegate: ListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    func configure(dItem: DItem, indexPath: IndexPath) {
        self.dItem = dItem
        self.indexPath = indexPath
        self.termLabel.text = dItem.term
        self.definitionLabel.text = dItem.definition
        
        
        if dItem.audioFile != "" && aFC.isAudioFilePresentInBundle(filename: dItem.audioFile, extension: "mp3")
        {
            playAudioButton.isEnabled = true
        } else {
            playAudioButton.isEnabled = false
        }
        
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)
    }
    
    func playAudio () {
 
        let fileName = "\(audioFolder)/\(dItem.audioFile).mp3"
        
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
      
        playAudioButton.setImage(myTheme.image_speaker, for: .normal)
    }
    
 
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        // MARK: to fix
        /*
        
        isFavorite = !isFavorite
        utilities.setFavoriteState(button: favoriteButton, isFavorite: isFavorite)
        delegate?.pressedFavoriteButton(sender: sender, indexPath: indexPath, itemID: self.itemID)*/
    }
    
    @IBAction func playAudioButtonAction(_ sender: UIButton) {
        playAudioButton.setImage(myTheme.image_speaker_playing, for: .normal)
        playAudio()
    }

}
