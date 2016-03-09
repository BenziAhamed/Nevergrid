//
//  EntityManagerSystem.swift
//  NeverGrid
//
//  Created by Benzi on 25/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class EntityManagerSystem : System {
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.CoinCollected, handler: self)
        world.eventBus.subscribe(GameEvent.PowerupCollected, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
        world.eventBus.subscribe(GameEvent.ClonerDeath, handler: self)
        world.eventBus.subscribe(GameEvent.PortalDestroyed, handler: self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.CoinCollected: fallthrough
        case GameEvent.PowerupCollected: fallthrough
        case GameEvent.ZoneKeyCollected: fallthrough
        case GameEvent.EnemyDeath: fallthrough
        case GameEvent.ClonerDeath: fallthrough
        case GameEvent.PortalDestroyed:
            world.manager.removeEntity(data as! Entity)
            
        default: break
        }
    }
}