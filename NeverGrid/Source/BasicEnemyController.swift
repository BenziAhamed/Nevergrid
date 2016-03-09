//
//  BasicEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class BasicEnemyController : EnemyController {
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "BasicEnemyController"
        
        let moveStrategy = ConstrainedMoveStrategy(enemy: entity, world: world, searchDirections: Direction.AllDirections)
        //let moveStrategy = AstarMoveStrategy(enemy: entity, world: world)
        
        
        //add(CheckAlive(entity: entity, world: world))
        add(CheckFrozen(entity: entity, world: world))
        add(MoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
}