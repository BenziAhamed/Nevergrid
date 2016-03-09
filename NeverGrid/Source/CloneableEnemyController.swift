//
//  CloneableEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// controller for enemies that can clone themselves
class CloneableEnemyController : EnemyController {
    
    
    struct Settings {
        static let maxCloningOperationsAllowed = 2
    }
    
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "CloneableEnemyController"
        
        let moveStrategy = ConstrainedMoveStrategy(enemy: entity, world: world, searchDirections: Direction.AllDirections)
        
        
        //add(CheckAlive(entity: entity, world: world))
        add(CheckFrozen(entity: entity, world: world))
        add(CloneEnemy(entity: entity, world: world, moveStrategy: moveStrategy))
        add(DieIfOld(limit: Settings.maxCloningOperationsAllowed, entity: entity, world: world))
        add(MoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
}
