//
//  CollectItems.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that checks to see if we need to collect a coin/powerup
/// raises goal collected event
/// raises powerup collected event
class CollectItems : EntityAction {
    
    override var description:String { return "CollectItems" }
    
    override func perform() -> SKAction? {
        let entityLocation = world.location.get(entity)
        
        let cell = world.level.cells.get(entityLocation)!
        if let g = cell.goal {
            world.eventBus.raise(GameEvent.CoinCollected, data: g)
            cell.goal = nil
        }
        if let z = cell.zoneKey {
            let zoneKey = world.zoneKey.get(z)
            world.level.activateCells(zoneKey.zoneID)
            world.eventBus.raise(GameEvent.ZoneKeyCollected, data: z)
            cell.zoneKey = nil
        }
        if let p =  cell.powerup {
            world.eventBus.raise(GameEvent.PowerupCollected, data: p)
            cell.powerup = nil
        }
        
        return nil
    }
}