//
//  EnemyController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyController : EntityActionController {
    
    var entity:Entity
    init(entity:Entity, world:WorldMapper) {
        self.entity = entity
        super.init(world: world)
        name = "EnemyController"
        startHandler = Callback(self, EnemyController.onMoveStarted)
        completionHandler = Callback(self, EnemyController.onMoveCompleted)
    }
    
    func onMoveStarted() {
        world.eventBus.raise(GameEvent.EnemyMoveStarted, data: entity)
    }
    
    func onMoveCompleted() {
        world.eventBus.raise(GameEvent.EnemyMoveCompleted, data: entity)
    }
}