//
//  RobotMoveOnce.swift
//  NeverGrid
//
//  Created by Benzi on 24/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


class RobotMoveOnce : MoveOnce {
    

    override var description:String { return "RobotMoveOnce" }

    override init(entity: Entity, world: WorldMapper, moveStrategy:EnemyMoveStrategy)  {
        super.init(entity: entity, world: world, moveStrategy:moveStrategy)
    }
    
    override func perform() -> SKAction? {
        let moveAction = super.perform()
        if moveAction != nil {
            
            // since a robot moves in an animated fashion lets get that on the way
            // move body up
            // do the move
            // after move completes we need to move body down
            // base move action takes ActionFactory.Timing.EntityMove time
            
            let sprite = world.sprite.get(entity)
            let robotHeight = sprite.node.size.height * (128.0/168.0)
            let timeForBodyAnimation = NSTimeInterval(0.2)
            let bodyAnimation =
                SKAction.moveByX(0.0, y: 0.125*robotHeight, duration: timeForBodyAnimation) // move up
                .followedBy(SKAction.waitForDuration(ActionFactory.Timing.EntityMove)) // wait for move to complete
                .followedBy(SKAction.moveByX(0.0, y: -0.125*robotHeight, duration: timeForBodyAnimation))
            
            let body = sprite.node.childNodeWithName("body")!
            body.runAction(bodyAnimation)
            
            let modifiedMoveAction =
                SKAction.waitForDuration(timeForBodyAnimation)
                .followedBy(moveAction!)
            
            return modifiedMoveAction
        }
        else {
            return nil
        }
        
    }

}