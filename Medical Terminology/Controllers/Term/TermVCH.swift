//
//  TermVCH.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 4/3/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import AVFoundation

class TermVCH {
	
	var termID : Int!
	
	var currentCategoryID : Int!
	
	var displayMode = DisplayMode.view
	
	///set this to true when the user is in edit/add mode and the data is valid to save as a term
	var isReadyToSaveTerm = false
	
	var audioPlayer = AVAudioPlayer()
	
	// try putting audio here
	func playAudio (audioFile: String) {
		
		
		let fileName = "\(myConstants.audioFolder)/\(audioFile).mp3"
		
		let path = Bundle.main.path(forResource: fileName, ofType: nil)!
		
		let url = URL(fileURLWithPath: path)
		print(url.absoluteURL)
		//if this player is already playing, stop the play
		
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
		 }
		 catch {
			print("problem with AVAudioSession.sharedInstance")
		 }
		
		if audioPlayer.isPlaying{
			audioPlayer.stop()
		}
		
		do {
			
			print("playing audio")
			
			audioPlayer = try AVAudioPlayer(contentsOf: url)
			//audioPlayer.delegate = self
			audioPlayer.prepareToPlay()
			audioPlayer.play()
			//delegate?.termAudioStartedPlaying()
			
		} catch {
			print("couldn't load audio file")
		}
		
	}
	
}
