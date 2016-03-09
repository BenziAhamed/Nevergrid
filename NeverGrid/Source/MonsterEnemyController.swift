//
//  MonsterEnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class MonsterEnemyController : EnemyController {
    override init(entity: Entity, world: WorldMapper) {
        super.init(entity: entity, world: world)
        super.name = "MonsterEnemyController"
        
        let moveStrategy = MonsterMoveStrategy(enemy: entity, world: world)
        
        //add(CheckAlive(entity: entity, world: world))
        add(MoveOnce(entity: entity, world: world, moveStrategy: moveStrategy))
        add(ProcessPlayerHit(entity: entity, world: world))
    }
}