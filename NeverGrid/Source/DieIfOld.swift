//
//  DieIfOld.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// action that blocks if we have been cloned twice
/// run on enemies
class DieIfOld : EntityAction {
    
    override var description:String { return "DieIfOld" }
    
    var cloneLimit = 0
    
    init(limit:Int, entity: Entity, world: WorldMapper)  {
        self.cloneLimit = limit
        super.init(entity: entity, world: world)
    }
    
    override func perform() -> SKAction? {
        let enemyComponent = world.enemy.get(entity)
        if enemyComponent.clonesCreated >= cloneLimit {
            let location = world.location.get(entity)
            let cell = world.level.cells.get(location)!
            cell.occupiedBy = nil
            world.eventBus.raise(GameEvent.ClonerDeath, data: entity)
            isBlocking = true
        }
        return nil
    }
}