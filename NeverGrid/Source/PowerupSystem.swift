//
//  PowerupSystem.swift
//  OnGettingThere
//
//  Created by Benzi on 20/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class PowerupSystem : System {
    
    override init(_ world:WorldMapper){
        super.init(world)
        world.eventBus.subscribe(GameEvent.PowerupCollected, handler: self)
    }
    
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        if event == GameEvent.PowerupCollected {
            //collectPowerup(data as Entity)
            togglePowerup(data as! Entity)
        }
    }
    
    func collectPowerup(p:Entity) {
        let powerup = world.powerup.get(p)
        
        if powerup.powerupType == PowerupType.Freeze {
            // add a freeze component to all enemies
            for enemy in world.enemy.entities() {
                
                let enemyComponent = world.enemy.get(enemy)
                
                
                // only freeze active enemies
                if !enemyComponent.enabled { continue }
                
                // monsters cannot be frozen
                if enemyComponent.enemyType == EnemyType.Monster { continue }
                
                
                let enemyAlreadyFrozen = world.freeze.belongsTo(enemy)

                switch powerup.duration {
                case let PowerupDuration.TurnBased(turns):
                    if turns == 0 {
                        // a turns=0 specifies this is a swtich off powerup
                        // add to enemy only if already frozen otherwise ignore
                        // as add this to an enemy will have no effect
                        if enemyAlreadyFrozen {
                            world.manager.addComponent(enemy, c: FreezeComponent(duration: powerup.duration))
                        }
                    } else {
                        // we need to update if enemy already has, else add the component
                        world.manager.addComponent(enemy, c: FreezeComponent(duration: powerup.duration))
                        if !enemyAlreadyFrozen {
                            // we raise an event only if this is the first time an enemy is being
                            // frozen
                            world.eventBus.raise(GameEvent.EnemyFrozen, data: enemy)
                        }
                    }
                    
                    
                case PowerupDuration.Infinite:
                    world.manager.addComponent(enemy, c: FreezeComponent(duration: powerup.duration))
                    if !enemyAlreadyFrozen {
                        world.eventBus.raise(GameEvent.EnemyFrozen, data: enemy)
                    }
                }
            }
        }
        
        else if powerup.powerupType == PowerupType.Slide {
            // add a slide component to the player
            
            // if the slide powerup is of turns 0 (off switch, and player already has a 
            // slide component, remove it. else add
            switch powerup.duration {
            case let PowerupDuration.TurnBased(turns):
                if turns == 0 {
                    if world.slide.belongsTo(world.mainPlayer) {
                        world.eventBus.raise(GameEvent.SlideCompleted, data: world.mainPlayer)
                        world.eventBus.raise(GameEvent.SlideDeactivated, data: world.mainPlayer)
                        world.manager.removeComponent(world.mainPlayer, c: world.slide.get(world.mainPlayer))
                    }
                } else {
                    world.manager.addComponent(world.mainPlayer, c: SlideComponent(duration: powerup.duration))
                    world.eventBus.raise(GameEvent.SlideActivated, data: world.mainPlayer)
                }
            case PowerupDuration.Infinite:
                world.manager.addComponent(world.mainPlayer, c: SlideComponent(duration: powerup.duration))
                world.eventBus.raise(GameEvent.SlideActivated, data: world.mainPlayer)
            }
        }
    }
}


extension PowerupSystem {
    // MARK: toggle mode for powerups
    
    func togglePowerup(p:Entity) {
        let powerup = world.powerup.get(p)
        switch powerup.powerupType {
        case .Freeze: toggleFreeze()
        case .Slide: toggleSlide()
        }
    }
    
    func toggleSlide() {
        if world.slide.belongsTo(world.mainPlayer) {
            removeItemFromPlayer("helmet")
            world.eventBus.raise(GameEvent.SlideDeactivated, data: world.mainPlayer)
            world.manager.removeComponent(world.mainPlayer, c: world.slide.get(world.mainPlayer))
        } else {
            attachItemToPlayer("helmet", texture: "player_helmet")
            world.manager.addComponent(world.mainPlayer, c: SlideComponent(duration: PowerupDuration.Infinite))
            world.eventBus.raise(GameEvent.SlideActivated, data: world.mainPlayer)
        }
    }
    

    
    func toggleFreeze() {
        
        // are enabled enemies frozen?
        for e in world.enemy.entities() {
            let enemy = world.enemy.get(e)

            // only freeze active enemies
            if !enemy.enabled { continue }
            
            // monsters cannot be frozen
            if enemy.enemyType == EnemyType.Monster { continue }
            
            
            if world.freeze.belongsTo(e) {
                world.eventBus.raise(GameEvent.EnemyUnfrozen, data: e)
                world.manager.removeComponent(e, c: world.freeze.get(e))
            } else {
                world.manager.addComponent(e, c: FreezeComponent(duration: PowerupDuration.Infinite))
                world.eventBus.raise(GameEvent.EnemyFrozen, data: e)
            }
        }
    }
    
    func attachItemToPlayer(name:String, texture:String) {
        let item = entitySprite(texture)
        item.alpha = 0.0
        item.position = CGPointMake(0,0.5*world.gs.sideLength)
        item.size = world.gs.getSize(FactoredSizes.ScalingFactor.Player).scale(1.1)
        item.name = name
        item.runAction(
            // move in from top to player's head
            SKAction.moveTo(CGPointZero, duration: 0.3)
                .alongside(SKAction.fadeInWithDuration(0.3))
        )
        let sprite = world.sprite.get(world.mainPlayer)
        sprite.node.addChild(item)
    }
    
    func removeItemFromPlayer(name:String) {
        // remove the hat
        let sprite = world.sprite.get(world.mainPlayer)
        let item = sprite.node.childNodeWithName(name)!
        item.runAction(
            // 1. wait
            SKAction.waitForDuration(0.3)
                // 2. then fade out and move hat up
                .followedBy(
                    SKAction.fadeOutWithDuration(0.3)
                        .alongside(SKAction.moveTo(CGPointMake(0,0.5*world.gs.sideLength), duration:0.3))
                )
                // 3. then remove hat
                .followedBy(SKAction.removeFromParent())
        )
    }
}