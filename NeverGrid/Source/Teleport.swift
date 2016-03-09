//
//  Teleport.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that teleports the entity
class Teleport : EntityAction {
    
    override var description:String { return "Teleport" }
    
    override func perform() -> SKAction?  {
        let location = world.location.get(entity)
        let player = world.player.get(entity)
        if let p = world.portalCache.get(location) {
            let portal = world.portal.get(p)
            
            // if the portal is not enabled
            // don't do anything
            if !portal.enabled { return nil }
            
            // only use a portal if its destination is valid, ie its not a
            // closed off cell
            if world.level.cells.get(portal.destination)!.type == CellType.Block { return nil }
            
            // we are teleporting
            world.eventBus.raise(GameEvent.PlayerTeleportStarted, data: p)
            
            // move the player to the new location
            location.row = portal.destination.row
            location.column = portal.destination.column
            player.teleportedInLastMove = true
            
            // after teleporting collect items on the landed cell
            // if we teleported, we need to destroy the cell from where
            // we came if it was a floating cell
            
            self.controller?.insert([
//                CorrectZIndex(entity: world.mainPlayer, world: world, row: location.row),
                DestroyCells(cellFilter:[CellType.Falling], entity: self.entity, world: self.world),
                CollectItems(entity: self.entity, world: self.world),
                RaiseEvent(event:GameEvent.PlayerTeleportCompleted, entity: self.entity, world: self.world)
                ])
            
            // just move to the location immediately
            return SKAction.moveTo(world.gs.getEntityPosition(row: location.row, column: location.column), duration: 0)
        }
        return nil
    }
}
