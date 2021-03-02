//
//  CollectionCell.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 5/17/19.
//  Copyright © 2019 Zaigham Tahir. All rights reserved.
//

import UIKit
import AVFoundation

protocol FCFavoritePressedDelegate: AnyObject {
    func userPressedFavoriteButton(itemID: Int)
}

class FlashCardCVCell: UICollectionViewCell, AVAudioPlayerDelegate {
    
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
    
    private var audioPlayer: AVAudioPlayer?
    
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
        
        //set speaker button to not playing
        playAudioButton.setImage(myTheme.image_speaker, for: .normal)
        
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
    
    func playAudio (audioFileWithExtension: String) {
        
        do {
            if let fileURL = Bundle.main.url(forResource: audioFileWithExtension, withExtension: nil) {
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL.path))
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            } else {
                print("No file with with the name: \(audioFileWithExtension)")
                return
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
            return
        }
        
    }
    
    //MARK: Delegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //change the speaker image to no playing
        playAudioButton.setImage(myTheme.image_speaker, for: .normal)
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
        
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
                playAudioButton.setImage(myTheme.image_speaker, for: .normal)
                return
                }
            }
            
            //play the audio associated with the item displayed
            playAudio(audioFileWithExtension: dItem.audioFile)
            playAudioButton.setImage(myTheme.image_speaker_playing, for: .normal)
            
        }
        
}
