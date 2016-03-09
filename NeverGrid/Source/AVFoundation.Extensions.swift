//
//  AVFoundation.Extensions.swift
//  MrGreen
//
//  Created by Benzi on 08/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import AVFoundation


extension AVAudioPlayer {
    class func playerWithFile(filename:String) -> AVAudioPlayer {
        let player = try? AVAudioPlayer(contentsOfURL: NSBundle.mainBundle().URLForResource(filename, withExtension: "wav")!)
        return player!
    }
}