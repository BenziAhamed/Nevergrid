//
//  GameMusic.swift
//  NeverGrid
//
//  Created by Benzi on 02/12/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import AVFoundation

class GameMusic {
    
    var musicEnabled:Bool
    private var musicPlayer:AVAudioPlayer? = nil
    private var setupDone:Bool = false

    init() {
        let settings = GameSettings()
        musicEnabled = settings.musicEnabled
    }
    
    func createPlayer() {
        let music = NSBundle.mainBundle().URLForResource("Wacky Loop", withExtension: "mp3")!
        musicPlayer = try? AVAudioPlayer(contentsOfURL: music)
        musicPlayer!.numberOfLoops = -1
        musicPlayer!.prepareToPlay()
    }
    
    func setup() {
        if !musicEnabled { return }
        if setupDone { return }
        createPlayer()
        musicPlayer!.play()
        setupDone = true
    }
    
    func pause() {
        musicPlayer?.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch _ {
        }
    }
    
    func play() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        musicPlayer?.play()
    }
    
    func toggle() {
        if musicEnabled {
            musicPlayer!.stop()
            musicPlayer = nil
            musicEnabled = false
        } else {
            musicEnabled = true
            setupDone = false
            setup()
        }
        let settings = GameSettings()
        settings.musicEnabled = self.musicEnabled
        settings.save()
    }
    
    
    // singleton pattern
    class var sharedInstance: GameMusic {
        struct Singleton {
            static let instance = GameMusic()
        }
        return Singleton.instance
    }

}