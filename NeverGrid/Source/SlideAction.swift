//
//  SlideAction.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

/// entry action to the slide controller
/// specific to the player
class SlidePlayerAction : EntityAction {
    var direction:UInt!
    
    override var description:String { return "SlidePlayerAction" }
    
    init(entity: Entity, world: WorldMapper, direction:UInt) {
        super.init(entity: entity, world: world)
        self.direction = direction
    }
    
    var slideController:SlidingPlayerController {
        return controller! as! SlidingPlayerController
    }
    
//    func tiltHat() {
//        let slideController = controller! as SlidingPlayerController
//        let tiltAngle = direction == Direction.Left ? -M_PI_32 : M_PI_32
//        let sprite = world.sprite.get(entity)
//        let hat = sprite.node.childNodeWithName("hat")!
//        let currentAngle = hat.zRotation
//        
//        // we need to tilt if we are changing directions
//        if currentAngle != tiltAngle {
//            // we need to tilt, taking
//            // slightly more time than a unit move
//            hat.runAction(SKAction.rotateToAngle(tiltAngle, duration: ActionFactory.Timing.EntityMove * 1.2))
//        }
//        
//        // set the hat tilted flag so that further attempts are avoided
//        slideController.hatTilted = true
//    }
//    
//    func bounceHat() {
//        let sprite = world.sprite.get(entity)
//        let hat = sprite.node.childNodeWithName("hat")!
//        hat.runAction(ActionFactory.sharedInstance.bounce)
//    }
    
    override func perform() -> SKAction? {
        
        // if we are not sliding, just return
        if direction == Direction.None {
            isBlocking = true
            return nil
        }
        
        let location = world.location.get(entity)
        let cell = world.level.cells.get(location)!
        if world.level.movePossible(cell, direction: direction) {
            if let neighbour = world.level.getNeighbour(cell, direction: direction) {

                
                
                var willHitPortal = false
                if let p = world.portalCache.get(neighbour.location) {
                    willHitPortal = world.portal.get(p).enabled
                }
                
                //slideController.doSlide()
                
                // move one player step
                controller?.add(MoveAlongDirection(entity: entity, world: world, direction:direction, duration:0.1))
                controller?.add(CheckGameWon(entity: entity, world: world))
                
                // keep moving until we hit a portal
                // or we can't move because of a wall
                if !willHitPortal {
                    controller?.add(SlidePlayerAction(entity: entity, world: world, direction:direction))
                }
            }
            return nil
        } else {
            // we can't move in this direction
            location.stayInPlace()
            isBlocking = true
            shouldWaitForActionCompletion = false
            return ActionFactory.sharedInstance.getShakeForDirection(direction)
        }
    }
}


