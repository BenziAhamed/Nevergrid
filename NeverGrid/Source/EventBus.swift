//
//  world.eventBus.swift
//  gettingthere
//
//  Created by Benzi on 04/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

struct GameEvent {
    static let CellDestroyed =                   1
    static let PlayerMoveStarted =               2
    static let PlayerMoveCompleted =             3
    static let GameOver =                        4
    static let EntityRemoved =                   5
    static let CoinCollected =                   6
    static let PlayerTeleportStarted =           7
    static let PlayerTeleportCompleted =         8
    static let EnemyDeath =                      9
    static let EnemyMoveStarted =               10
    static let EnemyMoveCompleted =             11
    static let AICompleted =                    12
    static let EntityLanded =                   13
    static let UserSwipe =                      14
    static let DoPlayerMove =                   15
    static let GameStarted =                    16
    static let PlayerCreated =                  17
    static let EnemyCreated =                   18
    static let EnemyEnraged =                   19
    static let EnemyCalmed =                    20
    static let CloneCreated =                   21
    static let PortalDestroyed =                22
    static let EnemyFrozen =                    23
    static let EnemyUnfrozen =                  24
    static let PowerupCreated =                 25
    static let PowerupCollected =               26
    static let SlideActivated =                 27
    static let SlideDeactivated =               28
    static let SlideStarted =                   29
    static let SlideCompleted =                 30
    static let SceneLoaded =                    31
    static let SceneUnloaded =                  32
    static let UserPathCreated =                33
    static let ZoneKeyCollected =               34
    static let GameEntitiesCreated =            35
    static let EnemyMadeVisibleForZone =        36
    static let RobotBooted =                    37
    static let RobotShutdown =                  38
    static let ClonerDeath =                    39
}


// TODO: remove later
let ___GameEventNames = [
     1: "CellDestroyed",
     2: "PlayerMoveStarted",
     3: "PlayerMoveCompleted",
     4: "GameOver",
     5: "EntityRemoved",
     6: "CoinCollected",
     7: "PlayerTeleportStarted",
     8: "PlayerTeleportCompleted",
     9: "EnemyDeath",
    10: "EnemyMoveStarted",
    11: "EnemyMoveCompleted",
    12: "AICompleted",
    13: "EntityLanded",
    14: "UserSwipe",
    15: "DoPlayerMove",
    16: "GameStarted",
    17: "PlayerCreated",
    18: "EnemyCreated",
    19: "EnemyEnraged",
    20: "EnemyCalmed",
    21: "CloneCreated",
    22: "PortalDestroyed",
    23: "EnemyFrozen",
    24: "EnemyUnfrozen",
    25: "PowerupCreated",
    26: "PowerupCollected",
    27: "SlideActivated",
    28: "SlideDeactivated",
    29: "SlideStarted",
    30: "SlideCompleted",
    31: "SceneLoaded",
    32: "SceneUnloaded",
    33: "UserPathCreated",
    34: "ZoneKeyCollected",
    35: "GameEntitiesCreated",
    36: "EnemyMadeVisibleForZone",
    37: "RobotBooted",
    38: "RobotShutdown",
    39: "ClonerDeath"
]

//protocol GameEventHandler {
//    func handleEvent(event:Int, _ data:AnyObject?)
//}


// an asynchronous event bus (as in tries to spread event handling across
// update calls, this improves render bound calls by a margin, and also
// makes the game feel snappier
class EventBus {
    
    // certain events needs to be executed in sync
    let syncEventMap = [
        GameEvent.GameEntitiesCreated: true,
        GameEvent.GameStarted: true,
        GameEvent.EntityLanded : true,
        GameEvent.CoinCollected : true,
        GameEvent.UserSwipe: true,
        GameEvent.DoPlayerMove: true,
        GameEvent.AICompleted: true,
        GameEvent.CellDestroyed: true
    ]

    /// MARK: Basic init
    
    init() {}
    
    // the set of event handlers registered for an event
    var eventHandlers = [Int:NSMutableArray]()
    
    func subscribe(event:Int, handler:AnyObject) {
        if eventHandlers[event] == nil {
            eventHandlers[event] = NSMutableArray()
        }
        eventHandlers[event]!.addObject(handler)
    }
    
    
    func unsubscribe(handler:AnyObject) {
        for k in eventHandlers.keys {
            if let handlers = eventHandlers[k] {
                handlers.removeObject(handler)
            }
        }
    }
    
    func unsubscribe(event:Int, handler:AnyObject) {
        if let handlers = eventHandlers[event] {
            handlers.removeObject(handler)
        }
    }
    
    
    func reset() {
        eventHandlers.removeAll(keepCapacity: true)
        eventQ.clear()
    }
    
    
    /// MARK: Event handling
    
    var eventQ = SyncQueue<EventQueueItem>()
    
    struct EventQueueItem {
        let data:AnyObject?
        let event:Int
        let handler:EventHandler
    }
    
    var gameOverRaised = false
    
    func raise(event:Int, data:AnyObject?) {
        
        // the game over event is like a showstopper
        // we stop processing any events after we handle a game over event
        if gameOverRaised { return }
        gameOverRaised = (event == GameEvent.GameOver)
        
        if let handlers = eventHandlers[event] {
            
            

            if syncEventMap[event] == nil {
                
                // queue the event for processing in an update cycle
                
                debug_print("PUSH: \(___GameEventNames[event]!) -> \(handlers.count) targets")
                queueEvent(event, data, handlers)
                
            } else {
                
                // if this event needs to be executed all at one go
                // then run them immediately
                
                debug_print("SYNC: \(___GameEventNames[event]!) -> \(handlers.count) targets")
                
                let handlersCopy = NSMutableArray()
                for i in 0..<handlers.count {
                    handlersCopy.addObject(handlers.objectAtIndex(i))
                }
                
                for i in 0..<handlersCopy.count {
                    (handlersCopy[i] as? EventHandler)?.handleEvent(event,data)
                }
                
            }
        }
    }
    
    func queueEvent(event:Int, _ data:AnyObject?, _ handlers:NSMutableArray) {
            for handler in handlers {
                let queueItem:EventQueueItem = EventQueueItem(
                    data: data,
                    event: event,
                    handler: (handler as! EventHandler)
                )
                eventQ.push(queueItem)
            }
        
    }
    
    func update() {
        if eventQ.count > 0 {
            
            let eventItem = eventQ.pop()
            
            // if the game over event has been receieved, we can skip all
            // remaining events and process only the game over stuff
            if gameOverRaised && eventItem.event != GameEvent.GameOver {
                return
            }
            
            debug_print("POP: \(___GameEventNames[eventItem.event]!)")
            eventItem.handler.handleEvent(eventItem.event, eventItem.data)
        }
    }
}





// A drop in replacement of a sync version event bus follows:

//class EventBus {
//    
//    init() {}
//    
//    var eventHandlers = [Int:NSMutableArray]()
//    
//    func subscribe(event:Int, handler:AnyObject) {
//        if eventHandlers[event] == nil {
//            eventHandlers[event] = NSMutableArray()
//        }
//        eventHandlers[event]!.addObject(handler)
//    }
//    
//    func raise(event:Int, data:AnyObject?) {
//        if let handlers = eventHandlers[event] {
//            
//            let handlersCopy = NSMutableArray()
//            for i in 0..<handlers.count {
//                handlersCopy.addObject(handlers.objectAtIndex(i))
//            }
//            
//            debug_print(DebugType.EventBus, "🍊 event: \(___GameEventNames[event]!) -> \(handlersCopy.count) targets")
//            for i in 0..<handlersCopy.count {
//                (handlersCopy[i] as? GameEventHandler)?.handleEvent(event,data)
//            }
//
//        } else {
//            debug_print(DebugType.EventBus, "🍊 event: \(___GameEventNames[event]!) -> 0 targets")
//        }
//    }
//    
//    func unsubscribe(handler:AnyObject) {
//        for k in eventHandlers.keys {
//            if let handlers = eventHandlers[k] {
//                handlers.removeObject(handler)
//            }
//        }
//    }
//    
//    func unsubscribe(event:Int, handler:AnyObject) {
//        if let handlers = eventHandlers[event] {
//            handlers.removeObject(handler)
//        }
//    }
//    
//    
//    func reset() {
//        eventHandlers.removeAll(keepCapacity: true)
//    }
//    
//    // singleton pattern
//    class var defaultBus: EventBus {
//        struct Singleton {
//            static let instance = EventBus()
//        }
//        return Singleton.instance
//    }
//}