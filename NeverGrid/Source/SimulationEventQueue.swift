//
//  SimulationEventQueue.swift
//  OnGettingThere
//
//  Created by Benzi on 22/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class SimulationEventQueue {
    var q = [SimulationEvent]()
    
    var count:Int {
    return q.count
    }
    
    func add(event:SimulationEvent){
        // empty queue
        if q.count == 0 {
            q.append(event)
        }
        else {
            // find index to insert
            var insertIndex = 0
            while insertIndex < q.count && q[insertIndex].trigger <= event.trigger {
                insertIndex++
            }
            
            if insertIndex < q.count {
                q.insert(event, atIndex: insertIndex)
            } else {
                q.append(event)
            }
        }
    }
    
    func pop() -> SimulationEvent? {
        if q.count == 0 { return nil }
        return q.removeAtIndex(0)
    }
    
    func top() -> SimulationEvent? {
        if q.count == 0 { return nil }
        return q[0]
    }
    
    func print(name:String) {
        Swift.print("---- \(name) QUEUE ------")
        for e in q {
            Swift.print(e.description)
        }
        Swift.print("---------------")
    }
}
