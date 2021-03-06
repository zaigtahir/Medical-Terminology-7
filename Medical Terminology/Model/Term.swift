//
//  Term.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/23/21.
//  Copyright © 2021 Zaigham Tahir. All rights reserved.
//

import Foundation
import AVFoundation

/* for now this protocol in Term2
protocol TermAudioDelegate: AnyObject {
	func termAudioStartedPlaying()
	func termAudioStoppedPlaying()
}
*/

class Term: NSObject, AVAudioPlayerDelegate {
	var termID: Int = -1
	var name: String = ""
	var definition: String = ""
	var example: String = ""
	var myNotes: String = ""
	var secondCategoryID : Int = -1
	var thirdCategoryID : Int = -1
	var audioFile: String = ""
	var isStandard: Bool = false
	var audioPlayer = AVAudioPlayer()
	var favoriteForCategory = false

	/// initialize with the values when need  when using the TermVC and CategoryListVC
	var assignedCategories = [Int]()

	weak var delegate: TermAudioDelegate?
	
	override init () {
		super.init()
	}
	
	convenience init(termID: Int, name: String, definition: String, example: String, myNotes: String, secondCategoryID: Int, thirdCategoryID: Int, audioFile: String, isStandard: Bool) {
		
		self.init()
		self.termID = termID
		self.name = name
		self.definition = definition
		self.example = example
		self.myNotes = myNotes
		self.secondCategoryID = secondCategoryID
		self.thirdCategoryID = thirdCategoryID
		self.audioFile = audioFile
		self.isStandard = isStandard
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
			audioPlayer.delegate = self
			audioPlayer.prepareToPlay()
			audioPlayer.play()
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
