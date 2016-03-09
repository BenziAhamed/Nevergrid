//
//  CloudSystem.swift
//  NeverGrid
//
//  Created by Benzi on 23/09/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class CloudSystem : System {
    
    
    override init(_ world:WorldMapper) {
        super.init(world)
        world.eventBus.subscribe(GameEvent.GameStarted, handler:self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
        case GameEvent.GameStarted:
            renderClouds(world.scene!)
        default:
            break
        }
    }
    

}

func renderClouds(scene:NavigatingScene) {
    let cloudNames = ["cloud_1","cloud_2","cloud_3"]
    let spawn = SKAction.runBlock {
        let name = any(cloudNames)
        let sprite = cloudSprite(name)
        let x =  scene.frame.width + sprite.size.width/2.0 + (50.0)*unitRandom()
        let offset = sprite.size.height/2.0+20.0
        let y = clamp(offset, max: scene.frame.height-offset, value: scene.frame.height*unitRandom())
        sprite.position = CGPointMake(x,y)
        sprite.setScale(0.5 + unitRandom())
        
        scene.backgroundNode.addChild(sprite)
        
        // move
        let destination = CGPointMake(-(2.0*sprite.size.width), sprite.position.y)
        let speed:CGFloat = 15.0 + 10.0 * unitRandom() // points per sec
        let distance:CGFloat = sprite.position.x - destination.x
        let time = NSTimeInterval((distance / speed) + 4.0*unitRandom())
        
        sprite.runAction(
            SKAction.moveTo(destination, duration: time)
                .followedBy(SKAction.removeFromParent())
        )

    }
    let delay = SKAction.waitForDuration(factor2(forPhone: 14.0, forPhone3x: 16.0, forPad: 20.0))
    let spawnForever = SKAction.repeatActionForever (
        spawn.followedBy(delay)
    )
    scene.runAction(spawnForever)
}