//
//  ProcessEnemyHit.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that blocks if you hit an enemy
/// raises the game over event
class ProcessEnemyHit : EntityAction {
    
    override var description:String { return "ProcessEnemyHit" }
    
    override func perform() -> SKAction? {
        let location = world.location.get(entity)
        let cell = world.level.cells.get(location)!
        if cell.occupiedByEnemy {
            // we hit an enemy
            // if the enemy has a freeze enabled, we can kill them
            // else its game over for us
            let enemy = cell.occupiedBy!
            if world.freeze.belongsTo(enemy) {
                cell.occupiedBy = nil
                world.eventBus.raise(GameEvent.EnemyDeath, data: enemy)
            } else {
                // we died
                if world.slide.belongsTo(entity) {
                    world.eventBus.raise(GameEvent.GameOver, data: GameOverReason(.PlayerCrashedIntoEnemy))
                } else {
                    world.eventBus.raise(GameEvent.GameOver, data: GameOverReason(.PlayerHitEnemy))
                }
                isBlocking = true
            }
        }
        return nil
    }
}