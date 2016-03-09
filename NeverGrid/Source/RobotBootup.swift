//
//  RobotBootup.swift
//  NeverGrid
//
//  Created by Benzi on 21/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// action that boots up a robot if required
class RobotBootup : EntityAction {
    
    override var description:String { return "RobotBootup" }
    
    let baseRange = 1
    
    override func perform() -> SKAction? {
        
        let robot = world.enemy.get(entity)
        
        // if we have not booted up, check if we need to boot up
        // by looking at player proximity
        if !robot.bootedUp {
            let proximity = getProximity(self.baseRange)
            if proximity == .Alert || proximity == .InRange  {
                // if we have not already booted up
                // add a light node and start blinking
                robot.bootedUp = true
                
                // add the light node, and start blinking
                let sprite = world.sprite.get(entity)
                let robotBody = sprite.node.childNodeWithName("body")!
                let light = robotBody.childNodeWithName("light")!
                
                let lightOnOff = SKAction.fadeInWithDuration(0.5).followedBy(SKAction.fadeOutWithDuration(0.5))
                let lightAction = SKAction.repeatActionForever(lightOnOff)
                
                light.runAction(lightAction, withKey: "light-action")
                
                let eyes = robotBody.childNodeWithName("emotion")! as! SKSpriteNode
                eyes.texture = SpriteManager.Shared.entities.texture("robot_eyes_activated")
                
                
                let scanArea = sprite.node.childNodeWithName("scan_area")!
                scanArea.runAction(SKAction.scaleTo(1.75, duration: 0.3))
                
                world.eventBus.raise(GameEvent.RobotBooted, data: entity)

            }
            
            isBlocking = true
            return nil
        } else {
            // we have already booted up
            // is player in extended range so that we can follow?
            let proximity = getProximity(self.baseRange+1)
            if proximity == .OutOfRange  {
                robot.bootedUp = false
                
                let sprite = world.sprite.get(entity)
                let robotBody = sprite.node.childNodeWithName("body")!
                let light = robotBody.childNodeWithName("light")!
                light.removeAllActions()
                light.runAction(SKAction.fadeOutWithDuration(0.5))
                
                let eyes = robotBody.childNodeWithName("emotion")! as! SKSpriteNode
                eyes.texture = SpriteManager.Shared.entities.texture("robot_eyes")
                
                let scanArea = sprite.node.childNodeWithName("scan_area")!
                scanArea.runAction(SKAction.scaleTo(1.0, duration: 0.3))

                world.eventBus.raise(GameEvent.RobotShutdown, data: entity)
                
                isBlocking = true
                return nil
            }
        }
        
        return nil
    }
    
    
    private enum PlayerProximity {
        case InRange
        case Alert
        case OutOfRange
    }
    
    private func getProximity(range:Int) -> PlayerProximity {
        
        let player = world.location.get(world.mainPlayer)
        let enemy = world.location.get(entity)
        
        // is player within range
        if enemy.row-range <= player.row &&  player.row <= enemy.row+range
            && enemy.column-range <= player.column && player.column <= enemy.column+range {
                
                if player.row == enemy.row-range || player.row == enemy.row+range ||
                    player.column == enemy.column-range || player.column == enemy.column+range {
                        return .Alert
                } else {
                    return .InRange
                }
        }
        
        return .OutOfRange
    }
}