//
//  SlidingPlayerController.swift
//  MrGreen
//
//  Created by Benzi on 15/08/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit

class SlidingPlayerController: PlayerController {
    
    //var hatTilted = false
    
    private var slideActivated = false
    
    func doSlide() {
//        if slideActivated { return }
//        slideActivated = true
//        let playerSprite = world.sprite.get(world.mainPlayer).node
//        let slideEffect = entitySprite("slide_effect_\(Direction.Name[moveDirection]!)")
//        slideEffect.size = playerSprite.size
//        var targetPosition = CGPointZero
//        let offsetAmount:CGFloat = slideEffect.size.width * 0.95
//        // offset the position based on direction
//        switch moveDirection {
//        case Direction.Down:
//            slideEffect.position = CGPointMake(0.0, +offsetAmount)
//        case Direction.Up:
//            slideEffect.position = CGPointMake(0.0, -offsetAmount)
//        case Direction.Left:
//            slideEffect.position = CGPointMake(+offsetAmount, 0.0)
//        case Direction.Right:
//            slideEffect.position = CGPointMake(-offsetAmount, 0.0)
//        default: break
//        }
//        slideEffect.zPosition = playerSprite.zPosition - 1.0
//        slideEffect.name = "slide_effect"
//        playerSprite.addChild(slideEffect)
    }
    
    func endSlide() {
//        slideActivated = false
//        let playerSprite = world.sprite.get(world.mainPlayer).node
//        let slideEffect = playerSprite.childNodeWithName("slide_effect")!
//        slideEffect.removeFromParent()
    }
    
    override init(world: WorldMapper, moveDirection: UInt) {
        super.init(world: world, moveDirection: moveDirection)
        super.name = "SlidingPlayerController"
        add(SlidePlayerAction(entity: world.mainPlayer, world: world, direction: moveDirection))
    }
    
    override func begin() {
        super.begin()
        world.eventBus.raise(GameEvent.SlideStarted, data: world.mainPlayer)
    }
    
    override func end() {
        //if slideActivated { endSlide() }
        world.eventBus.raise(GameEvent.SlideCompleted, data: nil)
        
//        // check if we need to remove the slide behaviour
//        // slide mode
//        if world.slide.belongsTo(world.mainPlayer) {
//            let slide = world.slide.get(world.mainPlayer)
//            switch slide.duration {
//            case .Infinite:
//                world.eventBus.raise(GameEvent.SlideCompleted, data: slide)
//            case let .TurnBased(moves):
//                slide.duration = .TurnBased(moves-1)
//                world.eventBus.raise(GameEvent.SlideCompleted, data: slide)
//                if (moves-1) <= 0 {
//                    world.eventBus.raise(GameEvent.SlideDeactivated, data: slide)
//                    world.manager.removeComponent(world.mainPlayer, c: slide)
//                }
//            }
//        }
        
        super.end()
    }
}