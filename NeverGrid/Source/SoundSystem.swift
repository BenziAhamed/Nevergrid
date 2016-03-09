//
//  SoundSystem.swift
//  gettingthere
//
//  Created by Benzi on 04/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

// responsible for all in game sounds
// try to make sure that all sound effects
// are triggered via the sound system
// this makes it easier to mute sounds by
// simply unsubscribing from related events
class SoundSystem : System {
    
    var enabled = false
    
    override init(_ world:WorldMapper) {
        super.init(world)
        enable()
    }
    
    func enable() {
        world.eventBus.subscribe(GameEvent.CoinCollected, handler: self)
        world.eventBus.subscribe(GameEvent.ZoneKeyCollected, handler: self)
        world.eventBus.subscribe(GameEvent.PlayerTeleportStarted, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
        world.eventBus.subscribe(GameEvent.EntityLanded, handler: self)
        world.eventBus.subscribe(GameEvent.CloneCreated, handler: self)
        world.eventBus.subscribe(GameEvent.PowerupCollected, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyFrozen, handler: self)
        world.eventBus.subscribe(GameEvent.RobotBooted, handler: self)
        enabled = true
    }
    
    func disable() {
        //world.eventBus.unsubscribe(self)
        enabled = false
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        
        switch event {
        
        case GameEvent.CoinCollected:
            world.scene!.runAction(ActionFactory.sharedInstance.playCollectCoin)

        case GameEvent.ZoneKeyCollected:
            world.scene!.runAction(ActionFactory.sharedInstance.playCollectItem)
            
        case GameEvent.PlayerTeleportStarted:
            world.scene!.runAction(ActionFactory.sharedInstance.playTeleport)
        
        case GameEvent.EnemyDeath:
            world.scene!.runAction(ActionFactory.sharedInstance.playDeath)

        case GameEvent.EntityLanded:
            world.scene!.runAction(ActionFactory.sharedInstance.playPop)

        case GameEvent.CloneCreated:
            world.scene!.runAction(ActionFactory.sharedInstance.playCloned)
            
        case GameEvent.PowerupCollected:
            world.scene!.runAction(ActionFactory.sharedInstance.playCollectItem)
            
        case GameEvent.EnemyFrozen:
            world.scene!.runAction(
                SKAction.waitForDuration(0.5)
                .followedBy(ActionFactory.sharedInstance.playPoink)
            )
            
        case GameEvent.RobotBooted:
            world.scene!.runAction(ActionFactory.sharedInstance.playRobotWakeup)
            
        default:
            break
        }
    }
}