//
//  System.swift
//  gettingthere
//
//  Created by Benzi on 05/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


class System : EventHandler {
    
    var world:WorldMapper!
    var simulations = [Simulation]()
    
    init(_ world:WorldMapper) {
        self.world = world
    }
    
    func update(dt:Double) {
        if simulations.count == 0 { return }
        for sim in simulations {
            sim.update(dt)
        }
    }
    
    func startAllSimulations() {
        for sim in simulations {
            sim.start()
        }
    }
    
    func stopAllSimulations() {
        for sim in simulations {
            sim.stop()
        }
    }
    
    
}

class EventHandler : NSObject {
    func handleEvent(event:Int, _ data:AnyObject?) {
    }
}

