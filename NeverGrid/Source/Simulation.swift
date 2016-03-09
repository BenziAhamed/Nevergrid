//
//  Simulation.swift
//  OnGettingThere
//
//  Created by Benzi on 22/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// represents a class that can schedule simulation events
/// based on their trigger times
class Simulation {
    
    var name:String = ""
    
    // game time elapsed counter
    var elapsed:Double = 0.0
    
    // overall duration of the sim
    // if zero, it means infinite duration
    var duration:Double = 0.0
    
    // is the sim running?
    var running = false
    
    // the set of events to process
    var events = SimulationEventQueue()
    
    /// activate the sim
    func start() {
        endDefinition()
        running = true
        //events.print("\(name) START ")
    }
    
    func pause() {
        running = false
    }
    
    func resume() {
        running = true
    }
    
    var currentEvent:SimulationEvent? = nil
    
    /// update the sim time
    func update(dt:Double)
    {
        //println("\(name) running:\(running)")
        
        if !running { return }
        
        elapsed += dt
        
        //println("\(name) - dt:\(dt), duration:\(duration), elapsed:\(elapsed) events:\(events.count)")
        
        // are we within the sim time
        if duration==0 || elapsed <= duration {
            // do we have any events?
            var event = events.top()
            
            //events.print("\(name) BEFORE ")
            
            //println("\(name) - event:\(event?.name) [trigger:\(event?.trigger) <=  elapsed:\(elapsed)]")
            
            while (event != nil && event!.trigger <= elapsed) {
                
                //println("\(name) - event:\(event!.name) [trigger:\(event!.trigger) <=  elapsed:\(elapsed)]")
                //events.print("\(name) BEFORE ")
                
                // pop and fire
                events.pop()
                event!.fire()
                
                // is the event repeating?
                // then add it back
                if event!.recurring || event!.numberOfTimes > 1 {
                    event!.numberOfTimes--
                    events.add( event!.updateNextTrigger() )
                }
                
                //events.print("\(name) AFTER ")

                // query next event
                event = events.top()
            }
        } else {
            // we reached end of sim
            stop()
        }
    }
    
    /// add a simulation event
    func add(event:SimulationEvent){
        events.add(event)
    }
    
    
    func stop() {
        if !running { return }
        running = false
        while events.count > 0 {
            if let event = events.pop() {
                if event.forceTriggerOnSimulationEnd {
                    event.fire()
                }
            }
        }
    }

//}
//
//
//
//
//
///// fluent API extensions
//extension Simulation {

    func named(name:String) -> Simulation {
        currentEvent!.name = "\(self.name) - \(name)"
        return self
    }
    
    func ensure() -> Simulation {
        currentEvent?.ensure()
        return self
    }
    
    func delay(by:Double) -> Simulation {
        currentEvent?.delay(by)
        return self
    }
    
    func `repeat`(times:Int) -> Simulation {
        currentEvent?.`repeat`(times)
        return self
    }
    
    
    /// required for fluent style API
    func beginDefinition() {
        currentEvent = SimulationEvent()
    }
    
    /// required for fluent style API
    func endDefinition() {
        if currentEvent != nil {
            self.add(currentEvent!)
            currentEvent = nil
        }
    }
    
    func perform(action:TargetAction) -> Simulation {
        currentEvent?.perform(action)
        return self
    }
    
    func withChance(chance:Double) -> Simulation {
        currentEvent?.setChance(chance)
        return self
    }
    
    /// creates an event will fire at a specified time
    func at(time:Double) -> Simulation {
        endDefinition()
        beginDefinition()
        
        currentEvent!.initialTrigger = time
        currentEvent!.trigger = time
        currentEvent!.range = 0.0
        currentEvent!.recurring = false
        return self
    }
    
    /// creates an event will fire at a random range after time
    func at(time:Double, range:Double) -> Simulation {
        endDefinition()
        beginDefinition()

        currentEvent!.initialTrigger = time
        currentEvent!.trigger = time + Double(unitRandom()) * range
        currentEvent!.range = range
        currentEvent!.recurring = false
        return self

    }
    

    /// creates a recurring event spaced time-secs apart
    func every(time:Double) -> Simulation {
        endDefinition()
        beginDefinition()

        currentEvent!.initialTrigger = time
        currentEvent!.trigger = time
        currentEvent!.range = 0.0
        currentEvent!.recurring = true
        return self

    }
    
    /// creates a recurring event spaced time-secs and an additional random range apart
    func every(time:Double, range:Double) -> Simulation {
        endDefinition()
        beginDefinition()

        currentEvent!.initialTrigger = time
        currentEvent!.trigger = time + Double(unitRandom()) * range
        currentEvent!.range = range
        currentEvent!.recurring = true
        return self
    }
    
    
}
