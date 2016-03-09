//
//  MoveOnce.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit



/// action that moves once based on the move strategy provided
/// blocks if you cannot make a move
class MoveOnce : EntityAction
{
    
    override var description:String { return "MoveOnce" }
    
    var moveStrategy:EnemyMoveStrategy!
    
    init(entity: Entity, world: WorldMapper, moveStrategy:EnemyMoveStrategy)  {
        super.init(entity: entity, world: world)
        self.moveStrategy = moveStrategy
    }
    
    override func perform() -> SKAction? {
        let eLocation = world.location.get(entity)
        let pLocation = world.location.get(world.mainPlayer)
        let bestMove = moveStrategy.getMove()
        
        if bestMove.direction != Direction.None {
            
            // clear previous cell occupancy
            for c in getEnemyBounds(world, enemy: entity, fromLocation: eLocation) {
                let cell = world.level.cells.get(c)!
                cell.occupiedBy = nil
            }

            // move the enemy logically by one step
            eLocation.row = bestMove.row
            eLocation.column = bestMove.column

            // update new cell occupancy
            for c in getEnemyBounds(world, enemy: entity, fromLocation: eLocation) {
                let cell = world.level.cells.get(c)!
                cell.occupiedBy = entity
            }

            
            let enemy = world.enemy.get(entity)
            let moveToPosition = world.gs.getEnemyPosition(eLocation, type: enemy.enemyType)
            let moveAction = SKAction.moveTo(moveToPosition, duration: ActionFactory.Timing.EntityMove)
            return moveAction
        } else {
            isBlocking = true
            return nil
        }
    }
}