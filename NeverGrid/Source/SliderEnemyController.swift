//
//  SliderEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit



class SliderEnemyController : EnemyController {
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "SliderEnemyController"
        
        let moveStrategy = SliderMoveStrategy(enemy: entity, world: world)
        
        //add(CheckAlive(entity: entity, world: world))
        add(CheckFrozen(entity: entity, world: world))
        add(MoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(ProcessPlayerHit(entity: entity, world: world))
        add(DieIfOnFluffyCell(entity: entity, world: world))
    }
    
}
