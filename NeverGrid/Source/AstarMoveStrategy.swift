//
//  AstarMoveStrategy.swift
//  MrGreen
//
//  Created by Benzi on 03/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

/// not working
class AstarMoveStrategy : BasicMoveStrategy {
    
    override init(enemy: Entity, world: WorldMapper) {
        super.init(enemy: enemy, world: world)
    }
    
    override func getMove() -> EnemyMove {
        
        let enemyLocation = world.location.get(enemy)
        let playerLocation = world.playerLocation
        let path = findPath(start: enemyLocation, end: playerLocation)
        let move = EnemyMove()
        let nextLocation = path[path.count-1]
        
        move.column = nextLocation.column
        move.row = nextLocation.row
        move.direction = getPossibleMove(enemyLocation, end: nextLocation)
        
        return move
    }
    
    func findPath(start start:LocationComponent, end:LocationComponent) -> [LocationComponent] {
        let frontier = PriorityQueue<LocationComponent>()
        frontier.put(start, priority: 0)
        let cameFrom = LocationBasedCache<LocationComponent>()
        let costSoFar = LocationBasedCache<Int>()
        
        //cameFrom.set(start, item: nil)
        costSoFar.set(start, item: 0)
        
        while frontier.count > 0 {
            let current = frontier.get()!
            
            if current == end {
                break
            }
            
            for next in getNeighbours(current) {
                let newCost = costSoFar.get(current)! + distance(current,b: next)
                if costSoFar.get(next) == nil || newCost < costSoFar.get(next)! {
                    costSoFar.set(next, item: newCost)
                    let priority = newCost + distance(end,b: next)
                    frontier.put(next, priority: priority)
                    cameFrom.set(next, item: current)
                }
            }
        }
        
        
        var path = [LocationComponent]()
        path.append(end)
        var parent:LocationComponent = cameFrom.get(end)!
        while(parent != start) {
            path.append(parent)
            parent = cameFrom.get(parent)!
        }
        
//        for location in path {
//            print("\(location) <-- ")
//        }
//        println("\(start)")
//        println("should move: \(Direction.Name[getPossibleMove(start, path[path.count-1])]!)")
        
        return path
    }
}


extension AstarMoveStrategy {
    
    func getNeighbours(current:LocationComponent) -> [LocationComponent] {
        var neighbours = [LocationComponent]()
        
        if isValidMoveFromLocation(current, moveDirection: Direction.Up) {
            neighbours.append(current.neighbourTop)
        }

        if isValidMoveFromLocation(current, moveDirection: Direction.Down) {
            neighbours.append(current.neighbourBottom)
        }

        if isValidMoveFromLocation(current, moveDirection: Direction.Left) {
            neighbours.append(current.neighbourLeft)
        }

        if isValidMoveFromLocation(current, moveDirection: Direction.Right) {
            neighbours.append(current.neighbourRight)
        }

        return neighbours
    }
    
}
