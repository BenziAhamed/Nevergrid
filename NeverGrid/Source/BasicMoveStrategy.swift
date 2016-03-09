//
//  BasicMoveStrategy.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


class EnemyMove : CustomStringConvertible {
    var direction:UInt = Direction.None
    var row:Int = -1
    var column:Int = -1
    
    var description: String { return "move \(Direction.Name[direction]!) to (\(column),\(row))" }
}

protocol EnemyMoveStrategy {
    func getMove() -> EnemyMove
}

class BasicMoveStrategy : EnemyMoveStrategy {
    
    var enemy:Entity!
    var world:WorldMapper!
    
    init(enemy:Entity, world:WorldMapper) {
        self.enemy = enemy
        self.world = world
    }
    
    func getMove() -> EnemyMove {
        return EnemyMove()
    }
    
    
    // returns true if the destination cell
    // is a valid move target for an enemy
    // entity
    func willNotCollideWithEnemyOrPortal(atLocation:LocationComponent) -> Bool {
        
        // find out where all enemies are currently
        // and check if we will cross over the bounds
        // of the other enemy
        
        // if we move to this location, compute our new bounds
        // and check if that space is already occupied
        let selfBounds = getEnemyBounds(world, enemy: enemy, fromLocation: atLocation)
        
        for l in selfBounds {
            // if cell is occupied, return false
            let cell = world.level.cells.get(l)!
            if cell.occupiedByEnemy && cell.occupiedBy != self.enemy {
                return false
            }
        }
        
        for location in selfBounds {
            if let portal = world.portalCache.get(location) {
                let p = self.world.portal.get(portal)
                if p.enabled {
                    return false
                }
            }
        }
        return true
    }
    
    
    /// determines if a valid enemy move can be made from the speicified
    /// location and target direction
    func isValidMoveFromLocation(location:LocationComponent, moveDirection:UInt) -> Bool {
        if world.level.movePossible(location, direction: moveDirection) {
            let cell = world.level.cells.get(location)!
            if let neighbour = world.level.getNeighbour(cell, direction: moveDirection) {
                if willNotCollideWithEnemyOrPortal(neighbour.location) {
                    return true
                }
            }
        }
        return false
    }
    
    func getLocationRelativeToMove(current:LocationComponent, direction:UInt) -> LocationComponent {
        let (c,r) = world.level.getCellRelativeTo(column: current.column, row: current.row, direction: direction)!
        return LocationComponent(row: r, column: c)
    }
    
    
}