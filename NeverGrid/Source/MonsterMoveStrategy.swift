//
//  MonsterMoveStrategy.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation


class MonsterMoveStrategy : BasicMoveStrategy {
    
    override init(enemy: Entity, world: WorldMapper) {
        super.init(enemy: enemy, world: world)
    }
    
    
    /// returns the locations from which a specific move needs to be checked
    /// only if we can move along the direction from the specified locations
    /// can we make a move
    func getLocationsForDirection(currentLocation:LocationComponent, moveDirection:UInt) -> [LocationComponent] {
        switch(moveDirection) {
            
        case Direction.Up:
            return [
                currentLocation.neighbourTop,
                currentLocation.neighbourTopRight
            ]
            
        case Direction.Left:
            return [
                currentLocation,
                currentLocation.neighbourTop
            ]
            
        case Direction.Right:
            return [
                currentLocation.neighbourRight,
                currentLocation.neighbourTopRight
            ]
            
        case Direction.Down:
            return [
                currentLocation,
                currentLocation.neighbourRight
            ]
            
        default:
            return []
        }
    }
    
    
    // which corner cell is closest to the player?
    func monsterReferenceCell(playerLocation:LocationComponent, monsterLocation:LocationComponent) -> LocationComponent {
        let topLeft = monsterLocation.neighbourTop
        var target = monsterLocation
        
        if playerLocation.row < monsterLocation.row {
            if playerLocation.column <= monsterLocation.column {
                target = monsterLocation.neighbourTop
            } else {
                target = monsterLocation.neighbourTopRight
            }
        } else {
            if playerLocation.column > monsterLocation.column {
                target = monsterLocation.neighbourRight
            }
        }
        
        return target
    }
    
    
    override func getMove() -> EnemyMove {
        let enemyLocation = world.location.get(enemy)
        let playerLocation = world.location.get(world.mainPlayer)
        
        var bestMove = EnemyMove()
        var searchDirections = Direction.AllDirections
        
        
        let monsterReference = monsterReferenceCell(playerLocation, monsterLocation: enemyLocation)
        var leastDistance = distance(monsterReference, b: playerLocation)
        
        //println("monster loc: \(enemyLocation) closest cell: \(monsterReference), and distance is \(leastDistance)")
        
        for direction in searchDirections {
            
            
            // ensure we can move in the direction for all location offsets of the monster
            // a move is possible only if
            // a) the destination cells are not blocked to each other
            // b) the monsters cells are connected to the destination cells
            
            var movePossible = true
            let newLocations = getLocationsForDirection(enemyLocation, moveDirection: direction)
            
            // check if the destination pair is connected
            if direction == Direction.Left && !world.level.movePossible(newLocations[0].neighbourLeft, direction: Direction.Up) { movePossible = false }
            else if direction == Direction.Right && !world.level.movePossible(newLocations[0].neighbourRight, direction: Direction.Up) { movePossible = false }
            else if direction == Direction.Up && !world.level.movePossible(newLocations[0].neighbourTop, direction: Direction.Right) { movePossible = false }
            else if direction == Direction.Down && !world.level.movePossible(newLocations[0].neighbourBottom, direction: Direction.Right) { movePossible = false }
            
            // destination is alright, check if we can move from
            // current location to detsination
            if movePossible {
                for l in newLocations {
                    if !world.level.movePossible(l, direction: direction) {
                        movePossible = false
                        break
                    }
                }
            }
            
            
            // the moves are all possible based on the grid layout
            // now check if we will collide with an enemy or not
            if movePossible {
                let newLocation = getLocationRelativeToMove(enemyLocation, direction: direction)
                movePossible = willNotCollideWithEnemyOrPortal(newLocation)
            }
            
            
            // if we are free to move, check if moving in this direction
            // will give us any advantage
            if movePossible {
                let newLocation = getLocationRelativeToMove(enemyLocation, direction: direction)
                let monsterReference =  monsterReferenceCell(playerLocation, monsterLocation: newLocation)
                let currentDistance = distance(playerLocation, b: monsterReference)
                
                //println("for move: \(Direction.Name[direction]!) new loc: \(newLocation) closest cell: \(monsterReference), and distance is \(currentDistance)")
                
                if currentDistance < leastDistance {
                    
                    leastDistance = currentDistance
                    bestMove.direction = direction
                    bestMove.row = newLocation.row
                    bestMove.column = newLocation.column
                    
                }
            }
        }
        
        //println("-------- best option: \(bestMove)")
        
        return bestMove
    }
}


