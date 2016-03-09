//
//  LevelzoneSystem.swift
//  MrGreen
//
//  Created by Benzi on 23/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class LevelZoneSystem : System {
    
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameEntitiesCreated, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        
        if world.level.zoneBehaviour == ZoneBehaviour.Standalone {
            world.eventBus.subscribe(GameEvent.PlayerMoveCompleted, handler: self)
        }

    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.ZoneKeyCollected:
            let zoneKey = world.zoneKey.get(data as! Entity)
            enableEntitiesForZone(zoneKey.zoneID, skipTurns:true)
            makeZoneVisible(data as! Entity)
            
        case GameEvent.GameEntitiesCreated:
            var zoneLevel:UInt = 0
            while zoneLevel <= world.level.initialZone {
                world.level.activateCells(zoneLevel)
                enableEntitiesForZone(zoneLevel)
                zoneLevel++
            }
            
        case GameEvent.PlayerMoveCompleted:
            pauseEnemiesIfPlayerEnteredNewZone()
            
        default:
            break
        }
    }
    
    func makeZoneVisible(zoneKey:Entity) {
        // make all cells that have current zone level visible
        let zone = world.zoneKey.get(zoneKey)
        
        for c in world.cell.entities() {
            let location = world.location.get(c)
            if world.level.cells.get(location)!.zone == zone.zoneID {
                let sprite = world.sprite.get(c)
                
                // appear from bottom
                let rand = unitRandom() * world.gs.sideLength
                let moveDown = SKAction.moveByX(0, y: -world.gs.sideLength-rand, duration: 0.0)
                let fadeIn = SKAction.fadeInWithDuration(0.4)
                let moveUp = SKAction.moveByX(0, y: +world.gs.sideLength+rand, duration: 0.5)
                let animation = SKAction.sequence([
                    moveDown,
                    SKAction.group([fadeIn, moveUp])
                ])
                fadeIn.timingMode = SKActionTimingMode.EaseIn
                animation.timingMode = SKActionTimingMode.EaseOut
                
                sprite.node.runAction(animation)
            }
        }
    }
    
    func enableEntitiesForZone(zoneID:UInt, skipTurns:Bool=false) {
        
        // portals
        for p in world.portal.entities() {
            
            let portal = world.portal.get(p)
            let start = world.location.get(p)
            let sprite = world.sprite.get(p)
            
            portal.enabled =
                world.level.isActive(start) &&
                world.level.isActive(portal.destination)
            
            if !portal.enabled {
                sprite.node.alpha = 0.0
            } else {
                sprite.node.runAction(SKAction.fadeInWithDuration(0.3))
            }
        }
        
        // enemies
        for e in world.enemy.entities() {
            let enemy = world.enemy.get(e)
            if enemy.enabled { continue } // ignore already enabled enemies
            
            let location = world.location.get(e)
            enemy.enabled = world.level.isActive(location)
            
            // if we have just enabled an enemy for a zone level > initial zone level
            // means that we are to show an enemy once the game is already in play
            // and the entity landing controller has finished running long time ago
            if enemy.enabled && zoneID > world.level.initialZone {
                if skipTurns {
                    enemy.skipTurns = 1 // since we are just appearing, no need to make a move just yet
                }
                let sprite = world.sprite.get(e)
                sprite.node.runAction(SKAction.fadeInWithDuration(0.7))
                world.eventBus.raise(GameEvent.EnemyMadeVisibleForZone, data: e)
            }
        }
        
        // goals
        for e in world.goal.entities() {
            let location = world.location.get(e)
            if world.level.cells.get(location)!.zone == zoneID {
                let sprite = world.sprite.get(e)
                sprite.node.runAction(SKAction.fadeInWithDuration(0.3))
            }
        }
        
        // powerups
        for e in world.powerup.entities() {
            let location = world.location.get(e)
            if world.level.cells.get(location)!.zone == zoneID {
                let sprite = world.sprite.get(e)
                sprite.node.runAction(SKAction.fadeInWithDuration(0.3))
            }
        }
        
        // zone keys
        for e in world.zoneKey.entities() {
            let location = world.location.get(e)
            if world.level.cells.get(location)!.zone == zoneID {
                let sprite = world.sprite.get(e)
                sprite.node.runAction(SKAction.fadeInWithDuration(0.3))
            }
        }
    }
    
    
    
    /// when player enters a new zone in standalone mode,
    /// we want the enemies to skip a move
    func pauseEnemiesIfPlayerEnteredNewZone() {
        let currentLocation = world.location.get(world.mainPlayer)
        
        if !currentLocation.hasChanged() { return }
        
        let currentZone = world.level.cells.get(currentLocation)!.zone
        let previousZone = world.level.cells.get(currentLocation.previous())!.zone
        
        if currentZone == previousZone { return }
        
//        let player = world.player.get(world.mainPlayer)
//        if !player.teleportedInLastMove { return }
        
        // if the players zone has changed
        for e in world.enemy.entities() {
            let enemy = world.enemy.get(e)
            let enemyLocation = world.location.get(e)
            let enemyZone = world.level.cells.get(enemyLocation)!.zone
            if enemyZone == currentZone {
//                println("player previous location = \(currentLocation.previous())")
//                println("player current location = \(currentLocation)")
//                println("player location changed? = \(currentLocation.hasChanged())")
//                println("zone: \(currentZone) - enemy:\(e.id) - should skip a move")
                enemy.skipTurns = 1
            }
        }
        
    }
}