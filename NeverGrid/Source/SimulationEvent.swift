//
//  SimulationEvent.swift
//  OnGettingThere
//
//  Created by Benzi on 22/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class SimulationEvent {
    
    var trigger:Double = 0.0
    var initialTrigger:Double = 0.0
    var range:Double = 0.0
    var callback:TargetAction? = nil
    var recurring = false
    var probability:Double = 1.0
    var name:String=""
    
    // special handling
    var forceTriggerOnSimulationEnd = false
    var numberOfTimes = 0
    
    var description:String {
        return "\(trigger) - \(name) - task recurring?:\(recurring)"
    }
    
    /// updates self to be repeated again
    func updateNextTrigger() -> SimulationEvent {
        trigger += initialTrigger + Double(unitRandom())*range
        return self
    }
    
    /// runs the callback
    func fire() {
        if callback != nil && Double(unitRandom()) <= self.probability {
            //println("🍎 firing: \(name)")
            callback?.performAction()
        }
    }
}

extension SimulationEvent {
    func ensure() -> SimulationEvent {
        self.forceTriggerOnSimulationEnd = true
        return self
    }
    
    func delay(by:Double) -> SimulationEvent {
        self.trigger = self.trigger + by
        return self
    }
    
    func `repeat`(times:Int) -> SimulationEvent {
        self.numberOfTimes = times
        self.recurring = false
        return self
    }
    
    func perform(action:TargetAction) -> SimulationEvent {
        self.callback = action
        return self
    }
    
    func setChance(chance:Double) -> SimulationEvent {
        self.probability = chance
        return self
    }
    
}