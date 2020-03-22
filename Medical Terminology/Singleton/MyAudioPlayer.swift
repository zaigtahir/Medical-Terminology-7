//
//  MyAudioPlayer.swift
//  Medical Terminology
//
//  Created by Zaigham Tahir on 3/5/20.
//  Copyright © 2020 Zaigham Tahir. All rights reserved.
//

import Foundation
import AVFoundation

class MyAudioPlayer {
    
    private var audioPlayer: AVAudioPlayer?
    
    func playAudio (audioFileWithExtension: String) {
        
        do {
            if let fileURL = Bundle.main.url(forResource: audioFileWithExtension, withExtension: nil) {
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL.path))
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            } else {
                print("No file with specified name exists")
                return
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
            return
        }
        
    }
    
    func stopAudio () {
        //stop playing any audio
        audioPlayer?.stop()
    }
    
    
}
