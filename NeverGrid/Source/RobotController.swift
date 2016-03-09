//
//  RobotController.swift
//  NeverGrid
//
//  Created by Benzi on 21/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// an enemy that is a robot
class RobotController : EnemyController {
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "RobotController"
        
        let moveStrategy = ConstrainedMoveStrategy(enemy: entity, world: world, searchDirections: Direction.AllDirections)
        
        add(CheckFrozen(entity: entity, world: world))
        add(RobotBootup(entity: entity, world: world))
        add(RobotMoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
}
