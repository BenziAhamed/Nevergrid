//
//  MoveInAsClone.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit



/// action that runs an animated entry of the
/// newly cloned clone
class MoveInAsClone : EntityAction {
    
    override var description:String { return "MoveInAsClone" }
    
    override func perform() -> SKAction? {
        
        let location = world.location.get(entity)
        let enemy = world.enemy.get(entity)
        
        enemy.enabled = true
        
        let cell = world.level.cells.get(location)!
        cell.occupiedBy = entity
        
        let moveTo = SKAction.moveTo(world.gs.getEntityPosition(location), duration: ActionFactory.Timing.EntityMove)
        let fadeIn = SKAction.fadeInWithDuration(ActionFactory.Timing.EntityMove)
        return SKAction.group([moveTo,fadeIn])
    }
}

