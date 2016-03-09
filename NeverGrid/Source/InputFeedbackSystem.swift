//
//  InputFeedbackSystem.swift
//  NeverGrid
//
//  Created by Benzi on 16/10/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

// provides visual feedback of a player's move
class InputFeedbackSystem : System {
    
    override init(_ world: WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.DoPlayerMove, handler: self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        let move = data as! UInt
        let sprite = textSprite("move_\(Direction.Name[move]!)")
        sprite.position = CGPointMake(
            world.scene!.frame.midX,
            5.0 + sprite.frame.height/2.0
        )
        world.scene!.hudNode.addChild(sprite)
        sprite.runAction(
            SKAction.waitForDuration(5.0)
            .followedBy(SKAction.scaleTo(0.0, duration: 0.2))
            .followedBy(SKAction.removeFromParent())
        )
    }
    
}