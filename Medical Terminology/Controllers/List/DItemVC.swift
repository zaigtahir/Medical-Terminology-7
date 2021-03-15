//
//  DItemViewController.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 11/14/18.
//  Copyright © 2018 Zaigham Tahir. All rights reserved.
//

import UIKit
import AVFoundation

class DItemVC: UIViewController, AVAudioPlayerDelegate  {
    
    @IBOutlet weak var termLabel: UILabel!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var playAudioButton: UIButton!
    @IBOutlet weak var viewCard: UIView!
    
    let dIC = DItemController()
    let utilities = Utilities()
    
    private var audioPlayer: AVAudioPlayer?
    
    var dItem : DItem!   //set this in viewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        termLabel.text = dItem.term
       
        termLabel.text = dItem.term
        definitionLabel.text = "Definition: \(dItem.definition)"
        
        //look for a comma, if there is a comma, use Examples: for sample text
        
        if dItem.example == "" {
            exampleLabel.text = ""
            
        } else {
            exampleLabel.text = "Example: \(dItem.example)"
        }
        
        //check if the audioFile is present in the bundle
        let aFC = AudioFileController()
        
        //set audio button enable or disable
        if dItem.audioFile != "" && aFC.isAudioFilePresentInBundle(filename: dItem.audioFile, extension: "mp3"){
            
            playAudioButton.isEnabled = true
        } else {
            playAudioButton.isEnabled = false
            
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
    
    func playAudio () {
 
		let fileName = "\(myConstants.audioFolder)/\(dItem.audioFile).mp3"
        
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
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
        
        dItem.isFavorite = !dItem.isFavorite    //local toggle
        utilities.setFavoriteState(button: favoriteButton, isFavorite: dItem.isFavorite)    //update button
        dIC.saveFavorite(itemID: dItem.itemID, isFavorite: dItem.isFavorite)   //updates the database
    }
    
    @IBAction func playAudioAction(_ sender: Any) {
        //play the audio associated with the item displayed
        playAudioButton.setImage(myTheme.imageSpeakerPlaying, for: .normal)
        playAudio()
    }
    
    
    
    
    
}
