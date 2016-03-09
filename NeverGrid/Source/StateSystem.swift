//
//  StateSystem.swift
//  NeverGrid
//
//  Created by Benzi on 08/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

// This system manages all game related state
class StateSystem : System {
    
    override init(_ world: WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.PlayerMoveStarted, handler: self)
        world.eventBus.subscribe(GameEvent.PlayerMoveCompleted, handler: self)
        world.eventBus.subscribe(GameEvent.AICompleted, handler: self)
        world.eventBus.subscribe(GameEvent.CoinCollected, handler: self)
    }
    
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        
        case GameEvent.PlayerMoveStarted:
            world.state.status = GameplayState.PlayerTurnInProgress
        
        case GameEvent.PlayerMoveCompleted:
            world.state.movesMade++
            world.state.status = GameplayState.AIInProgress
        
        case GameEvent.AICompleted:
            world.state.status = GameplayState.Waiting
        
        case GameEvent.CoinCollected:
            world.state.coinsCollected++
            
        case GameEvent.GameOver:
            world.state.status = GameplayState.GameOver
        
        default: break
        }
    }
}