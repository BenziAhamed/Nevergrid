//
//  ConstrainedMoveStrategy.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

/// move strategy that attempts to find a move that is as close
/// to the player as possible, in the order of the moves in the
/// valid move set
class ConstrainedMoveStrategy : BasicMoveStrategy {
    
    var validDirections:[UInt]!
    
    init(enemy: Entity, world: WorldMapper, searchDirections:[UInt]) {
        self.validDirections = searchDirections
        super.init(enemy: enemy, world: world)
    }
    
    override func getMove() -> EnemyMove {
        let enemyLocation = world.location.get(enemy)
        var leastDistance = distance(enemyLocation, b: world.playerLocation)
        var bestMove = EnemyMove()
        
        // check in all directions
        // see if a move is possible, then valid
        // and then if that move makes us closer
        // to the player, return the move info
        for move in validDirections {
            if isValidMoveFromLocation(enemyLocation, moveDirection: move)
            {
                let newLocation = getLocationRelativeToMove(enemyLocation, direction: move)
                let currentDistance = distance(world.playerLocation, b: newLocation)
                if currentDistance < leastDistance {
                    leastDistance = currentDistance
                    bestMove.direction = move
                    bestMove.row = newLocation.row
                    bestMove.column = newLocation.column
                }
            }
        }
        return bestMove
    }
}