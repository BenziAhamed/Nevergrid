//
//  NewlyClonedEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// acts as a one off controller for freshly cloned enemies
class NewlyClonedEnemyController : EnemyController {
    
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "CloneableEnemyController"
        
        //add(CheckAlive(entity: entity, world: world))
        add(MoveInAsClone(entity: entity, world: world))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
}
