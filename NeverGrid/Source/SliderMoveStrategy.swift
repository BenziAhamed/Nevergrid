//
//  SliderMoveStrategy.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class SliderMoveStrategy : BasicMoveStrategy {
    override init(enemy: Entity, world: WorldMapper) {
        super.init(enemy: enemy, world: world)
    }
    
    
    override func getMove() -> EnemyMove {
        let enemyLocation = world.location.get(enemy)
        let enemyComponent = world.enemy.get(enemy)
        let bestMove = EnemyMove()
        
        
        
        var nextMove =  (enemyComponent.enemyType == EnemyType.SliderUpDown ? Direction.Up : Direction.Left)
        
        // try to continue on with the last move
        // if we have already moved
        if enemyLocation.lastMove != Direction.None {
            nextMove = enemyLocation.lastMove
        }
        
        
        // continue to check if we can move in the current direction
        // else we try to switch
        let searchMoves = [nextMove, Direction.Opposite[nextMove]! ]
        
        for move in searchMoves {
            if isValidMoveFromLocation(enemyLocation, moveDirection: move)
            {
                let newLocation = getLocationRelativeToMove(enemyLocation, direction: move)
                bestMove.direction = move
                bestMove.row = newLocation.row
                bestMove.column = newLocation.column
            }
        }
        
        return bestMove
    }
}