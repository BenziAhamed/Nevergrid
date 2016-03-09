//
//  InputSystem.swift
//  gettingthere
//
//  Created by Benzi on 13/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class InputSystem : System {
    
    enum State {
        case ProcessingUserSwipe
        case ProcessingUserPath
        case Waiting
    }
    
    var state = State.Waiting
    var path:[VisitedCell]!
    var turnsCompleted = 0
    
    override init(_ world: WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameStarted, handler: self)
    }
    
    func enable() {
        world.eventBus.subscribe(GameEvent.UserSwipe, handler: self)
        //world.eventBus.subscribe(GameEvent.UserPathCreated, handler: self)
        world.eventBus.subscribe(GameEvent.AICompleted, handler: self)
        world.eventBus.subscribe(GameEvent.GameOver, handler: self)
    }
    
    var disabled = false
    
    func disable() {
        //world.eventBus.unsubscribe(self)
        disabled = true
    }
    
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        
        if disabled {
            return
        }
        
        if event == GameEvent.UserSwipe {
            if state==State.Waiting {
                state = State.ProcessingUserSwipe
                world.eventBus.raise(GameEvent.DoPlayerMove, data: data)
            }
        }
        else if event == GameEvent.AICompleted {
            if state == State.ProcessingUserSwipe {
                state = State.Waiting
            }
        }
        else if event == GameEvent.GameOver {
            disable()
        }
        else if event == GameEvent.GameStarted {
            enable()
        }
    }
}

//        if event == GameEvent.UserPathCreated {
//            if state == State.Waiting {
//                state = State.ProcessingUserPath
//                path = data as [VisitedCell]
//                turnsCompleted = 1 // because the first cell in a path will be the player cell
//                // kick start the first player move
//                // remaining moves will be handled in AI completed event
//                world.eventBus.raise(GameEvent.DoPlayerMove, data: path[turnsCompleted].direction)
//            }
//        }
//        else

//            else if state == State.ProcessingUserPath {
//                // have we finished raising events for all required
//                // path cells?
//                turnsCompleted++
//                if turnsCompleted == path.count {
//
//                    // since we completed this path, lets remove all path nodes
//                    for cell in path {
//                        for child in cell.sprite.node.children {
//                            if let c = child as? SKSpriteNode {
//                                if c.name == nil { continue }
//                                if (c.name!).hasPrefix("path") {
//                                    c.removeFromParent()
//                                }
//                            }
//                        }
//                    }
//
//                    state = State.Waiting
//                } else {
//                    // raise the next event
//                    world.eventBus.raise(GameEvent.DoPlayerMove, data: path[turnsCompleted].direction)
//                }
//            }