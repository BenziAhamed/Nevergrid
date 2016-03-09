//
//  GameTimer.swift
//  OnGettingThere
//
//  Created by Benzi on 06/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation



class GameTimer {
    var gametime_previous:CFTimeInterval = CFAbsoluteTimeGetCurrent() // needs to be this
    var gametime_elapsed:CFTimeInterval = 0
    
    var pause_elapsed = false
    
    func pause() {
        advance(CFAbsoluteTimeGetCurrent(), paused:true)
    }
    
    func unpause() {
        advance(CFAbsoluteTimeGetCurrent(), paused:false)
    }
    
    
    func advance(paused:Bool = false) {
        advance(CFAbsoluteTimeGetCurrent(), paused: paused)
//        if gametime_elapsed > 0.018 {
//            println("\(updateLoopCounter-1): \(gametime_elapsed)")
//        }
    }
    
    func advance(currentTime:CFTimeInterval, paused:Bool) {
        if paused {
            pause_elapsed = true
            gametime_elapsed = 0
        }
        else  {
            if pause_elapsed {
                gametime_elapsed = 0
                pause_elapsed = false
            }
            else {
                gametime_elapsed = currentTime - gametime_previous
            }
            gametime_previous = currentTime
        }
    }
}
