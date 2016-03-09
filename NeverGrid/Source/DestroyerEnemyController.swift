//
//  DestroyerEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 01/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// an enemy that destroys all cells it leaves from
class DestroyerEnemyController : EnemyController {
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "DestroyerEnemyController"
        
        let moveStrategy = ConstrainedMoveStrategy(enemy: entity, world: world, searchDirections: Direction.AllDirections)
        
        //add(CheckAlive(entity: entity, world: world))
        add(CheckFrozen(entity: entity, world: world))
        add(MoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(DestroyCells(cellFilter: [CellType.Normal, CellType.Falling], entity: entity, world: world))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
}
