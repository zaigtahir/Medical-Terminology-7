//
//  Term2.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 6/18/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import AVFoundation

protocol TermAudioDelegate: AnyObject {
	func termAudioStartedPlaying()
	func termAudioStoppedPlaying()
}

// trying to add a new commment

class TermTB: NSObject, AVAudioPlayerDelegate {
	var termID: Int = -1
	var name: String = ""
	var definition: String = ""
	var example: String = ""
	var myNotes: String = ""
	var secondCategoryID : Int = -1
	var thirdCategoryID : Int = -1
	var audioFile: String = ""
	
	
	var audioPlayer : AVAudioPlayer?
	
	var isStandard = false
	var isFavorite = false
	var learnedTerm = false
	var learnedDefinition = false
	var answeredTerm = 0
	var answeredDefinition = 0
	var learnedFlashcard = false
	
	/// initialize with the values when need  when using the TermVC and CategoryListVC
	var assignedCategories = [Int]()

	weak var delegate: TermAudioDelegate?
	
	override init () {
		super.init()
	}
	
	func printTerm() {
		print("term name: \(self.name)")
		print("term ID: \(self.termID)")
	}
	
	func playAudio () {
		
		if !isAudioFilePresent() {
			return
		}
		
		let fileName = "\(myConstants.audioFolder)/\(audioFile).mp3"
		
		let path = Bundle.main.path(forResource: fileName, ofType: nil)!
		
		let url = URL(fileURLWithPath: path)
		
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
			
		 }
		 catch {
			print("problem with AVAudioSession.sharedInstance")
		 }
		
		if let ap = audioPlayer {
			if ap.isPlaying {
				ap.stop()
				delegate?.termAudioStoppedPlaying()
				return
			}
		}
		
		
		do {
		
			audioPlayer = try AVAudioPlayer(contentsOf: url)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()
			audioPlayer?.play()
			delegate?.termAudioStartedPlaying()
			
		} catch {
			print("couldn't load audio file")
		}
		
	}
	
	func isAudioFilePresent () -> Bool {
		
		if Bundle.main.url(forResource: "\(myConstants.audioFolder)/\(audioFile)", withExtension: "mp3") != nil {
			return true
		} else {
			return false
		}
	}
	
	// MARK: -Delegate methods
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		delegate?.termAudioStoppedPlaying()
	}
	
}
