//
//  DestroyCells.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// action that makes falling cells fall based on your previous location
/// raises the floating cell destroyed event
class DestroyCells : EntityAction {
    
    var cellFilter:[CellType]

    init(cellFilter:[CellType], entity:Entity, world:WorldMapper) {
        self.cellFilter = cellFilter
        super.init(entity: entity, world: world)
    }
    
    override var description:String { return "DestroyCells" }

    
    override func perform() -> SKAction?  {

        let location = world.location.get(entity)
        let prevLocation = LocationComponent(row: location.previousRow, column: location.previousColumn)
        
        if prevLocation == location { return nil } // if we are just standing in the same position don't do anything
        
        let gridCell = world.level.cells.get(prevLocation)!
        
        // if the cell does not match our filter
        if !cellFilter.contains(gridCell.type) { return nil }

        // or if we are an enemy and the previous cell contained a collectible item
        if entity != world.mainPlayer && cellContainsCollectableItem(prevLocation) { return nil }
        
        let cellEntityForPrevLocation = world.cellCache.get(prevLocation)
        
        // update the walls so that we can't reach this cell anymore
        gridCell.walls = Direction.All
        gridCell.fallen = true
        
        // destroy the cell
        world.eventBus.raise(GameEvent.CellDestroyed, data: cellEntityForPrevLocation)
        
        // if this cell had a portal
        // destroy the source and destination portals
        if let source = world.portalCache.get(prevLocation) {
            
            let sourcePortal = world.portal.get(source)
            let destination = world.portalCache.get(sourcePortal.destination)!
            
            world.eventBus.raise(GameEvent.PortalDestroyed, data: source)
            world.eventBus.raise(GameEvent.PortalDestroyed, data: destination)
            
            world.portalCache.clear(prevLocation)
            world.portalCache.clear(sourcePortal.destination)
        }
        
        
        // if this cell had an enemy not of type monster
        // destroy the enemy too, applicable only for destroyers
        
        if entity != world.mainPlayer {
            let cell = world.level.cells.get(prevLocation)!
            if cell.occupiedByEnemy {
                let e = cell.occupiedBy!
                let enemy = world.enemy.get(e)
                if enemy.enabled || enemy.enemyType != EnemyType.Monster {
                    // kill this enemy
                    cell.occupiedBy = nil
                    world.eventBus.raise(GameEvent.EnemyDeath, data: e)
                }
                
            }
        }

        return nil
    }
    
    
    func cellContainsCollectableItem(cellLocation:LocationComponent) -> Bool {
        for collectable in world.collectable.entities() {
            let location = world.location.get(collectable)
            if location == cellLocation { return true }
        }
        return false
    }
}