//
//  CheckFrozen.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class CheckFrozen : EntityAction {
    
    override var description:String { return "CheckFrozen" }
    
    override func perform() -> SKAction? {
        
        // TODO: uncommment for normal powerup mode, else works in toggle mode
//        if world.freeze.belongsTo(entity) {
//            let freeze = world.freeze.get(entity)
//            switch freeze.duration {
//            case PowerupDuration.Infinite:
//                break
//            case var PowerupDuration.TurnBased(moves):
//                moves-=1
//                if moves < 0 {
//                    // unfreeze
//                    world.eventBus.raise(GameEvent.EnemyUnfrozen, data: entity)
//                    world.manager.removeComponent(entity, c: freeze)
//                } else {
//                    freeze.duration = PowerupDuration.TurnBased(moves)
//                }
//            }
//            isBlocking = true
//        }
        
        isBlocking = world.freeze.belongsTo(entity)
        return nil
    }
}
