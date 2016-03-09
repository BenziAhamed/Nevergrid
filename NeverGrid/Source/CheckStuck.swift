//
//  CheckStuck.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// action that blocks if you are stuck
/// NOTE: maybe if you are stuck, this can take in an additional
/// parameter to decide what to do
/// e.g. CheckStuck.withOutcome (raiseGameFail) for players
///      CheckStuck.withOutcome (die) for enemies
class CheckStuck : EntityAction {
    
    override var description:String { return "CheckStuck" }
    
    override func perform() -> SKAction? {
        let location = world.location.get(entity)
        var movePossible = false
        let cell = world.level.cells.get(location)!
        var atLeastOneEnemyFound = false
        
        // find if at least one move is possible
        for move in [Direction.Left,Direction.Right,Direction.Down,Direction.Up] {
            // see if we can move in this direction
            // and see if we are not blocked by an enemy
            if world.level.movePossible(cell, direction: move) {
                let neighbour = world.level.getNeighbour(cell, direction: move)!
                if neighbour.occupiedByEnemy && !world.freeze.belongsTo(neighbour.occupiedBy!) {
                    
                    // if the enemy is a  slider ignore them, else
                    // mark as at least one enemy found
                    let enemy = world.enemy.get(neighbour.occupiedBy!)
                    if enemy.enemyType != EnemyType.SliderLeftRight && enemy.enemyType != EnemyType.SliderUpDown {
                        atLeastOneEnemyFound = true
                    }
                    else {
                        // found a slider as neighbour, a move may be possible
                        // if we skip a turn
                        movePossible = true
                    }
                    
                }
                else {
                    // cell is empty and we can move to that cell
                    movePossible = true
                }
            }
            
            // we can break as soon as we find at least one valid move
            if movePossible {
                break
            }
        }
        if !movePossible {
            let reason = atLeastOneEnemyFound ? GameOverReason(.PlayerCornered) : GameOverReason(.PlayerStuck)
            world.eventBus.raise(GameEvent.GameOver, data: reason)
            isBlocking = true
        }
        return nil
    }
}